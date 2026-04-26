/**
 * Amir ERP — invoicing service.
 *
 * Computes line and document totals, persists the invoice, and posts a
 * matching double-entry journal entry to the GL on confirmation.
 *
 * Author: Amir Saoudi.
 */
import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, InvoiceType } from '@prisma/client';
import { PrismaService } from '../../core/prisma/prisma.service';
import { PostingService } from '../accounting/posting.service';
import { D, round, sum } from '../../common/utils/decimal';
import { EventEmitter2 } from '@nestjs/event-emitter';

export interface InvoiceLineInput {
  productId?: string;
  description: string;
  quantity: number | string;
  unitPrice: number | string;
  discount?: number | string;
  taxRate?: number | string;
}

export interface CreateInvoiceInput {
  tenantId: string;
  partnerId: string;
  type?: InvoiceType;
  date?: Date;
  dueDate?: Date | null;
  currency?: string;
  notes?: string;
  lines: InvoiceLineInput[];
}

@Injectable()
export class InvoicingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly posting: PostingService,
    private readonly events: EventEmitter2,
  ) {}

  static computeTotals(lines: InvoiceLineInput[]) {
    const computed = lines.map((l) => {
      const lineSubtotal = D(l.quantity).times(l.unitPrice).times(D(1).minus(D(l.discount ?? 0)));
      const lineTax = lineSubtotal.times(D(l.taxRate ?? 0));
      const total = lineSubtotal.plus(lineTax);
      return { ...l, lineSubtotal, lineTax, total };
    });
    const subtotal = sum(computed.map((c) => c.lineSubtotal));
    const taxTotal = sum(computed.map((c) => c.lineTax));
    const total = subtotal.plus(taxTotal);
    return { computed, subtotal, taxTotal, total };
  }

  async nextNumber(tenantId: string, type: InvoiceType): Promise<string> {
    const prefix = type === 'PURCHASE' ? 'BIL' : type === 'CREDIT_NOTE' ? 'CRN' : 'INV';
    const year = new Date().getFullYear();
    const count = await this.prisma.unscoped((db) =>
      db.invoice.count({ where: { tenantId, type, date: { gte: new Date(`${year}-01-01`) } } }),
    );
    return `${prefix}-${year}-${String(count + 1).padStart(5, '0')}`;
  }

  async create(input: CreateInvoiceInput) {
    const { computed, subtotal, taxTotal, total } = InvoicingService.computeTotals(input.lines);
    const number = await this.nextNumber(input.tenantId, input.type ?? 'SALE');

    const inv = await this.prisma.invoice.create({
      data: {
        tenantId: input.tenantId,
        partnerId: input.partnerId,
        number,
        type: input.type ?? 'SALE',
        status: 'OPEN',
        date: input.date ?? new Date(),
        dueDate: input.dueDate ?? null,
        currency: input.currency ?? 'USD',
        subtotal: subtotal.toFixed(4),
        taxTotal: taxTotal.toFixed(4),
        total: total.toFixed(4),
        notes: input.notes ?? null,
        lines: {
          create: computed.map((c) => ({
            productId: c.productId ?? null,
            description: c.description,
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

    this.events.emit('invoice.created', { tenantId: input.tenantId, invoiceId: inv.id, total: total.toString() });
    return inv;
  }

  async confirmAndPost(invoiceId: string, accounts: { revenueAccountId: string; receivableAccountId: string; taxAccountId?: string }) {
    const inv = await this.prisma.invoice.findUnique({ where: { id: invoiceId } });
    if (!inv) throw new NotFoundException();

    await this.posting.post({
      tenantId: inv.tenantId,
      date: inv.date,
      reference: inv.number,
      memo: `Invoice ${inv.number}`,
      sourceType: 'invoice',
      sourceId: inv.id,
      lines: [
        // DR accounts receivable, CR revenue + CR tax
        { debitAccountId: accounts.receivableAccountId, amount: inv.total.toString(), currency: inv.currency },
        { creditAccountId: accounts.revenueAccountId, amount: inv.subtotal.toString(), currency: inv.currency },
        ...(D(inv.taxTotal).gt(0) && accounts.taxAccountId
          ? [{ creditAccountId: accounts.taxAccountId, amount: inv.taxTotal.toString(), currency: inv.currency }]
          : []),
      ],
    });

    return inv;
  }

  list(where: Prisma.InvoiceWhereInput = {}, take = 100) {
    return this.prisma.invoice.findMany({
      where,
      orderBy: { date: 'desc' },
      take,
      include: { partner: true },
    });
  }

  get(id: string) {
    return this.prisma.invoice.findUnique({
      where: { id },
      include: { lines: true, partner: true, payments: { include: { payment: true } } },
    });
  }

  static async recomputeStatus(prisma: PrismaService, invoiceId: string) {
    const inv = await prisma.invoice.findUnique({ where: { id: invoiceId } });
    if (!inv) return null;
    const paid = D(inv.amountPaid);
    const total = D(inv.total);
    const status =
      paid.gte(total) && total.gt(0) ? 'PAID' :
      paid.gt(0) ? 'PARTIAL' :
      inv.dueDate && inv.dueDate < new Date() ? 'OVERDUE' :
      'OPEN';
    if (status !== inv.status) {
      await prisma.invoice.update({ where: { id: invoiceId }, data: { status } });
    }
    return status;
  }

  static formatTotal(amount: string | number, currency: string): string {
    return `${round(Number(amount)).toString()} ${currency}`;
  }
}
