import { Body, Controller, Get, Param, Post, Query, UseGuards, BadRequestException } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../core/auth/guards/jwt-auth.guard';
import { RequirePermissions } from '../../core/auth/decorators/permissions.decorator';
import { CurrentUser } from '../../core/auth/decorators/current-user.decorator';
import { JwtPayload } from '../../core/auth/auth.service';
import { PrismaService } from '../../core/prisma/prisma.service';
import { PostingService, PostingLine } from './posting.service';

@ApiTags('journal-entries')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'accounting/journal-entries', version: '1' })
export class JournalsController {
  constructor(private readonly prisma: PrismaService, private readonly posting: PostingService) {}

  @Get()
  @RequirePermissions('accounting.read')
  list(@Query('from') from?: string, @Query('to') to?: string) {
    return this.prisma.journalEntry.findMany({
      where: {
        ...(from && to ? { date: { gte: new Date(from), lte: new Date(to) } } : {}),
      },
      include: { lines: { include: { debitAccount: true, creditAccount: true } } },
      orderBy: { date: 'desc' },
      take: 200,
    });
  }

  @Get(':id')
  @RequirePermissions('accounting.read')
  get(@Param('id') id: string) {
    return this.prisma.journalEntry.findUnique({
      where: { id },
      include: { lines: { include: { debitAccount: true, creditAccount: true } } },
    });
  }

  @Post()
  @RequirePermissions('accounting.create')
  async create(
    @Body() body: { date: string; reference?: string; memo?: string; lines: PostingLine[] },
    @CurrentUser() u: JwtPayload,
  ) {
    if (!body.lines || body.lines.length < 2) {
      throw new BadRequestException('Journal entry requires at least 2 lines');
    }
    return this.posting.post({
      tenantId: u.tenantId!,
      date: new Date(body.date),
      reference: body.reference,
      memo: body.memo,
      sourceType: 'manual',
      lines: body.lines,
    });
  }
}
