import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PaymentInput, PaymentsService } from './payments.service';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'payments', version: '1' })
export class PaymentsController {
  constructor(private readonly svc: PaymentsService) {}

  @Get()
  @RequirePermissions('payments.read')
  list() { return this.svc.list(); }

  @Post()
  @RequirePermissions('payments.create')
  create(@Body() body: Omit<PaymentInput, 'tenantId'>, @CurrentUser() u: JwtPayload) {
    return this.svc.create({ ...body, tenantId: u.tenantId! });
  }
}
