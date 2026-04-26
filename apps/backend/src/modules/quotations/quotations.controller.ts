import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { QuotationsService, QuotationLineInput } from './quotations.service';

@ApiTags('quotations')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'quotations', version: '1' })
export class QuotationsController {
  constructor(private readonly svc: QuotationsService) {}

  @Get()
  @RequirePermissions('quotations.read')
  list() { return this.svc.list(); }

  @Get(':id')
  @RequirePermissions('quotations.read')
  get(@Param('id') id: string) { return this.svc.get(id); }

  @Post()
  @RequirePermissions('quotations.create')
  create(@Body() body: { partnerId: string; date?: string; validUntil?: string | null; currency?: string; notes?: string; lines: QuotationLineInput[] }, @CurrentUser() u: JwtPayload) {
    return this.svc.create({
      tenantId: u.tenantId!,
      partnerId: body.partnerId,
      date: body.date ? new Date(body.date) : undefined,
      validUntil: body.validUntil ? new Date(body.validUntil) : null,
      currency: body.currency,
      notes: body.notes,
      lines: body.lines,
    });
  }
}
