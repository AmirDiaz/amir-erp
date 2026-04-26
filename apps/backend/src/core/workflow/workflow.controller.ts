import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { PrismaService } from '../prisma/prisma.service';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('workflows')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'workflows', version: '1' })
export class WorkflowController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('workflows.read')
  list() { return this.prisma.workflow.findMany({ orderBy: { createdAt: 'desc' } }); }

  @Get(':id')
  @RequirePermissions('workflows.read')
  get(@Param('id') id: string) { return this.prisma.workflow.findUnique({ where: { id } }); }

  @Post()
  @RequirePermissions('workflows.create')
  create(@Body() body: Record<string, unknown>, @CurrentUser() user: JwtPayload) {
    return this.prisma.workflow.create({
      data: {
        tenantId: user.tenantId!,
        name: String(body.name ?? 'Untitled'),
        trigger: String(body.trigger ?? ''),
        conditions: (body.conditions as never) ?? ({} as never),
        actions: (body.actions as never) ?? ([] as never),
        isActive: Boolean(body.isActive ?? true),
      },
    });
  }

  @Put(':id')
  @RequirePermissions('workflows.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.workflow.update({
      where: { id },
      data: {
        name: body.name as string,
        trigger: body.trigger as string,
        conditions: body.conditions as never,
        actions: body.actions as never,
        isActive: body.isActive as boolean,
      },
    });
  }

  @Delete(':id')
  @RequirePermissions('workflows.delete')
  remove(@Param('id') id: string) { return this.prisma.workflow.delete({ where: { id } }); }
}
