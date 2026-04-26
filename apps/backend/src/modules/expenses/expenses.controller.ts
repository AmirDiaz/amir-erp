import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ExpenseStatus } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('expenses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'expenses', version: '1' })
export class ExpensesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('expenses.read')
  list() { return this.prisma.expense.findMany({ orderBy: { date: 'desc' }, include: { employee: true } }); }

  @Post()
  @RequirePermissions('expenses.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.expense.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id/status')
  @RequirePermissions('expenses.update')
  status(@Param('id') id: string, @Body() body: { status: ExpenseStatus }) {
    return this.prisma.expense.update({ where: { id }, data: { status: body.status } });
  }

  @Delete(':id')
  @RequirePermissions('expenses.delete')
  remove(@Param('id') id: string) { return this.prisma.expense.delete({ where: { id } }); }
}
