import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { WorkflowEngine } from './workflow.engine';
import { WorkflowProcessor } from './workflow.processor';
import { WorkflowController } from './workflow.controller';

@Module({
  imports: [BullModule.registerQueue({ name: 'workflows' })],
  controllers: [WorkflowController],
  providers: [WorkflowEngine, WorkflowProcessor],
  exports: [WorkflowEngine],
})
export class WorkflowModule {}
