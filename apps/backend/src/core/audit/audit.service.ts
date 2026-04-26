import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TenantContext } from '../tenancy/tenant.context';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);
  constructor(
    private readonly prisma: PrismaService,
    private readonly ctx: TenantContext,
  ) {}

  async record(input: {
    action: string;
    entity: string;
    entityId?: string;
    before?: unknown;
    after?: unknown;
  }): Promise<void> {
    try {
      const info = this.ctx.current();
      await this.prisma.unscoped((db) =>
        db.auditLog.create({
          data: {
            tenantId: info?.tenantId ?? null,
            userId: info?.userId ?? null,
            action: input.action,
            entity: input.entity,
            entityId: input.entityId ?? null,
            before: (input.before ?? null) as never,
            after: (input.after ?? null) as never,
            ip: info?.ip ?? null,
            userAgent: info?.userAgent ?? null,
          },
        }),
      );
    } catch (e) {
      this.logger.warn(`audit log failed: ${(e as Error).message}`);
    }
  }
}
