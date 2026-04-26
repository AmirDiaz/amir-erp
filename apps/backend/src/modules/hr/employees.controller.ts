import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('employees')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'hr/employees', version: '1' })
export class EmployeesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('hr.read')
  list() { return this.prisma.employee.findMany({ orderBy: { fullName: 'asc' } }); }

  @Get(':id')
  @RequirePermissions('hr.read')
  get(@Param('id') id: string) { return this.prisma.employee.findUnique({ where: { id }, include: { leaves: true, payslips: true } }); }

  @Post()
  @RequirePermissions('hr.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.employee.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('hr.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.prisma.employee.update({ where: { id }, data: body as Record<string, unknown> }); }

  @Delete(':id')
  @RequirePermissions('hr.delete')
  remove(@Param('id') id: string) { return this.prisma.employee.delete({ where: { id } }); }
}
