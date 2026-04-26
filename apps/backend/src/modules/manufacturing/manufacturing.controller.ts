import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { MoStatus } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('manufacturing')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'manufacturing', version: '1' })
export class ManufacturingController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('orders')
  @RequirePermissions('manufacturing.read')
  listOrders() { return this.prisma.manufacturingOrder.findMany({ orderBy: { createdAt: 'desc' } }); }

  @Post('orders')
  @RequirePermissions('manufacturing.create')
  async createOrder(@Body() body: { productId: string; quantity: number; bomId?: string }, @CurrentUser() u: JwtPayload) {
    const year = new Date().getFullYear();
    const n = await this.prisma.manufacturingOrder.count();
    return this.prisma.manufacturingOrder.create({
      data: { ...body, tenantId: u.tenantId!, number: `MO-${year}-${String(n + 1).padStart(5, '0')}` },
    });
  }

  @Patch('orders/:id/status')
  @RequirePermissions('manufacturing.update')
  setStatus(@Param('id') id: string, @Body() body: { status: MoStatus }) {
    return this.prisma.manufacturingOrder.update({ where: { id }, data: { status: body.status } });
  }

  @Get('boms')
  @RequirePermissions('manufacturing.read')
  listBoms() { return this.prisma.bom.findMany({ include: { lines: true } }); }

  @Post('boms')
  @RequirePermissions('manufacturing.create')
  createBom(@Body() body: { productId: string; name: string; output?: number; lines: { componentProductId: string; quantity: number }[] }, @CurrentUser() u: JwtPayload) {
    return this.prisma.bom.create({
      data: {
        tenantId: u.tenantId!, productId: body.productId, name: body.name, output: body.output ?? 1,
        lines: { create: body.lines.map((l) => ({ productId: body.productId, componentProductId: l.componentProductId, quantity: l.quantity })) },
      },
      include: { lines: true },
    });
  }

  @Delete('boms/:id')
  @RequirePermissions('manufacturing.delete')
  removeBom(@Param('id') id: string) { return this.prisma.bom.delete({ where: { id } }); }
}
