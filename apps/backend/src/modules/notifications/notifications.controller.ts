import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'notifications', version: '1' })
export class NotificationsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('notifications.read')
  list(@CurrentUser() u: JwtPayload) {
    return this.prisma.notification.findMany({
      where: { OR: [{ userId: u.sub }, { userId: null }] },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  @Post()
  @RequirePermissions('notifications.create')
  create(@Body() body: { userId?: string; type: string; title: string; body?: string; data?: Record<string, unknown> }, @CurrentUser() u: JwtPayload) {
    return this.prisma.notification.create({ data: { ...body, tenantId: u.tenantId!, data: (body.data ?? null) as never } });
  }

  @Patch(':id/read')
  @RequirePermissions('notifications.update')
  read(@Param('id') id: string) { return this.prisma.notification.update({ where: { id }, data: { readAt: new Date() } }); }
}
