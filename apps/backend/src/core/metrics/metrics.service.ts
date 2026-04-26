import { Injectable, OnModuleInit } from '@nestjs/common';
import { collectDefaultMetrics, register, Counter, Histogram } from 'prom-client';

@Injectable()
export class MetricsService implements OnModuleInit {
  readonly httpRequests = new Counter({
    name: 'amir_http_requests_total',
    help: 'Total HTTP requests',
    labelNames: ['method', 'route', 'status'],
  });

  readonly httpDurationSeconds = new Histogram({
    name: 'amir_http_request_duration_seconds',
    help: 'HTTP request duration',
    labelNames: ['method', 'route', 'status'],
    buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10],
  });

  onModuleInit(): void {
    collectDefaultMetrics({ prefix: 'amir_' });
  }

  metrics(): Promise<string> { return register.metrics(); }
}
