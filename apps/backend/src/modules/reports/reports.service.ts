/**
 * Amir ERP — financial reports (P&L, Balance Sheet, Trial Balance, Cash Flow).
 * Author: Amir Saoudi.
 */
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D, sum } from '../../common/utils/decimal';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async trialBalance(tenantId: string, asOf: Date = new Date()) {
    const accounts = await this.prisma.unscoped((db) =>
      db.account.findMany({ where: { tenantId } }),
    );
    const lines = await this.prisma.unscoped((db) =>
      db.journalLine.findMany({
        where: {
          journalEntry: { tenantId, date: { lte: asOf }, status: 'POSTED' },
        },
      }),
    );
    return accounts.map((a) => {
      const debits = sum(
        lines.filter((l) => l.debitAccountId === a.id).map((l) => l.amount.toString()),
      );
      const credits = sum(
        lines.filter((l) => l.creditAccountId === a.id).map((l) => l.amount.toString()),
      );
      const balance = debits.minus(credits);
      const normalDebit = a.type === 'ASSET' || a.type === 'EXPENSE';
      return {
        accountId: a.id,
        code: a.code,
        name: a.name,
        type: a.type,
        debit: debits.toString(),
        credit: credits.toString(),
        balance: (normalDebit ? balance : balance.negated()).toString(),
      };
    });
  }

  async profitAndLoss(tenantId: string, from: Date, to: Date) {
    const tb = await this.trialBalance(tenantId, to);
    const income = tb.filter((r) => r.type === 'INCOME');
    const expenses = tb.filter((r) => r.type === 'EXPENSE');
    const totalIncome = sum(income.map((r) => r.balance));
    const totalExpense = sum(expenses.map((r) => r.balance));
    return {
      from, to,
      income, expenses,
      totalIncome: totalIncome.toString(),
      totalExpense: totalExpense.toString(),
      netIncome: totalIncome.minus(totalExpense).toString(),
    };
  }

  async balanceSheet(tenantId: string, asOf: Date = new Date()) {
    const tb = await this.trialBalance(tenantId, asOf);
    const assets = tb.filter((r) => r.type === 'ASSET');
    const liabilities = tb.filter((r) => r.type === 'LIABILITY');
    const equity = tb.filter((r) => r.type === 'EQUITY');
    const totalAssets = sum(assets.map((r) => r.balance));
    const totalLiabilities = sum(liabilities.map((r) => r.balance));
    const totalEquity = sum(equity.map((r) => r.balance));
    return {
      asOf,
      assets, liabilities, equity,
      totalAssets: totalAssets.toString(),
      totalLiabilities: totalLiabilities.toString(),
      totalEquity: totalEquity.toString(),
      check: totalAssets.minus(totalLiabilities.plus(totalEquity)).toString(),
    };
  }

  async cashFlowSummary(tenantId: string, from: Date, to: Date) {
    const payments = await this.prisma.unscoped((db) =>
      db.payment.findMany({ where: { tenantId, date: { gte: from, lte: to } } }),
    );
    const cashIn = sum(payments.filter((p) => p.method !== 'CHECK' || true).map((p) => p.amount.toString()));
    return { from, to, cashIn: cashIn.toString(), count: payments.length };
  }
}
