import { Module } from '@nestjs/common';
import { ProductsController } from './products.controller';
import { StockController } from './stock.controller';
import { InventoryService } from './inventory.service';
@Module({ controllers: [ProductsController, StockController], providers: [InventoryService], exports: [InventoryService] })
export class InventoryModule {}
