import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PosOrderInput, PosService } from './pos.service';

@ApiTags('pos')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'pos', version: '1' })
export class PosController {
  constructor(private readonly pos: PosService) {}

  @Post('sessions/open')
  @RequirePermissions('pos.create')
  open(@Body() body: { openingCash: number }, @CurrentUser() u: JwtPayload) {
    return this.pos.openSession(u.tenantId!, u.sub, body.openingCash);
  }

  @Post('sessions/:id/close')
  @RequirePermissions('pos.update')
  close(@Param('id') id: string, @Body() body: { closingCash: number }) {
    return this.pos.closeSession(id, body.closingCash);
  }

  @Post('orders')
  @RequirePermissions('pos.create')
  submit(@Body() body: Omit<PosOrderInput, 'tenantId'>, @CurrentUser() u: JwtPayload) {
    return this.pos.submitOrder({ ...body, tenantId: u.tenantId! });
  }

  @Post('orders/:id/refund')
  @RequirePermissions('pos.update')
  refund(@Param('id') id: string, @Body() body: { reason?: string }) {
    return this.pos.refund(id, body.reason);
  }

  @Get('orders')
  @RequirePermissions('pos.read')
  list(@Query('session') sessionId?: string) {
    return this.pos.list(sessionId);
  }

  @Post('sync')
  @RequirePermissions('pos.create')
  sync(@Body() body: { orders: PosOrderInput[] }, @CurrentUser() u: JwtPayload) {
    return this.pos.syncBatch({ tenantId: u.tenantId!, orders: body.orders });
  }
}
