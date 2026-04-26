/**
 * Amir ERP — workflow / automation engine.
 *
 * Listens to internal domain events and dispatches matching workflow
 * definitions to the BullMQ queue for asynchronous execution.
 *
 * A workflow definition has:
 *   - trigger:    string event name (e.g. "invoice.created")
 *   - conditions: JSON-Logic-like rule
 *   - actions:    list of actions (notify, email, set-field, webhook)
 *
 * Author: Amir Saoudi.
 */
import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { Queue } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';

export interface WorkflowEvent {
  trigger: string;
  tenantId: string;
  payload: Record<string, unknown>;
}

@Injectable()
export class WorkflowEngine {
  private readonly logger = new Logger(WorkflowEngine.name);

  constructor(
    private readonly prisma: PrismaService,
    @InjectQueue('workflows') private readonly queue: Queue,
  ) {}

  emit(event: WorkflowEvent): void {
    void this.dispatch(event);
  }

  @OnEvent('**', { async: true, promisify: true })
  async onAny(eventName: string, payload: Record<string, unknown>): Promise<void> {
    if (typeof payload?.tenantId !== 'string') return;
    await this.dispatch({ trigger: eventName, tenantId: payload.tenantId, payload });
  }

  private async dispatch(evt: WorkflowEvent): Promise<void> {
    try {
      const workflows = await this.prisma.unscoped((db) =>
        db.workflow.findMany({
          where: { tenantId: evt.tenantId, trigger: evt.trigger, isActive: true },
        }),
      );
      for (const wf of workflows) {
        await this.queue.add('execute', { workflowId: wf.id, event: evt }, { removeOnComplete: 1000 });
      }
    } catch (e) {
      this.logger.warn(`workflow dispatch failed: ${(e as Error).message}`);
    }
  }

  static evaluateConditions(conditions: unknown, payload: Record<string, unknown>): boolean {
    // Tiny rule evaluator — supports {all|any|not|var|==|!=|>|<|in|contains}
    if (!conditions || typeof conditions !== 'object') return true;
    const c = conditions as Record<string, unknown>;
    const get = (k: string): unknown => k.split('.').reduce<unknown>((a, p) => (a && typeof a === 'object' ? (a as Record<string, unknown>)[p] : undefined), payload);

    if ('all' in c && Array.isArray(c.all)) return c.all.every((x) => WorkflowEngine.evaluateConditions(x, payload));
    if ('any' in c && Array.isArray(c.any)) return c.any.some((x) => WorkflowEngine.evaluateConditions(x, payload));
    if ('not' in c) return !WorkflowEngine.evaluateConditions(c.not, payload);
    if ('==' in c) { const [a, b] = c['=='] as [string, unknown]; return get(a) === b; }
    if ('!=' in c) { const [a, b] = c['!='] as [string, unknown]; return get(a) !== b; }
    if ('>' in c)  { const [a, b] = c['>']  as [string, number]; return Number(get(a)) > b; }
    if ('<' in c)  { const [a, b] = c['<']  as [string, number]; return Number(get(a)) < b; }
    if ('in' in c) { const [a, b] = c['in'] as [string, unknown[]]; return Array.isArray(b) && b.includes(get(a)); }
    return true;
  }
}
