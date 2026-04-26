import { Module } from '@nestjs/common';
import { LeadsController } from './leads.controller';
import { OpportunitiesController } from './opportunities.controller';
@Module({ controllers: [LeadsController, OpportunitiesController] })
export class CrmModule {}
