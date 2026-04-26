/**
 * Amir ERP — Prisma service with auto multi-tenant scoping.
 *
 * Tenant isolation strategy:
 *   - For every model that has a `tenantId` field, all `find*` and `count`
 *     queries are automatically scoped to the active tenant taken from the
 *     async-local-storage context (`TenantContext`).
 *   - Mutations (`create`/`update`/`upsert`/`delete*`) inject the active
 *     tenant id when not provided.
 *   - Superadmin requests (no tenant context) bypass scoping.
 *
 * Author: Amir Saoudi.
 */
import { Injectable, OnModuleDestroy, OnModuleInit, Logger } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { TenantContext } from '../tenancy/tenant.context';

const SCOPED_MODELS = new Set<string>([
  'Company', 'Branch', 'Role', 'UserTenant',
  'Account', 'JournalEntry', 'Tax',
  'Partner', 'Product', 'Warehouse', 'StockMove',
  'Quotation', 'Contract', 'Lead', 'Opportunity',
  'Invoice', 'Payment',
  'PurchaseOrder', 'Bill',
  'PosSession', 'PosOrder',
  'ManufacturingOrder', 'Bom',
  'Project', 'Task',
  'Employee', 'Payslip', 'Expense', 'Asset',
  'Notification', 'AuditLog', 'Workflow', 'Plugin', 'FileObject',
]);

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(private readonly tenantContext: TenantContext) {
    super({
      log: [
        { emit: 'event', level: 'query' },
        { emit: 'event', level: 'warn' },
        { emit: 'event', level: 'error' },
      ],
    });
  }

  async onModuleInit(): Promise<void> {
    this.$use(async (params, next) => {
      const tenantId = this.tenantContext.tenantId();
      if (tenantId && params.model && SCOPED_MODELS.has(params.model)) {
        switch (params.action) {
          case 'findFirst':
          case 'findFirstOrThrow':
          case 'findMany':
          case 'findUnique':
          case 'findUniqueOrThrow':
          case 'count':
          case 'aggregate':
          case 'groupBy': {
            params.args = params.args || {};
            params.args.where = mergeWhere(params.args.where, { tenantId });
            break;
          }
          case 'updateMany':
          case 'deleteMany': {
            params.args = params.args || {};
            params.args.where = mergeWhere(params.args.where, { tenantId });
            break;
          }
          case 'create': {
            params.args = params.args || { data: {} };
            params.args.data = { ...params.args.data, tenantId: params.args.data?.tenantId ?? tenantId };
            break;
          }
          case 'createMany': {
            params.args = params.args || { data: [] };
            const rows = Array.isArray(params.args.data) ? params.args.data : [params.args.data];
            params.args.data = rows.map((r: Record<string, unknown>) => ({
              tenantId: (r as { tenantId?: string }).tenantId ?? tenantId,
              ...r,
            }));
            break;
          }
          case 'update':
          case 'upsert':
          case 'delete': {
            params.args = params.args || {};
            params.args.where = mergeWhere(params.args.where, { tenantId });
            break;
          }
          default:
            break;
        }
      }
      return next(params);
    });

    await this.$connect();
    this.logger.log('Prisma connected');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  /**
   * Helpful escape hatch when an admin/cron job genuinely needs to operate
   * across tenants (e.g. cross-tenant reporting, super-admin actions).
   */
  unscoped<T>(fn: (db: PrismaClient) => Promise<T>): Promise<T> {
    return this.tenantContext.runWithTenant(null, () => fn(this));
  }
}

function mergeWhere(existing: unknown, scoped: Record<string, unknown>): Record<string, unknown> {
  if (!existing) return scoped;
  if (typeof existing !== 'object') return scoped;
  return { AND: [existing as Prisma.JsonObject, scoped] } as Record<string, unknown>;
}
