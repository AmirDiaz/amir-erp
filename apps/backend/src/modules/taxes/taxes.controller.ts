import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('taxes')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'taxes', version: '1' })
export class TaxesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('taxes.read')
  list() { return this.prisma.tax.findMany({ orderBy: { name: 'asc' } }); }

  @Post()
  @RequirePermissions('taxes.create')
  create(@Body() body: { name: string; rate: number; type?: 'PERCENT' | 'FIXED'; isInclusive?: boolean }, @CurrentUser() u: JwtPayload) {
    return this.prisma.tax.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('taxes.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.tax.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('taxes.delete')
  remove(@Param('id') id: string) { return this.prisma.tax.delete({ where: { id } }); }
}
