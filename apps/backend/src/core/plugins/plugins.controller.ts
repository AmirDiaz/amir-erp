import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';
import { PluginsService } from './plugins.service';

@ApiTags('plugins')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'plugins', version: '1' })
export class PluginsController {
  constructor(private readonly plugins: PluginsService) {}

  @Get('marketplace')
  marketplace() { return this.plugins.manifests(); }

  @Get()
  @RequirePermissions('plugins.read')
  list() { return this.plugins.list(); }

  @Post('install')
  @RequirePermissions('plugins.update')
  install(@Body() body: { key: string; config?: Record<string, unknown> }, @CurrentUser() u: JwtPayload) {
    return this.plugins.install({ tenantId: u.tenantId!, key: body.key, config: body.config });
  }

  @Patch(':id/toggle')
  @RequirePermissions('plugins.update')
  toggle(@Param('id') id: string, @Body() body: { isEnabled: boolean }) {
    return this.plugins.toggle(id, body.isEnabled);
  }

  @Delete(':id')
  @RequirePermissions('plugins.delete')
  uninstall(@Param('id') id: string) { return this.plugins.uninstall(id); }
}
