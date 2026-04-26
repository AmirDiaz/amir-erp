import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { BrandingService } from './branding.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Public } from '../auth/decorators/public.decorator';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { JwtPayload } from '../auth/auth.service';
import { TenantContext } from '../tenancy/tenant.context';

@ApiTags('branding')
@Controller({ path: 'branding', version: '1' })
export class BrandingController {
  constructor(private readonly branding: BrandingService, private readonly ctx: TenantContext) {}

  @Public()
  @Get('public')
  async publicTheme() {
    const tenantId = this.ctx.tenantId();
    if (!tenantId) return { appName: 'Amir ERP' };
    return this.branding.forTenant(tenantId);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get()
  get(@CurrentUser() u: JwtPayload) { return this.branding.forTenant(u.tenantId!); }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Patch()
  @RequirePermissions('branding.update')
  update(@CurrentUser() u: JwtPayload, @Body() body: Record<string, unknown>) {
    return this.branding.update(u.tenantId!, body);
  }
}
