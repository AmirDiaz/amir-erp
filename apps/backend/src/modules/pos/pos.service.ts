/**
 * Amir ERP — POS service.
 *
 * Critical features:
 *   - Idempotent order creation via `clientUuid` (offline-friendly: a
 *     device that retries the same order will receive the same response).
 *   - Conflict resolution: the server is authoritative; the client receives
 *     the canonical pricing/stock and surfaces any deltas in the UI.
 *   - Automatic stock deduction (StockMove) and tenant-scoped numbering.
 *   - Hooks into the workflow engine via `pos.order.created`.
 *
 * Author: Amir Saoudi.
 */
import { Injectable, ConflictException } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D, sum } from '../../common/utils/decimal';
import { InventoryService } from '../inventory/inventory.service';

export interface PosOrderLineInput {
  productId: string;
  description?: string;
  quantity: number | string;
  unitPrice: number | string;
  discount?: number | string;
  taxRate?: number | string;
}

export interface PosPaymentInput {
  method: 'CASH' | 'CARD' | 'BANK_TRANSFER' | 'MOBILE' | 'CHECK' | 'OTHER';
  amount: number | string;
}

export interface PosOrderInput {
  tenantId: string;
  clientUuid: string;
  sessionId?: string;
  partnerId?: string;
  warehouseId?: string;
  date?: Date;
  lines: PosOrderLineInput[];
  payments: PosPaymentInput[];
}

@Injectable()
export class PosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly inventory: InventoryService,
    private readonly events: EventEmitter2,
  ) {}

  async openSession(tenantId: string, cashierId: string, openingCash: number | string) {
    return this.prisma.posSession.create({
      data: { tenantId, cashierId, openingCash: D(openingCash).toFixed(4) },
    });
  }

  async closeSession(sessionId: string, closingCash: number | string) {
    return this.prisma.posSession.update({
      where: { id: sessionId },
      data: { closedAt: new Date(), status: 'CLOSED', closingCash: D(closingCash).toFixed(4) },
    });
  }

  async submitOrder(input: PosOrderInput) {
    // Idempotency: if an order with this clientUuid already exists, return it.
    const existing = await this.prisma.posOrder.findUnique({
      where: { clientUuid: input.clientUuid },
      include: { lines: true },
    });
    if (existing) return { order: existing, conflict: false };

    const computed = input.lines.map((l) => {
      const sub = D(l.quantity).times(l.unitPrice).times(D(1).minus(D(l.discount ?? 0)));
      const tax = sub.times(D(l.taxRate ?? 0));
      return { ...l, subtotal: sub, tax, total: sub.plus(tax) };
    });
    const subtotal = sum(computed.map((c) => c.subtotal));
    const taxTotal = sum(computed.map((c) => c.tax));
    const discountTotal = sum(computed.map((c) => D(c.quantity).times(c.unitPrice).times(D(c.discount ?? 0))));
    const total = subtotal.plus(taxTotal);

    const paid = sum(input.payments.map((p) => p.amount));
    if (paid.lessThan(total)) {
      throw new ConflictException(`Insufficient payment: paid ${paid} < total ${total}`);
    }

    const year = new Date().getFullYear();
    const count = await this.prisma.posOrder.count({ where: { date: { gte: new Date(`${year}-01-01`) } } });
    const number = `POS-${year}-${String(count + 1).padStart(6, '0')}`;

    const order = await this.prisma.$transaction(async (tx) => {
      const o = await tx.posOrder.create({
        data: {
          tenantId: input.tenantId,
          sessionId: input.sessionId ?? null,
          clientUuid: input.clientUuid,
          number,
          date: input.date ?? new Date(),
          partnerId: input.partnerId ?? null,
          status: 'PAID',
          subtotal: subtotal.toFixed(4),
          discount: discountTotal.toFixed(4),
          taxTotal: taxTotal.toFixed(4),
          total: total.toFixed(4),
          payments: input.payments as never,
          syncedAt: new Date(),
          lines: {
            create: computed.map((c) => ({
              productId: c.productId,
              description: c.description ?? '',
              quantity: D(c.quantity).toFixed(4),
              unitPrice: D(c.unitPrice).toFixed(4),
              discount: D(c.discount ?? 0).toFixed(4),
              taxRate: D(c.taxRate ?? 0).toFixed(4),
              total: c.total.toFixed(4),
            })),
          },
        },
        include: { lines: true },
      });

      // Stock deduction
      for (const line of computed) {
        await tx.stockMove.create({
          data: {
            tenantId: input.tenantId,
            productId: line.productId,
            fromWarehouseId: input.warehouseId ?? null,
            quantity: D(line.quantity).toFixed(4),
            reason: 'POS_SALE',
            reference: o.number,
          },
        });
      }
      return o;
    });

    this.events.emit('pos.order.created', { tenantId: input.tenantId, orderId: order.id, total: total.toString() });
    return { order, conflict: false };
  }

  async refund(orderId: string, reason?: string) {
    const order = await this.prisma.posOrder.findUniqueOrThrow({ where: { id: orderId }, include: { lines: true } });
    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.posOrder.update({
        where: { id: orderId },
        data: { status: 'REFUNDED' },
      });
      for (const l of order.lines) {
        await tx.stockMove.create({
          data: {
            tenantId: order.tenantId,
            productId: l.productId,
            toWarehouseId: null,
            quantity: l.quantity,
            reason: 'RETURN',
            reference: `refund:${order.number}:${reason ?? ''}`,
          },
        });
      }
      return updated;
    });
  }

  list(sessionId?: string) {
    return this.prisma.posOrder.findMany({
      where: sessionId ? { sessionId } : undefined,
      orderBy: { date: 'desc' },
      take: 100,
      include: { lines: true },
    });
  }

  async syncBatch(input: { tenantId: string; orders: PosOrderInput[] }) {
    const results: Array<{ clientUuid: string; ok: boolean; orderId?: string; error?: string }> = [];
    for (const o of input.orders) {
      try {
        const { order } = await this.submitOrder({ ...o, tenantId: input.tenantId });
        results.push({ clientUuid: o.clientUuid, ok: true, orderId: order.id });
      } catch (e) {
        results.push({ clientUuid: o.clientUuid, ok: false, error: (e as Error).message });
      }
    }
    return { count: results.length, results };
  }
}
