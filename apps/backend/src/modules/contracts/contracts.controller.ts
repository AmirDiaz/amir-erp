import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('contracts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'contracts', version: '1' })
export class ContractsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('contracts.read')
  list() { return this.prisma.contract.findMany({ orderBy: { createdAt: 'desc' }, include: { partner: true } }); }

  @Post()
  @RequirePermissions('contracts.create')
  async create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    const year = new Date().getFullYear();
    const n = await this.prisma.contract.count({ where: { startDate: { gte: new Date(`${year}-01-01`) } } });
    return this.prisma.contract.create({
      data: { ...(body as Record<string, unknown>), tenantId: u.tenantId!, number: (body.number as string) ?? `CT-${year}-${String(n + 1).padStart(4, '0')}` } as any,
    });
  }

  @Patch(':id')
  @RequirePermissions('contracts.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.contract.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('contracts.delete')
  remove(@Param('id') id: string) { return this.prisma.contract.delete({ where: { id } }); }
}
