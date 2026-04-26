import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('assets')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'assets', version: '1' })
export class AssetsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('assets.read')
  list() { return this.prisma.asset.findMany({ orderBy: { createdAt: 'desc' }, include: { employee: true } }); }

  @Post()
  @RequirePermissions('assets.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.asset.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('assets.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.prisma.asset.update({ where: { id }, data: body as Record<string, unknown> }); }

  @Delete(':id')
  @RequirePermissions('assets.delete')
  remove(@Param('id') id: string) { return this.prisma.asset.delete({ where: { id } }); }
}
