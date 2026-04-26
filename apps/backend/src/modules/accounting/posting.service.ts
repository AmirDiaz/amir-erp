/**
 * Amir ERP — double-entry posting service.
 *
 * Validates that total debits equal total credits, then atomically inserts
 * a `JournalEntry` and its `JournalLine` rows. Used directly by manual
 * journal endpoints and indirectly by invoicing/payment/POS modules to
 * generate accounting entries.
 *
 * Author: Amir Saoudi.
 */
import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D, sum } from '../../common/utils/decimal';

export interface PostingLine {
  debitAccountId?: string;
  creditAccountId?: string;
  amount: number | string;
  currency?: string;
  memo?: string;
}

export interface PostingInput {
  tenantId: string;
  date: Date;
  reference?: string;
  memo?: string;
  sourceType?: string;
  sourceId?: string;
  lines: PostingLine[];
}

@Injectable()
export class PostingService {
  constructor(private readonly prisma: PrismaService) {}

  async post(input: PostingInput) {
    const debits = sum(input.lines.filter((l) => l.debitAccountId).map((l) => l.amount));
    const credits = sum(input.lines.filter((l) => l.creditAccountId).map((l) => l.amount));
    if (!debits.eq(credits)) {
      throw new BadRequestException(
        `Unbalanced entry: debits ${debits.toString()} vs credits ${credits.toString()}`,
      );
    }
    if (debits.lte(0)) {
      throw new BadRequestException('Posting amount must be > 0');
    }

    return this.prisma.unscoped((db) =>
      db.journalEntry.create({
        data: {
          tenantId: input.tenantId,
          date: input.date,
          reference: input.reference,
          memo: input.memo,
          status: 'POSTED',
          sourceType: input.sourceType,
          sourceId: input.sourceId,
          lines: {
            create: input.lines.map((l) => ({
              debitAccountId: l.debitAccountId ?? null,
              creditAccountId: l.creditAccountId ?? null,
              amount: D(l.amount).toFixed(4),
              currency: l.currency ?? 'USD',
              memo: l.memo ?? null,
            })),
          },
        },
        include: { lines: true },
      }),
    );
  }

  async reverse(journalEntryId: string) {
    const original = await this.prisma.journalEntry.findUniqueOrThrow({
      where: { id: journalEntryId },
      include: { lines: true },
    });
    return this.prisma.unscoped((db) =>
      db.journalEntry.create({
        data: {
          tenantId: original.tenantId,
          date: new Date(),
          reference: `REV-${original.reference ?? original.id.slice(0, 8)}`,
          memo: `Reversal of ${original.id}`,
          status: 'POSTED',
          sourceType: 'reversal',
          sourceId: original.id,
          lines: {
            create: original.lines.map((l) => ({
              // swap debit ↔ credit
              debitAccountId: l.creditAccountId,
              creditAccountId: l.debitAccountId,
              amount: l.amount,
              currency: l.currency,
              memo: `reversal: ${l.memo ?? ''}`,
            })),
          },
        },
        include: { lines: true },
      }),
    );
  }
}
