/**
 * Amir ERP — backend entry point.
 * Author: Amir Saoudi <amirsaoudi620@gmail.com>
 */
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType, Logger, RequestMethod, VERSION_NEUTRAL } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import compression from 'compression';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { AuditInterceptor } from './core/audit/audit.interceptor';
import { AppConfig } from './core/config/app.config';
import { APP_AUTHOR, APP_AUTHOR_EMAIL, APP_NAME } from './common/branding';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: false,
  });

  const config = app.get(AppConfig);
  const logger = new Logger('Bootstrap');

  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(compression());
  app.enableCors({
    origin: config.cors.origins,
    credentials: true,
  });

  app.setGlobalPrefix('api', {
    exclude: [
      { path: 'health', method: RequestMethod.GET },
      { path: 'metrics', method: RequestMethod.GET },
      { path: 'about', method: RequestMethod.GET },
    ],
  });
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalInterceptors(new TransformInterceptor(), app.get(AuditInterceptor));

  const swagger = new DocumentBuilder()
    .setTitle(`${APP_NAME} — API`)
    .setDescription(`Author: ${APP_AUTHOR} <${APP_AUTHOR_EMAIL}>`)
    .setVersion('0.1.0')
    .setContact(APP_AUTHOR, '', APP_AUTHOR_EMAIL)
    .addBearerAuth()
    .addServer('/api')
    .build();
  const swaggerDocument = SwaggerModule.createDocument(app, swagger);
  SwaggerModule.setup('api/docs', app, swaggerDocument, {
    customSiteTitle: `${APP_NAME} — API Docs`,
    swaggerOptions: { persistAuthorization: true },
  });

  const port = config.port;
  await app.listen(port, '0.0.0.0');

  logger.log(`╔══════════════════════════════════════════════════╗`);
  logger.log(`║          ${APP_NAME} backend ready          ║`);
  logger.log(`║          Author: ${APP_AUTHOR}             ║`);
  logger.log(`╚══════════════════════════════════════════════════╝`);
  logger.log(`→ http://localhost:${port}`);
  logger.log(`→ Swagger: http://localhost:${port}/api/docs`);
}

bootstrap().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Fatal bootstrap error:', err);
  process.exit(1);
});
