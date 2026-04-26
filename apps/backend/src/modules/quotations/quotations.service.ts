import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D, sum } from '../../common/utils/decimal';

export interface QuotationLineInput {
  description: string;
  quantity: number | string;
  unitPrice: number | string;
  discount?: number | string;
  taxRate?: number | string;
}

@Injectable()
export class QuotationsService {
  constructor(private readonly prisma: PrismaService) {}

  list() { return this.prisma.quotation.findMany({ orderBy: { date: 'desc' }, take: 100, include: { partner: true } }); }
  get(id: string) { return this.prisma.quotation.findUnique({ where: { id }, include: { lines: true, partner: true } }); }

  async create(input: { tenantId: string; partnerId: string; date?: Date; validUntil?: Date | null; currency?: string; notes?: string; lines: QuotationLineInput[] }) {
    const computed = input.lines.map((l) => {
      const sub = D(l.quantity).times(l.unitPrice).times(D(1).minus(D(l.discount ?? 0)));
      const tax = sub.times(D(l.taxRate ?? 0));
      return { ...l, total: sub.plus(tax) };
    });
    const subtotal = sum(computed.map((c) => D(c.quantity).times(c.unitPrice).times(D(1).minus(D(c.discount ?? 0)))));
    const taxTotal = sum(computed.map((c) => D(c.quantity).times(c.unitPrice).times(D(1).minus(D(c.discount ?? 0))).times(D(c.taxRate ?? 0))));
    const total = subtotal.plus(taxTotal);

    const year = new Date().getFullYear();
    const count = await this.prisma.quotation.count({ where: { date: { gte: new Date(`${year}-01-01`) } } });
    const number = `QT-${year}-${String(count + 1).padStart(5, '0')}`;

    return this.prisma.quotation.create({
      data: {
        tenantId: input.tenantId,
        partnerId: input.partnerId,
        number,
        date: input.date ?? new Date(),
        validUntil: input.validUntil ?? null,
        currency: input.currency ?? 'USD',
        notes: input.notes ?? null,
        subtotal: subtotal.toFixed(4),
        taxTotal: taxTotal.toFixed(4),
        total: total.toFixed(4),
        lines: {
          create: computed.map((c) => ({
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
  }
}
