/**
 * Amir ERP — Redis service (cache, pubsub, distributed locks).
 * Author: Amir Saoudi.
 */
import { Injectable, OnModuleDestroy, OnModuleInit, Logger } from '@nestjs/common';
import Redis, { RedisOptions } from 'ioredis';
import { AppConfig } from '../config/app.config';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private _client!: Redis;
  private _subscriber!: Redis;

  constructor(private readonly cfg: AppConfig) {}

  onModuleInit(): void {
    const opts: RedisOptions = {
      host: this.cfg.redis.host,
      port: this.cfg.redis.port,
      password: this.cfg.redis.password,
      maxRetriesPerRequest: null,
      lazyConnect: false,
    };
    this._client = new Redis(opts);
    this._subscriber = new Redis(opts);
    this._client.on('error', (e) => this.logger.error(`redis error: ${e.message}`));
    this._client.on('connect', () => this.logger.log('Redis connected'));
  }

  async onModuleDestroy(): Promise<void> {
    await this._client?.quit();
    await this._subscriber?.quit();
  }

  get client(): Redis { return this._client; }
  get subscriber(): Redis { return this._subscriber; }

  async withLock<T>(key: string, ttlMs: number, fn: () => Promise<T>): Promise<T> {
    const token = `${process.pid}-${Date.now()}-${Math.random()}`;
    const ok = await this._client.set(`lock:${key}`, token, 'PX', ttlMs, 'NX');
    if (ok !== 'OK') throw new Error(`Could not acquire lock: ${key}`);
    try {
      return await fn();
    } finally {
      const lua = `if redis.call('GET',KEYS[1])==ARGV[1] then return redis.call('DEL',KEYS[1]) else return 0 end`;
      await this._client.eval(lua, 1, `lock:${key}`, token);
    }
  }
}
