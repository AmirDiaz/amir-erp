import { Global, MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { TenantContext } from './tenant.context';
import { TenancyMiddleware } from './tenancy.middleware';

@Global()
@Module({
  providers: [TenantContext, TenancyMiddleware],
  exports: [TenantContext, TenancyMiddleware],
})
export class TenancyModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(TenancyMiddleware).forRoutes('*');
  }
}
