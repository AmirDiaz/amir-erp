import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PayrollService } from './payroll.service';

@ApiTags('payroll')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'payroll', version: '1' })
export class PayrollController {
  constructor(private readonly svc: PayrollService) {}

  @Get('payslips')
  @RequirePermissions('payroll.read')
  list() { return this.svc.list(); }

  @Post('generate')
  @RequirePermissions('payroll.create')
  generate(@Body() body: { period: string; deductionsRate?: number }, @CurrentUser() u: JwtPayload) {
    return this.svc.generate({ tenantId: u.tenantId!, period: body.period, deductionsRate: body.deductionsRate });
  }

  @Post('payslips/:id/approve')
  @RequirePermissions('payroll.update')
  approve(@Param('id') id: string) { return this.svc.approve(id); }

  @Post('payslips/:id/pay')
  @RequirePermissions('payroll.update')
  pay(@Param('id') id: string) { return this.svc.pay(id); }
}
