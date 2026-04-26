import { Module } from '@nestjs/common';
import { PurchaseOrdersController } from './purchase-orders.controller';
import { BillsController } from './bills.controller';
@Module({ controllers: [PurchaseOrdersController, BillsController] })
export class ProcurementModule {}
