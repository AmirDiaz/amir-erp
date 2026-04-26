import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { TenantsService } from './tenants.service';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';

@ApiTags('tenants')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'tenants', version: '1' })
export class TenantsController {
  constructor(private readonly svc: TenantsService) {}

  @Get()
  @RequirePermissions('tenants.read')
  list() { return this.svc.list(); }

  @Get(':id')
  @RequirePermissions('tenants.read')
  get(@Param('id') id: string) { return this.svc.get(id); }

  @Post()
  @RequirePermissions('tenants.create')
  create(@Body() body: { slug: string; name: string }) { return this.svc.create(body); }

  @Patch(':id')
  @RequirePermissions('tenants.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.svc.update(id, body as Record<string, unknown>);
  }
}
