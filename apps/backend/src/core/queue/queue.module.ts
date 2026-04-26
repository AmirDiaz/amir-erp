/**
 * Amir ERP — BullMQ queue infrastructure.
 *
 * Queues registered:
 *   - emails           transactional email
 *   - documents        PDF/CSV generation
 *   - workflows        rule-engine executions
 *   - pos-sync         POS offline sync arbitration
 *   - imports          background data imports
 *
 * Author: Amir Saoudi.
 */
import { BullModule } from '@nestjs/bullmq';
import { Global, Module } from '@nestjs/common';
import { AppConfig } from '../config/app.config';

const QUEUES = ['emails', 'documents', 'workflows', 'pos-sync', 'imports'] as const;

@Global()
@Module({
  imports: [
    BullModule.forRootAsync({
      inject: [AppConfig],
      useFactory: (cfg: AppConfig) => ({
        connection: {
          host: cfg.redis.host,
          port: cfg.redis.port,
          password: cfg.redis.password,
        },
      }),
    }),
    ...QUEUES.map((name) => BullModule.registerQueue({ name })),
  ],
  exports: [BullModule],
})
export class QueueModule {}
