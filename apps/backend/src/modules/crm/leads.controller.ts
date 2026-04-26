import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('crm-leads')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'crm/leads', version: '1' })
export class LeadsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('crm.read')
  list() { return this.prisma.lead.findMany({ orderBy: { createdAt: 'desc' } }); }

  @Get('pipeline')
  @RequirePermissions('crm.read')
  async pipeline() {
    const leads = await this.prisma.lead.findMany();
    const stages = ['NEW', 'QUALIFIED', 'CONTACTED', 'PROPOSAL', 'WON', 'LOST'] as const;
    return stages.map((stage) => ({ stage, count: leads.filter((l) => l.stage === stage).length, items: leads.filter((l) => l.stage === stage) }));
  }

  @Post()
  @RequirePermissions('crm.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.lead.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('crm.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.lead.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('crm.delete')
  remove(@Param('id') id: string) { return this.prisma.lead.delete({ where: { id } }); }
}
