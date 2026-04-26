import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { TaskStatus } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('tasks')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'projects/tasks', version: '1' })
export class TasksController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('projects.read')
  list(@Query('project') projectId?: string, @Query('status') status?: TaskStatus) {
    return this.prisma.task.findMany({
      where: { ...(projectId ? { projectId } : {}), ...(status ? { status } : {}) },
      orderBy: [{ priority: 'desc' }, { createdAt: 'desc' }],
    });
  }

  @Post()
  @RequirePermissions('projects.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() u: JwtPayload) {
    return this.prisma.task.create({ data: { ...(body as Record<string, unknown>), tenantId: u.tenantId! } as any });
  }

  @Patch(':id')
  @RequirePermissions('projects.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.prisma.task.update({ where: { id }, data: body as Record<string, unknown> }); }

  @Delete(':id')
  @RequirePermissions('projects.delete')
  remove(@Param('id') id: string) { return this.prisma.task.delete({ where: { id } }); }
}
