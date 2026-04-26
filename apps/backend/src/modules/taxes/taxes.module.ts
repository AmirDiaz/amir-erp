import { Module } from '@nestjs/common';
import { TaxesController } from './taxes.controller';
@Module({ controllers: [TaxesController] })
export class TaxesModule {}
