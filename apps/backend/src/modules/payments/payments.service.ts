import { Injectable } from '@nestjs/common';
import { PaymentMethod } from '@prisma/client';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D } from '../../common/utils/decimal';
import { InvoicingService } from '../invoicing/invoicing.service';

export interface PaymentInput {
  tenantId: string;
  partnerId: string;
  method: PaymentMethod;
  amount: number | string;
  currency?: string;
  reference?: string;
  notes?: string;
  allocations?: { invoiceId: string; amount: number | string }[];
}

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    return this.prisma.payment.findMany({ orderBy: { date: 'desc' }, take: 200, include: { partner: true } });
  }

  async create(input: PaymentInput) {
    return this.prisma.$transaction(async (tx) => {
      const payment = await tx.payment.create({
        data: {
          tenantId: input.tenantId,
          partnerId: input.partnerId,
          method: input.method,
          amount: D(input.amount).toFixed(4),
          currency: input.currency ?? 'USD',
          reference: input.reference ?? null,
          notes: input.notes ?? null,
        },
      });
      for (const a of input.allocations ?? []) {
        await tx.paymentAllocation.create({
          data: { paymentId: payment.id, invoiceId: a.invoiceId, amount: D(a.amount).toFixed(4) },
        });
        await tx.invoice.update({
          where: { id: a.invoiceId },
          data: { amountPaid: { increment: D(a.amount).toFixed(4) as never } },
        });
        await InvoicingService.recomputeStatus(this.prisma, a.invoiceId);
      }
      return payment;
    });
  }
}
