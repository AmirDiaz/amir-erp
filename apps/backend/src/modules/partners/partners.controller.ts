import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { PartnerType } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { PageQueryDto, offset } from '../../common/utils/pagination';

@ApiTags('partners')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'partners', version: '1' })
export class PartnersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('partners.read')
  async list(@Query() q: PageQueryDto, @Query('type') type?: PartnerType) {
    const where = {
      ...(type ? { type } : {}),
      ...(q.q ? { OR: [
        { name: { contains: q.q, mode: 'insensitive' as const } },
        { email: { contains: q.q, mode: 'insensitive' as const } },
        { phone: { contains: q.q } },
      ] } : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.partner.findMany({ where, ...offset(q), orderBy: { createdAt: 'desc' } }),
      this.prisma.partner.count({ where }),
    ]);
    return { items, page: q.page, pageSize: q.pageSize, total };
  }

  @Get(':id')
  @RequirePermissions('partners.read')
  get(@Param('id') id: string) { return this.prisma.partner.findUnique({ where: { id } }); }

  @Post()
  @RequirePermissions('partners.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.partner.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('partners.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.partner.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('partners.delete')
  remove(@Param('id') id: string) { return this.prisma.partner.delete({ where: { id } }); }
}
