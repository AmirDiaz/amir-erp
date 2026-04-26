import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { APP_AUTHOR, APP_NAME, APP_VERSION } from '../../common/branding';

@ApiTags('health')
@Controller({ path: 'health', version: VERSION_NEUTRAL })
export class HealthController {
  constructor(private readonly prisma: PrismaService, private readonly redis: RedisService) {}

  @Public()
  @Get()
  async health() {
    const checks = await Promise.allSettled([
      this.prisma.$queryRaw`SELECT 1`,
      this.redis.client.ping(),
    ]);
    const [db, cache] = checks;
    return {
      status: checks.every((c) => c.status === 'fulfilled') ? 'ok' : 'degraded',
      service: APP_NAME,
      version: APP_VERSION,
      author: APP_AUTHOR,
      checks: {
        db: db.status,
        redis: cache.status,
      },
      timestamp: new Date().toISOString(),
    };
  }
}
