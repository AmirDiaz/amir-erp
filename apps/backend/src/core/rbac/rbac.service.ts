/**
 * Amir ERP — RBAC + ABAC engine (CASL-flavored).
 *
 * Permission tokens are dot-separated:
 *   `module.action`            e.g. `invoicing.read`
 *   `module.action.scope`      e.g. `invoicing.read.own`
 *   `*`                        wildcard (superadmin)
 *
 * Author: Amir Saoudi.
 */
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export const SYSTEM_ROLES = {
  OWNER: {
    name: 'Owner',
    description: 'Full access to all modules within a tenant',
    permissions: ['*'],
    isSystem: true,
  },
  ADMIN: {
    name: 'Admin',
    description: 'Manage all modules except billing/tenant settings',
    permissions: [
      'accounting.*', 'invoicing.*', 'payments.*', 'taxes.*', 'reports.*',
      'sales.*', 'crm.*', 'quotations.*', 'contracts.*',
      'inventory.*', 'warehouses.*', 'procurement.*', 'partners.*',
      'pos.*', 'manufacturing.*', 'projects.*', 'hr.*',
      'payroll.*', 'expenses.*', 'assets.*', 'notifications.*',
      'users.read', 'users.invite',
    ],
    isSystem: true,
  },
  ACCOUNTANT: {
    name: 'Accountant',
    description: 'Financial modules',
    permissions: [
      'accounting.*', 'invoicing.*', 'payments.*', 'taxes.*', 'reports.*',
      'expenses.*', 'partners.read',
    ],
    isSystem: true,
  },
  SALES: {
    name: 'Sales',
    description: 'Sales / CRM',
    permissions: [
      'sales.*', 'crm.*', 'quotations.*', 'contracts.*',
      'invoicing.read', 'invoicing.create', 'partners.*',
    ],
    isSystem: true,
  },
  WAREHOUSE: {
    name: 'Warehouse',
    description: 'Inventory + procurement',
    permissions: [
      'inventory.*', 'warehouses.*', 'procurement.*', 'partners.read',
    ],
    isSystem: true,
  },
  CASHIER: {
    name: 'Cashier',
    description: 'POS only',
    permissions: ['pos.*', 'inventory.read', 'partners.read'],
    isSystem: true,
  },
  HR: {
    name: 'HR',
    description: 'HR + payroll + expenses',
    permissions: ['hr.*', 'payroll.*', 'expenses.*', 'assets.*'],
    isSystem: true,
  },
  VIEWER: {
    name: 'Viewer',
    description: 'Read-only across all modules',
    permissions: ['*.read'],
    isSystem: true,
  },
} as const;

@Injectable()
export class RbacService {
  constructor(private readonly prisma: PrismaService) {}

  static check(userPermissions: string[], required: string): boolean {
    if (!required) return true;
    if (userPermissions.includes('*')) return true;
    if (userPermissions.includes(required)) return true;
    const [mod] = required.split('.');
    if (userPermissions.includes(`${mod}.*`)) return true;
    if (userPermissions.includes('*.read') && required.endsWith('.read')) return true;
    return false;
  }

  async resolvePermissionsForRoles(tenantId: string, roleIds: string[]): Promise<string[]> {
    if (roleIds.length === 0) return [];
    const roles = await this.prisma.unscoped((db) =>
      db.role.findMany({ where: { id: { in: roleIds }, tenantId } }),
    );
    const set = new Set<string>();
    for (const role of roles) {
      const perms = (role.permissions as unknown as string[]) ?? [];
      perms.forEach((p) => set.add(p));
    }
    return Array.from(set);
  }

  async ensureSystemRoles(tenantId: string): Promise<void> {
    for (const role of Object.values(SYSTEM_ROLES)) {
      await this.prisma.unscoped((db) =>
        db.role.upsert({
          where: { tenantId_name: { tenantId, name: role.name } },
          update: { permissions: role.permissions, description: role.description, isSystem: true },
          create: {
            tenantId,
            name: role.name,
            description: role.description,
            permissions: role.permissions,
            isSystem: true,
          },
        }),
      );
    }
  }
}
