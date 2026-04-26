import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D, sum } from '../../common/utils/decimal';

@ApiTags('purchase-orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'procurement/purchase-orders', version: '1' })
export class PurchaseOrdersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('procurement.read')
  list() { return this.prisma.purchaseOrder.findMany({ orderBy: { date: 'desc' }, include: { partner: true, lines: true } }); }

  @Get(':id')
  @RequirePermissions('procurement.read')
  get(@Param('id') id: string) { return this.prisma.purchaseOrder.findUnique({ where: { id }, include: { partner: true, lines: true } }); }

  @Post()
  @RequirePermissions('procurement.create')
  async create(
    @Body() body: { partnerId: string; currency?: string; lines: { description: string; quantity: number; unitPrice: number }[] },
    @CurrentUser() u: JwtPayload,
  ) {
    const total = sum(body.lines.map((l) => D(l.quantity).times(l.unitPrice)));
    const year = new Date().getFullYear();
    const count = await this.prisma.purchaseOrder.count({ where: { date: { gte: new Date(`${year}-01-01`) } } });
    const number = `PO-${year}-${String(count + 1).padStart(5, '0')}`;
    return this.prisma.purchaseOrder.create({
      data: {
        tenantId: u.tenantId!,
        partnerId: body.partnerId,
        number,
        currency: body.currency ?? 'USD',
        total: total.toFixed(4),
        lines: {
          create: body.lines.map((l) => ({
            description: l.description,
            quantity: D(l.quantity).toFixed(4),
            unitPrice: D(l.unitPrice).toFixed(4),
            total: D(l.quantity).times(l.unitPrice).toFixed(4),
          })),
        },
      },
      include: { lines: true },
    });
  }
}
