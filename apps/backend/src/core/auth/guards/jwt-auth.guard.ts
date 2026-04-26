/**
 * Amir ERP — JWT auth guard.
 *
 * Skips authentication for handlers marked with @Public(). On success, hydrates
 * the tenant context with the user/tenant/roles from the JWT.
 *
 * Author: Amir Saoudi.
 */
import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { TenantContext } from '../../tenancy/tenant.context';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { JwtPayload } from '../auth.service';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(
    private readonly reflector: Reflector,
    private readonly tenantCtx: TenantContext,
  ) {
    super();
  }

  canActivate(context: ExecutionContext): boolean | Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;
    return super.canActivate(context) as boolean | Promise<boolean>;
  }

  handleRequest<TUser extends JwtPayload = JwtPayload>(err: unknown, user: TUser): TUser {
    if (err || !user) {
      throw err || new Error('Unauthorized');
    }
    const existing = this.tenantCtx.current();
    this.tenantCtx.runWith(
      {
        tenantId: user.tenantId ?? existing?.tenantId ?? null,
        userId: user.sub,
        roles: user.roles ?? [],
        permissions: user.permissions ?? [],
        ip: existing?.ip,
        userAgent: existing?.userAgent,
      },
      () => undefined,
    );
    return user;
  }
}
