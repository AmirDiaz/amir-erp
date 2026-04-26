/**
 * Amir ERP — async-local-storage based tenant context.
 * Author: Amir Saoudi.
 */
import { Injectable } from '@nestjs/common';
import { AsyncLocalStorage } from 'node:async_hooks';

export interface TenantInfo {
  tenantId: string | null;
  userId?: string;
  roles?: string[];
  permissions?: string[];
  ip?: string;
  userAgent?: string;
}

@Injectable()
export class TenantContext {
  private readonly als = new AsyncLocalStorage<TenantInfo>();

  runWith<T>(info: TenantInfo, fn: () => T): T {
    return this.als.run(info, fn);
  }

  runWithTenant<T>(tenantId: string | null, fn: () => Promise<T>): Promise<T> {
    return this.als.run({ tenantId }, fn);
  }

  current(): TenantInfo | undefined { return this.als.getStore(); }
  tenantId(): string | null { return this.als.getStore()?.tenantId ?? null; }
  userId(): string | undefined { return this.als.getStore()?.userId; }
  roles(): string[] { return this.als.getStore()?.roles ?? []; }
  permissions(): string[] { return this.als.getStore()?.permissions ?? []; }
}
