/**
 * Amir ERP — tenant resolver middleware.
 *
 * Resolution order:
 *   1. `X-Tenant-Id` header
 *   2. JWT claim (`tenant_id`) populated by AuthGuard
 *   3. Subdomain (`<slug>.amir-erp.com`)
 *
 * Author: Amir Saoudi.
 */
import { Injectable, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { TenantContext } from './tenant.context';

@Injectable()
export class TenancyMiddleware implements NestMiddleware {
  constructor(private readonly ctx: TenantContext) {}

  use(req: Request, _res: Response, next: NextFunction): void {
    const headerTenant = req.header('x-tenant-id') || null;
    const subTenant = subdomainTenant(req.hostname);
    const tenantId = headerTenant || subTenant || null;

    this.ctx.runWith(
      {
        tenantId,
        ip: req.ip,
        userAgent: req.header('user-agent') || undefined,
      },
      () => next(),
    );
  }
}

function subdomainTenant(host: string | undefined): string | null {
  if (!host) return null;
  const parts = host.split('.');
  if (parts.length < 3) return null;
  const sub = parts[0];
  if (['www', 'api', 'app', 'admin'].includes(sub)) return null;
  return sub;
}
