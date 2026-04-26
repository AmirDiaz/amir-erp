import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { AuthService } from '../../core/auth/auth.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService, private readonly auth: AuthService) {}

  list() {
    return this.prisma.unscoped((db) => db.user.findMany({ orderBy: { createdAt: 'desc' } }));
  }

  async invite(input: { email: string; fullName: string; tenantId: string; roleIds?: string[]; password?: string }) {
    const password = input.password ?? Math.random().toString(36).slice(2) + 'A!1';
    const hash = await this.auth.hashPassword(password);
    return this.prisma.unscoped(async (db) => {
      const user = await db.user.upsert({
        where: { email: input.email },
        update: {},
        create: { email: input.email, fullName: input.fullName, password: hash, status: 'INVITED' },
      });
      await db.userTenant.upsert({
        where: { userId_tenantId: { userId: user.id, tenantId: input.tenantId } },
        update: { roleIds: input.roleIds ?? [] },
        create: { userId: user.id, tenantId: input.tenantId, roleIds: input.roleIds ?? [] },
      });
      return { user, tempPassword: password };
    });
  }

  setRoles(userId: string, tenantId: string, roleIds: string[]) {
    return this.prisma.unscoped((db) =>
      db.userTenant.update({ where: { userId_tenantId: { userId, tenantId } }, data: { roleIds } }),
    );
  }
}
