import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('warehouses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'warehouses', version: '1' })
export class WarehousesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('warehouses.read')
  list() { return this.prisma.warehouse.findMany({ orderBy: { name: 'asc' } }); }

  @Post()
  @RequirePermissions('warehouses.create')
  create(@Body() body: { code: string; name: string; address?: string }, @CurrentUser() u: JwtPayload) {
    return this.prisma.warehouse.create({ data: { ...body, tenantId: u.tenantId! } });
  }

  @Patch(':id')
  @RequirePermissions('warehouses.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.warehouse.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('warehouses.delete')
  remove(@Param('id') id: string) { return this.prisma.warehouse.delete({ where: { id } }); }
}
