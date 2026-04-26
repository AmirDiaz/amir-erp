import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('leaves')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'hr/leaves', version: '1' })
export class LeavesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('hr.read')
  list() { return this.prisma.leave.findMany({ orderBy: { startDate: 'desc' }, include: { employee: true } }); }

  @Post()
  @RequirePermissions('hr.create')
  create(@Body() body: { employeeId: string; type: string; startDate: string; endDate: string; reason?: string }) {
    return this.prisma.leave.create({ data: { ...body, startDate: new Date(body.startDate), endDate: new Date(body.endDate) } });
  }

  @Patch(':id')
  @RequirePermissions('hr.update')
  update(@Param('id') id: string, @Body() body: { status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED' }) {
    return this.prisma.leave.update({ where: { id }, data: { status: body.status } });
  }
}
