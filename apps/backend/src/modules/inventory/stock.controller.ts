import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StockReason } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { InventoryService } from './inventory.service';

@ApiTags('stock')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'inventory/stock', version: '1' })
export class StockController {
  constructor(private readonly prisma: PrismaService, private readonly inv: InventoryService) {}

  @Get('on-hand/:productId')
  @RequirePermissions('inventory.read')
  onHand(@Param('productId') productId: string, @Query('warehouse') warehouseId?: string) {
    return this.inv.onHand(productId, warehouseId).then((qty) => ({ productId, warehouseId, qty }));
  }

  @Get('moves')
  @RequirePermissions('inventory.read')
  moves(@Query('product') productId?: string, @Query('warehouse') warehouseId?: string) {
    return this.prisma.stockMove.findMany({
      where: { ...(productId ? { productId } : {}), ...(warehouseId ? { OR: [{ fromWarehouseId: warehouseId }, { toWarehouseId: warehouseId }] } : {}) },
      orderBy: { date: 'desc' }, take: 200, include: { product: true, fromWarehouse: true, toWarehouse: true },
    });
  }

  @Post('move')
  @RequirePermissions('inventory.update')
  move(@Body() body: { productId: string; quantity: number; fromWarehouseId?: string; toWarehouseId?: string; unitCost?: number; reason: StockReason; reference?: string }, @CurrentUser() u: JwtPayload) {
    return this.inv.move({ ...body, tenantId: u.tenantId! });
  }
}
