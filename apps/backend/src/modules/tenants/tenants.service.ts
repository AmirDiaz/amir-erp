import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { RbacService } from '../../core/rbac/rbac.service';

@Injectable()
export class TenantsService {
  constructor(private readonly prisma: PrismaService, private readonly rbac: RbacService) {}

  async list() { return this.prisma.unscoped((db) => db.tenant.findMany({ orderBy: { createdAt: 'desc' } })); }
  async get(id: string) { return this.prisma.unscoped((db) => db.tenant.findUnique({ where: { id } })); }

  async create(input: { slug: string; name: string }) {
    const tenant = await this.prisma.unscoped((db) => db.tenant.create({ data: input }));
    await this.rbac.ensureSystemRoles(tenant.id);
    return tenant;
  }

  async update(id: string, patch: { name?: string; status?: 'ACTIVE' | 'SUSPENDED' | 'TRIAL' | 'ARCHIVED'; features?: Record<string, unknown> }) {
    return this.prisma.unscoped((db) => db.tenant.update({ where: { id }, data: patch as never }));
  }
}
