import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { WorkflowEngine, WorkflowEvent } from './workflow.engine';

@Processor('workflows')
export class WorkflowProcessor extends WorkerHost {
  private readonly logger = new Logger(WorkflowProcessor.name);
  constructor(private readonly prisma: PrismaService) { super(); }

  async process(job: Job<{ workflowId: string; event: WorkflowEvent }>): Promise<void> {
    const { workflowId, event } = job.data;
    const wf = await this.prisma.unscoped((db) => db.workflow.findUnique({ where: { id: workflowId } }));
    if (!wf || !wf.isActive) return;
    if (!WorkflowEngine.evaluateConditions(wf.conditions, event.payload)) return;

    const actions = (wf.actions as unknown as Array<Record<string, unknown>>) ?? [];
    for (const action of actions) {
      try {
        await this.run(action, event);
      } catch (e) {
        this.logger.warn(`action failed for wf ${wf.id}: ${(e as Error).message}`);
      }
    }
  }

  private async run(action: Record<string, unknown>, event: WorkflowEvent): Promise<void> {
    const type = action.type as string;
    switch (type) {
      case 'notify': {
        await this.prisma.unscoped((db) =>
          db.notification.create({
            data: {
              tenantId: event.tenantId,
              userId: (action.userId as string) ?? null,
              type: 'workflow',
              title: (action.title as string) ?? 'Workflow notification',
              body: (action.body as string) ?? null,
              data: event.payload as never,
            },
          }),
        );
        break;
      }
      case 'log': {
        this.logger.log(`workflow log: ${JSON.stringify({ event, action })}`);
        break;
      }
      default:
        this.logger.warn(`unknown workflow action type: ${type}`);
    }
  }
}
