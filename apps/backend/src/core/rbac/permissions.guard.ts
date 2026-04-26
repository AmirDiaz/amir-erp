/**
 * Amir ERP — permission guard. Reads required permissions set via
 * `@RequirePermissions(...)` and validates against the JWT payload.
 *
 * Author: Amir Saoudi.
 */
import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../auth/decorators/permissions.decorator';
import { RbacService } from './rbac.service';
import { JwtPayload } from '../auth/auth.service';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>(PERMISSIONS_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!required || required.length === 0) return true;

    const req = context.switchToHttp().getRequest<{ user?: JwtPayload }>();
    const user = req.user;
    if (!user) throw new ForbiddenException('No user');
    const perms = user.permissions ?? [];
    const ok = required.every((r) => RbacService.check(perms, r));
    if (!ok) throw new ForbiddenException(`Missing permissions: ${required.join(', ')}`);
    return true;
  }
}
