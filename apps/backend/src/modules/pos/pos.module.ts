import { Module } from '@nestjs/common';
import { PosController } from './pos.controller';
import { PosService } from './pos.service';
import { PosGateway } from './pos.gateway';
import { InventoryModule } from '../inventory/inventory.module';
@Module({
  imports: [InventoryModule],
  controllers: [PosController],
  providers: [PosService, PosGateway],
  exports: [PosService],
})
export class PosModule {}
