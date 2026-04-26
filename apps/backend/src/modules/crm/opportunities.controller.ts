import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('crm-opportunities')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'crm/opportunities', version: '1' })
export class OpportunitiesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('crm.read')
  list() { return this.prisma.opportunity.findMany({ orderBy: { createdAt: 'desc' } }); }

  @Post()
  @RequirePermissions('crm.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.opportunity.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('crm.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.opportunity.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('crm.delete')
  remove(@Param('id') id: string) { return this.prisma.opportunity.delete({ where: { id } }); }
}
