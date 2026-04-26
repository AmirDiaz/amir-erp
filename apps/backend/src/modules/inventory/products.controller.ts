import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { PageQueryDto, offset } from '../../common/utils/pagination';

@ApiTags('products')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'inventory/products', version: '1' })
export class ProductsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('inventory.read')
  async list(@Query() q: PageQueryDto) {
    const where = q.q ? {
      OR: [
        { name: { contains: q.q, mode: 'insensitive' as const } },
        { sku: { contains: q.q, mode: 'insensitive' as const } },
        { barcode: { contains: q.q } },
      ],
    } : {};
    const [items, total] = await Promise.all([
      this.prisma.product.findMany({ where, ...offset(q), orderBy: { createdAt: 'desc' } }),
      this.prisma.product.count({ where }),
    ]);
    return { items, page: q.page, pageSize: q.pageSize, total };
  }

  @Get('barcode/:barcode')
  @RequirePermissions('inventory.read')
  byBarcode(@Param('barcode') barcode: string) {
    return this.prisma.product.findFirst({ where: { barcode, isActive: true } });
  }

  @Get(':id')
  @RequirePermissions('inventory.read')
  get(@Param('id') id: string) { return this.prisma.product.findUnique({ where: { id } }); }

  @Post()
  @RequirePermissions('inventory.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.product.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('inventory.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.product.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('inventory.delete')
  remove(@Param('id') id: string) { return this.prisma.product.delete({ where: { id } }); }
}
