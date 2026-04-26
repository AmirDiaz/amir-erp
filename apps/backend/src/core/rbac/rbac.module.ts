import { Global, Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { RbacService } from './rbac.service';
import { PermissionsGuard } from './permissions.guard';

@Global()
@Module({
  providers: [
    RbacService,
    PermissionsGuard,
    { provide: APP_GUARD, useExisting: PermissionsGuard },
  ],
  exports: [RbacService, PermissionsGuard],
})
export class RbacModule {}
