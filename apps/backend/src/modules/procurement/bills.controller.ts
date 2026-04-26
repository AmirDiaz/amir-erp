import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('bills')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'procurement/bills', version: '1' })
export class BillsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('procurement.read')
  list() { return this.prisma.bill.findMany({ orderBy: { date: 'desc' }, include: { partner: true } }); }

  @Get(':id')
  @RequirePermissions('procurement.read')
  get(@Param('id') id: string) { return this.prisma.bill.findUnique({ where: { id } }); }

  @Post()
  @RequirePermissions('procurement.create')
  async create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    const year = new Date().getFullYear();
    const n = await this.prisma.bill.count({ where: { date: { gte: new Date(`${year}-01-01`) } } });
    const number = (body.number as string) ?? `BL-${year}-${String(n + 1).padStart(5, '0')}`;
    return this.prisma.bill.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId!, number } as any });
  }
}
