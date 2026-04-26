import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/prisma/prisma.service';
import { D } from '../../common/utils/decimal';

@Injectable()
export class PayrollService {
  constructor(private readonly prisma: PrismaService) {}

  list() { return this.prisma.payslip.findMany({ orderBy: { period: 'desc' }, include: { employee: true } }); }

  async generate(input: { tenantId: string; period: string; deductionsRate?: number }) {
    const employees = await this.prisma.employee.findMany({ where: { status: 'ACTIVE' } });
    const created = [];
    for (const emp of employees) {
      const gross = D(emp.salary);
      const deductions = gross.times(input.deductionsRate ?? 0.1);
      const net = gross.minus(deductions);
      const slip = await this.prisma.payslip.create({
        data: {
          tenantId: input.tenantId, employeeId: emp.id, period: input.period,
          gross: gross.toFixed(4), deductions: deductions.toFixed(4), net: net.toFixed(4),
          currency: emp.currency, status: 'DRAFT',
        },
      });
      created.push(slip);
    }
    return { count: created.length, slips: created };
  }

  approve(id: string) { return this.prisma.payslip.update({ where: { id }, data: { status: 'APPROVED' } }); }
  pay(id: string) { return this.prisma.payslip.update({ where: { id }, data: { status: 'PAID' } }); }
}
