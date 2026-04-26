import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { ReportsService } from './reports.service';

@ApiTags('reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'reports', version: '1' })
export class ReportsController {
  constructor(private readonly svc: ReportsService) {}

  @Get('trial-balance')
  @RequirePermissions('reports.read')
  trial(@CurrentUser() u: JwtPayload, @Query('asOf') asOf?: string) {
    return this.svc.trialBalance(u.tenantId!, asOf ? new Date(asOf) : new Date());
  }

  @Get('profit-and-loss')
  @RequirePermissions('reports.read')
  pl(@CurrentUser() u: JwtPayload, @Query('from') from: string, @Query('to') to: string) {
    return this.svc.profitAndLoss(u.tenantId!, new Date(from), new Date(to));
  }

  @Get('balance-sheet')
  @RequirePermissions('reports.read')
  bs(@CurrentUser() u: JwtPayload, @Query('asOf') asOf?: string) {
    return this.svc.balanceSheet(u.tenantId!, asOf ? new Date(asOf) : new Date());
  }

  @Get('cash-flow')
  @RequirePermissions('reports.read')
  cf(@CurrentUser() u: JwtPayload, @Query('from') from: string, @Query('to') to: string) {
    return this.svc.cashFlowSummary(u.tenantId!, new Date(from), new Date(to));
  }
}
