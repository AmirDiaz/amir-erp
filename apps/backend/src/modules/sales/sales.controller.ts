/**
 * Amir ERP — sales orders dashboard. Aggregates quotations + invoices
 * + leads pipeline metrics for tenant overview.
 *
 * Author: Amir Saoudi.
 */
import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { sum } from '../../common/utils/decimal';

@ApiTags('sales')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'sales', version: '1' })
export class SalesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('overview')
  @RequirePermissions('sales.read')
  async overview(@CurrentUser() u: JwtPayload, @Query('days') days = '30') {
    const since = new Date(Date.now() - Number(days) * 86400_000);
    const [invoices, quotations, leads, opps] = await Promise.all([
      this.prisma.invoice.findMany({ where: { type: 'SALE', date: { gte: since } } }),
      this.prisma.quotation.count({ where: { date: { gte: since } } }),
      this.prisma.lead.count({ where: { createdAt: { gte: since } } }),
      this.prisma.opportunity.findMany({ where: { createdAt: { gte: since } } }),
    ]);
    const revenue = sum(invoices.map((i) => i.total.toString())).toString();
    const pipeline = sum(opps.map((o) => o.amount.toString())).toString();
    return {
      tenantId: u.tenantId,
      since,
      invoiceCount: invoices.length,
      revenue,
      quotationCount: quotations,
      leadCount: leads,
      pipelineValue: pipeline,
    };
  }
}
