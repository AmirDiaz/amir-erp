/**
 * Amir ERP — authentication service.
 *
 * - Argon2id password hashing
 * - Short-lived JWT access tokens
 * - Long-lived rotating refresh tokens (hashed at rest, single-use)
 *
 * Author: Amir Saoudi.
 */
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { createHash, randomBytes } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import { AppConfig } from '../config/app.config';
import { RbacService } from '../rbac/rbac.service';

export interface JwtPayload {
  sub: string;       // user id
  email: string;
  tenantId?: string;
  roles?: string[];
  permissions?: string[];
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly cfg: AppConfig,
    private readonly rbac: RbacService,
  ) {}

  async hashPassword(plain: string): Promise<string> {
    return argon2.hash(plain, { type: argon2.argon2id });
  }

  async verifyPassword(hash: string, plain: string): Promise<boolean> {
    try { return await argon2.verify(hash, plain); }
    catch { return false; }
  }

  async register(input: {
    email: string;
    password: string;
    fullName: string;
    tenantSlug: string;
    tenantName?: string;
  }): Promise<{ userId: string; tenantId: string }> {
    const existing = await this.prisma.user.findUnique({ where: { email: input.email } });
    if (existing) throw new ConflictException('Email already registered');

    const passwordHash = await this.hashPassword(input.password);

    return this.prisma.unscoped(async (db) => {
      let tenant = await db.tenant.findUnique({ where: { slug: input.tenantSlug } });
      if (!tenant) {
        tenant = await db.tenant.create({
          data: { slug: input.tenantSlug, name: input.tenantName ?? input.tenantSlug },
        });
      }
      const user = await db.user.create({
        data: { email: input.email, password: passwordHash, fullName: input.fullName },
      });
      await db.userTenant.create({
        data: { userId: user.id, tenantId: tenant.id, isOwner: true, roleIds: [] },
      });
      return { userId: user.id, tenantId: tenant.id };
    });
  }

  async login(email: string, password: string, tenantSlug?: string): Promise<AuthTokens & { user: { id: string; email: string; fullName: string }; tenantId: string }> {
    const user = await this.prisma.unscoped((db) => db.user.findUnique({ where: { email } }));
    if (!user) throw new UnauthorizedException('Invalid credentials');
    const ok = await this.verifyPassword(user.password, password);
    if (!ok) throw new UnauthorizedException('Invalid credentials');

    const memberships = await this.prisma.unscoped((db) =>
      db.userTenant.findMany({ where: { userId: user.id }, include: { tenant: true } }),
    );
    if (memberships.length === 0) throw new UnauthorizedException('No tenant access');

    const membership =
      (tenantSlug && memberships.find((m) => m.tenant.slug === tenantSlug)) || memberships[0];

    await this.prisma.unscoped((db) =>
      db.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } }),
    );

    const permissions = membership.isOwner
      ? ['*']
      : await this.rbac.resolvePermissionsForRoles(membership.tenantId, membership.roleIds);

    const tokens = await this.issueTokens({
      sub: user.id,
      email: user.email,
      tenantId: membership.tenantId,
      roles: membership.roleIds,
      permissions,
    });

    return {
      ...tokens,
      tenantId: membership.tenantId,
      user: { id: user.id, email: user.email, fullName: user.fullName },
    };
  }

  async issueTokens(payload: JwtPayload): Promise<AuthTokens> {
    const accessToken = await this.jwt.signAsync(payload, {
      secret: this.cfg.jwt.accessSecret,
      expiresIn: this.cfg.jwt.accessTtl,
    });

    const refreshRaw = randomBytes(48).toString('hex');
    const refreshToken = `${payload.sub}.${refreshRaw}`;
    const tokenHash = createHash('sha256').update(refreshToken).digest('hex');

    await this.prisma.unscoped((db) =>
      db.refreshToken.create({
        data: {
          userId: payload.sub,
          tokenHash,
          expiresAt: new Date(Date.now() + this.cfg.jwt.refreshTtl * 1000),
        },
      }),
    );

    return { accessToken, refreshToken, expiresIn: this.cfg.jwt.accessTtl };
  }

  async refresh(refreshToken: string): Promise<AuthTokens> {
    const tokenHash = createHash('sha256').update(refreshToken).digest('hex');
    const record = await this.prisma.unscoped((db) =>
      db.refreshToken.findUnique({ where: { tokenHash } }),
    );
    if (!record || record.revokedAt || record.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid refresh token');
    }
    await this.prisma.unscoped((db) =>
      db.refreshToken.update({ where: { id: record.id }, data: { revokedAt: new Date() } }),
    );

    const memberships = await this.prisma.unscoped((db) =>
      db.userTenant.findMany({ where: { userId: record.userId } }),
    );
    const user = await this.prisma.unscoped((db) =>
      db.user.findUniqueOrThrow({ where: { id: record.userId } }),
    );
    const m = memberships[0];
    const permissions = m?.isOwner
      ? ['*']
      : m
        ? await this.rbac.resolvePermissionsForRoles(m.tenantId, m.roleIds)
        : [];
    return this.issueTokens({
      sub: user.id,
      email: user.email,
      tenantId: m?.tenantId,
      roles: m?.roleIds ?? [],
      permissions,
    });
  }

  async logout(refreshToken: string): Promise<void> {
    const tokenHash = createHash('sha256').update(refreshToken).digest('hex');
    await this.prisma.unscoped((db) =>
      db.refreshToken.updateMany({ where: { tokenHash }, data: { revokedAt: new Date() } }),
    );
  }
}
