import { Global, Module } from '@nestjs/common';
import { BrandingService } from './branding.service';
import { BrandingController } from './branding.controller';

@Global()
@Module({
  controllers: [BrandingController],
  providers: [BrandingService],
  exports: [BrandingService],
})
export class BrandingModule {}
