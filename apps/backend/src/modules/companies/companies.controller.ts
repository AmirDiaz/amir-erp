import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { PageQueryDto, offset } from '../../common/utils/pagination';

@ApiTags('companies')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'companies', version: '1' })
export class CompaniesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('companies.read')
  async list(@Query() q: PageQueryDto) {
    const where = q.q ? { name: { contains: q.q, mode: 'insensitive' as const } } : {};
    const [items, total] = await Promise.all([
      this.prisma.company.findMany({ where, ...offset(q), orderBy: { createdAt: 'desc' }, include: { branches: true } }),
      this.prisma.company.count({ where }),
    ]);
    return { items, page: q.page, pageSize: q.pageSize, total };
  }

  @Get(':id')
  @RequirePermissions('companies.read')
  get(@Param('id') id: string) { return this.prisma.company.findUnique({ where: { id }, include: { branches: true } }); }

  @Post()
  @RequirePermissions('companies.create')
  create(@Body() body: { name: string; legalName?: string; taxId?: string; currency?: string; country?: string; address?: string }, @CurrentUser() u: JwtPayload) {
    return this.prisma.company.create({ data: { ...body, tenantId: u.tenantId! } });
  }

  @Patch(':id')
  @RequirePermissions('companies.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.company.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('companies.delete')
  remove(@Param('id') id: string) { return this.prisma.company.delete({ where: { id } }); }
}
