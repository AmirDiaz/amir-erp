/**
 * Amir ERP — supplier shortcut over the Partner table.
 * Author: Amir Saoudi.
 */
import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { PageQueryDto, offset } from '../../common/utils/pagination';

@ApiTags('suppliers')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'suppliers', version: '1' })
export class SuppliersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('partners.read')
  async list(@Query() q: PageQueryDto) {
    const where = { type: { in: ['SUPPLIER', 'BOTH'] } as never } as never;
    const [items, total] = await Promise.all([
      this.prisma.partner.findMany({ where, ...offset(q), orderBy: { createdAt: 'desc' } }),
      this.prisma.partner.count({ where }),
    ]);
    return { items, page: q.page, pageSize: q.pageSize, total };
  }

  @Post()
  @RequirePermissions('partners.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.partner.create({ data: { ...(body as Record<string, unknown>), type: 'SUPPLIER', tenantId: u.tenantId! } as any });
  }
}
