import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server } from 'socket.io';

@Injectable()
@WebSocketGateway({ cors: { origin: '*' }, namespace: '/notifications' })
export class NotificationsGateway {
  @WebSocketServer() io!: Server;

  @OnEvent('notification.created')
  onCreated(payload: { tenantId: string; userId?: string }) {
    this.io.to(`tenant:${payload.tenantId}`).emit('notification', payload);
  }
}
