import { Module } from '@nestjs/common';
import { ManufacturingController } from './manufacturing.controller';
@Module({ controllers: [ManufacturingController] })
export class ManufacturingModule {}
