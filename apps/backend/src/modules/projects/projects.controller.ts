import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('projects')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'projects', version: '1' })
export class ProjectsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('projects.read')
  list() { return this.prisma.project.findMany({ orderBy: { createdAt: 'desc' }, include: { tasks: true } }); }

  @Get(':id')
  @RequirePermissions('projects.read')
  get(@Param('id') id: string) { return this.prisma.project.findUnique({ where: { id }, include: { tasks: true } }); }

  @Post()
  @RequirePermissions('projects.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.project.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('projects.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.prisma.project.update({ where: { id }, data: body as Record<string, unknown> }); }

  @Delete(':id')
  @RequirePermissions('projects.delete')
  remove(@Param('id') id: string) { return this.prisma.project.delete({ where: { id } }); }
}
