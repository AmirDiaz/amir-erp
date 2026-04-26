import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { InvoiceStatus, InvoiceType } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { InvoicingService, CreateInvoiceInput } from './invoicing.service';

@ApiTags('invoices')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'invoices', version: '1' })
export class InvoicingController {
  constructor(private readonly svc: InvoicingService) {}

  @Get()
  @RequirePermissions('invoicing.read')
  list(@Query('status') status?: InvoiceStatus, @Query('type') type?: InvoiceType) {
    return this.svc.list({ ...(status ? { status } : {}), ...(type ? { type } : {}) });
  }

  @Get(':id')
  @RequirePermissions('invoicing.read')
  get(@Param('id') id: string) { return this.svc.get(id); }

  @Post()
  @RequirePermissions('invoicing.create')
  create(@Body() body: Omit<CreateInvoiceInput, 'tenantId'>, @CurrentUser() u: JwtPayload) {
    return this.svc.create({ ...body, tenantId: u.tenantId! });
  }

  @Post(':id/post')
  @RequirePermissions('invoicing.update')
  postToLedger(
    @Param('id') id: string,
    @Body() body: { revenueAccountId: string; receivableAccountId: string; taxAccountId?: string },
  ) {
    return this.svc.confirmAndPost(id, body);
  }
}
