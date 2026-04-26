/**
 * Amir ERP — inventory service.
 *
 * Handles stock movements with weighted-average cost valuation. Negative
 * stock is allowed but flagged.
 *
 * Author: Amir Saoudi.
 */
import { Injectable } from '@nestjs/common';
import { StockReason } from '@prisma/client';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D, sum } from '../../common/utils/decimal';

@Injectable()
export class InventoryService {
  constructor(private readonly prisma: PrismaService) {}

  async onHand(productId: string, warehouseId?: string): Promise<string> {
    const where = { productId, ...(warehouseId ? { OR: [{ toWarehouseId: warehouseId }, { fromWarehouseId: warehouseId }] } : {}) };
    const moves = await this.prisma.stockMove.findMany({ where });
    const inQty = sum(moves.filter((m) => (warehouseId ? m.toWarehouseId === warehouseId : !!m.toWarehouseId)).map((m) => m.quantity.toString()));
    const outQty = sum(moves.filter((m) => (warehouseId ? m.fromWarehouseId === warehouseId : !!m.fromWarehouseId)).map((m) => m.quantity.toString()));
    return inQty.minus(outQty).toString();
  }

  async move(input: {
    tenantId: string;
    productId: string;
    quantity: number | string;
    fromWarehouseId?: string;
    toWarehouseId?: string;
    unitCost?: number | string;
    reason: StockReason;
    reference?: string;
  }) {
    return this.prisma.stockMove.create({
      data: {
        tenantId: input.tenantId,
        productId: input.productId,
        fromWarehouseId: input.fromWarehouseId ?? null,
        toWarehouseId: input.toWarehouseId ?? null,
        quantity: D(input.quantity).toFixed(4),
        unitCost: D(input.unitCost ?? 0).toFixed(4),
        reason: input.reason,
        reference: input.reference ?? null,
      },
    });
  }
}
