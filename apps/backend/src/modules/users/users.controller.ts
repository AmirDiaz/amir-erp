import { Body, Controller, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'users', version: '1' })
export class UsersController {
  constructor(private readonly svc: UsersService) {}

  @Get()
  @RequirePermissions('users.read')
  list() { return this.svc.list(); }

  @Post('invite')
  @RequirePermissions('users.invite')
  invite(@Body() body: { email: string; fullName: string; roleIds?: string[] }, @CurrentUser() u: JwtPayload) {
    return this.svc.invite({ ...body, tenantId: u.tenantId! });
  }

  @Put(':userId/roles')
  @RequirePermissions('users.update')
  setRoles(@Param('userId') userId: string, @Body() body: { roleIds: string[] }, @CurrentUser() u: JwtPayload) {
    return this.svc.setRoles(userId, u.tenantId!, body.roleIds);
  }
}
