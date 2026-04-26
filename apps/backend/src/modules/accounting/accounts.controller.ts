import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AccountType } from '@prisma/client';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';

@ApiTags('accounts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'accounting/accounts', version: '1' })
export class AccountsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermissions('accounting.read')
  list(@Query('type') type?: AccountType) {
    return this.prisma.account.findMany({
      where: type ? { type } : undefined,
      orderBy: { code: 'asc' },
    });
  }

  @Get(':id')
  @RequirePermissions('accounting.read')
  get(@Param('id') id: string) { return this.prisma.account.findUnique({ where: { id } }); }

  @Post()
  @RequirePermissions('accounting.create')
  create(@Body() body: { code: string; name: string; type: AccountType; parentId?: string; currency?: string }, @CurrentUser() u: JwtPayload) {
    return this.prisma.account.create({ data: { ...body, tenantId: u.tenantId! } });
  }

  @Patch(':id')
  @RequirePermissions('accounting.update')
  update(@Param('id') id: string, @Body() body: Record<string, unknown>) {
    return this.prisma.account.update({ where: { id }, data: body as Record<string, unknown> });
  }

  @Delete(':id')
  @RequirePermissions('accounting.delete')
  remove(@Param('id') id: string) { return this.prisma.account.delete({ where: { id } }); }
}
