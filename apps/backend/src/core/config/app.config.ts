/**
 * Amir ERP — strongly-typed configuration provider.
 * Author: Amir Saoudi.
 */
import { DynamicModule, Global, Module, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as Joi from 'joi';

export const configSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  PORT: Joi.number().default(3000),
  APP_BASE_URL: Joi.string().uri().default('http://localhost:3000'),
  WEB_BASE_URL: Joi.string().uri().default('http://localhost:8080'),

  DATABASE_URL: Joi.string().required(),

  REDIS_HOST: Joi.string().default('localhost'),
  REDIS_PORT: Joi.number().default(6379),
  REDIS_PASSWORD: Joi.string().allow('').default(''),

  JWT_ACCESS_SECRET: Joi.string().min(16).required(),
  JWT_REFRESH_SECRET: Joi.string().min(16).required(),
  JWT_ACCESS_TTL: Joi.number().default(900),
  JWT_REFRESH_TTL: Joi.number().default(2_592_000),

  S3_ENDPOINT: Joi.string().uri().default('http://localhost:9000'),
  S3_REGION: Joi.string().default('us-east-1'),
  S3_ACCESS_KEY: Joi.string().required(),
  S3_SECRET_KEY: Joi.string().required(),
  S3_BUCKET: Joi.string().default('amir-erp'),
  S3_USE_SSL: Joi.boolean().default(false),

  MEILI_HOST: Joi.string().uri().default('http://localhost:7700'),
  MEILI_KEY: Joi.string().allow('').default(''),

  SMTP_HOST: Joi.string().default('localhost'),
  SMTP_PORT: Joi.number().default(1025),
  SMTP_USER: Joi.string().allow('').default(''),
  SMTP_PASS: Joi.string().allow('').default(''),
  MAIL_FROM: Joi.string().default('Amir ERP <noreply@amir-erp.local>'),

  RATE_LIMIT_TTL: Joi.number().default(60),
  RATE_LIMIT_MAX: Joi.number().default(120),
  CORS_ORIGINS: Joi.string().default('http://localhost:8080'),

  LOG_LEVEL: Joi.string().valid('debug', 'info', 'warn', 'error').default('info'),
  ENABLE_METRICS: Joi.boolean().default(true),
});

@Injectable()
export class AppConfig {
  constructor(private readonly cs: ConfigService) {}

  static forRoot(): DynamicModule {
    return {
      module: AppConfigModule,
      providers: [AppConfig],
      exports: [AppConfig],
      global: true,
    };
  }

  get nodeEnv(): string { return this.cs.get<string>('NODE_ENV', 'development'); }
  get isDev(): boolean { return this.nodeEnv === 'development'; }
  get isProd(): boolean { return this.nodeEnv === 'production'; }
  get port(): number { return Number(this.cs.get<number>('PORT', 3000)); }
  get appBaseUrl(): string { return this.cs.get<string>('APP_BASE_URL')!; }
  get webBaseUrl(): string { return this.cs.get<string>('WEB_BASE_URL')!; }

  get database() { return { url: this.cs.get<string>('DATABASE_URL')! }; }

  get redis() {
    return {
      host: this.cs.get<string>('REDIS_HOST')!,
      port: Number(this.cs.get<number>('REDIS_PORT', 6379)),
      password: this.cs.get<string>('REDIS_PASSWORD') || undefined,
    };
  }

  get jwt() {
    return {
      accessSecret: this.cs.get<string>('JWT_ACCESS_SECRET')!,
      refreshSecret: this.cs.get<string>('JWT_REFRESH_SECRET')!,
      accessTtl: Number(this.cs.get<number>('JWT_ACCESS_TTL', 900)),
      refreshTtl: Number(this.cs.get<number>('JWT_REFRESH_TTL', 2_592_000)),
    };
  }

  get s3() {
    return {
      endpoint: this.cs.get<string>('S3_ENDPOINT')!,
      region: this.cs.get<string>('S3_REGION')!,
      accessKey: this.cs.get<string>('S3_ACCESS_KEY')!,
      secretKey: this.cs.get<string>('S3_SECRET_KEY')!,
      bucket: this.cs.get<string>('S3_BUCKET')!,
      useSSL: Boolean(this.cs.get<boolean>('S3_USE_SSL', false)),
    };
  }

  get meili() {
    return {
      host: this.cs.get<string>('MEILI_HOST')!,
      apiKey: this.cs.get<string>('MEILI_KEY') || undefined,
    };
  }

  get smtp() {
    return {
      host: this.cs.get<string>('SMTP_HOST')!,
      port: Number(this.cs.get<number>('SMTP_PORT', 1025)),
      user: this.cs.get<string>('SMTP_USER') || undefined,
      pass: this.cs.get<string>('SMTP_PASS') || undefined,
      from: this.cs.get<string>('MAIL_FROM')!,
    };
  }

  get cors() {
    const raw = this.cs.get<string>('CORS_ORIGINS', '');
    const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
    if (list.length === 0 || list.includes('*')) {
      return { origins: true as const };
    }
    return { origins: list };
  }

  get logLevel(): string { return this.cs.get<string>('LOG_LEVEL', 'info'); }
  get metricsEnabled(): boolean { return Boolean(this.cs.get<boolean>('ENABLE_METRICS', true)); }
}

@Global()
@Module({ providers: [AppConfig], exports: [AppConfig] })
class AppConfigModule {}
