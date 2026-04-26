/**
 * Amir ERP — file storage abstraction over MinIO/S3.
 * Author: Amir Saoudi.
 */
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Client as MinioClient } from 'minio';
import { AppConfig } from '../config/app.config';

@Injectable()
export class FilesService implements OnModuleInit {
  private readonly logger = new Logger(FilesService.name);
  private client!: MinioClient;
  private bucket!: string;

  constructor(private readonly cfg: AppConfig) {}

  async onModuleInit(): Promise<void> {
    const endpoint = new URL(this.cfg.s3.endpoint);
    this.client = new MinioClient({
      endPoint: endpoint.hostname,
      port: Number(endpoint.port) || (this.cfg.s3.useSSL ? 443 : 80),
      useSSL: this.cfg.s3.useSSL,
      accessKey: this.cfg.s3.accessKey,
      secretKey: this.cfg.s3.secretKey,
      region: this.cfg.s3.region,
    });
    this.bucket = this.cfg.s3.bucket;
    try {
      const exists = await this.client.bucketExists(this.bucket);
      if (!exists) await this.client.makeBucket(this.bucket, this.cfg.s3.region);
    } catch (e) {
      this.logger.warn(`MinIO not reachable yet: ${(e as Error).message}`);
    }
  }

  async putObject(key: string, data: Buffer, mimeType = 'application/octet-stream'): Promise<{ key: string; bucket: string; size: number }> {
    await this.client.putObject(this.bucket, key, data, data.length, { 'Content-Type': mimeType });
    return { key, bucket: this.bucket, size: data.length };
  }

  async presignedGetUrl(key: string, expiry = 600): Promise<string> {
    return this.client.presignedGetObject(this.bucket, key, expiry);
  }

  async presignedPutUrl(key: string, expiry = 600): Promise<string> {
    return this.client.presignedPutObject(this.bucket, key, expiry);
  }
}
