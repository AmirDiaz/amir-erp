/**
 * Amir ERP — POS realtime gateway. Broadcasts new orders to all connected
 * cashier clients in the same tenant for live dashboards / kitchen display.
 *
 * Author: Amir Saoudi.
 */
import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server } from 'socket.io';

@Injectable()
@WebSocketGateway({ cors: { origin: '*' }, namespace: '/pos' })
export class PosGateway {
  @WebSocketServer() io!: Server;

  @OnEvent('pos.order.created')
  onOrderCreated(payload: { tenantId: string; orderId: string }) {
    this.io.to(`tenant:${payload.tenantId}`).emit('order.created', payload);
  }
}
