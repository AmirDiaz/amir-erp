/**
 * Amir ERP — runtime plugin loader.
 *
 * Plugins live under `apps/backend/src/plugins/<key>/index.ts` and export a
 * default `Module` class. They are registered per tenant in the database
 * (`Plugin` table) with a JSON `config`. The Flutter client mirrors this list
 * to render plugin UI dynamically.
 *
 * Author: Amir Saoudi.
 */
import { Global, Module } from '@nestjs/common';
import { PluginsService } from './plugins.service';
import { PluginsController } from './plugins.controller';

@Global()
@Module({
  controllers: [PluginsController],
  providers: [PluginsService],
  exports: [PluginsService],
})
export class PluginsModule {}
