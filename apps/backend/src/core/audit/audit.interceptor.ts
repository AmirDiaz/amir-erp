/**
 * Amir ERP — global audit interceptor for mutations.
 *
 * Captures method + path + status for every request, and records detailed
 * audit log entries for state-changing HTTP verbs (POST/PUT/PATCH/DELETE).
 *
 * Author: Amir Saoudi.
 */
import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { AuditService } from './audit.service';

const MUTATING = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(private readonly audit: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const req = http.getRequest<{ method: string; originalUrl: string; body?: unknown }>();

    return next.handle().pipe(
      tap((response: unknown) => {
        if (!MUTATING.has(req.method)) return;
        // Skip audit for auth endpoints (already logged separately)
        if (/^\/api\/v\d+\/auth\//.test(req.originalUrl)) return;

        const action = `${req.method.toLowerCase()} ${req.originalUrl}`;
        const entity = inferEntity(req.originalUrl);
        const entityId = (response as { id?: string } | null)?.id;

        // fire-and-forget; never block the response
        void this.audit.record({
          action,
          entity,
          entityId,
          after: response,
        });
      }),
    );
  }
}

function inferEntity(url: string): string {
  const m = url.match(/\/api\/v\d+\/([^/?]+)/);
  return m?.[1] ?? 'unknown';
}
