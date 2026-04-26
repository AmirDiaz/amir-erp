import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface PluginManifest {
  key: string;
  name: string;
  version: string;
  description?: string;
  category?: string;
  icon?: string;
  permissions?: string[];
}

@Injectable()
export class PluginsService {
  // Built-in plugin manifests advertised to every tenant. Customers can also
  // upload their own bundles; those are stored as records in `Plugin`.
  static readonly BUILTIN: PluginManifest[] = [
    { key: 'whatsapp', name: 'WhatsApp Notifications', version: '1.0.0', category: 'notifications', icon: 'message' },
    { key: 'stripe', name: 'Stripe Payments', version: '1.0.0', category: 'payments', icon: 'credit-card' },
    { key: 'shopify', name: 'Shopify Sync', version: '1.0.0', category: 'sales', icon: 'shop' },
    { key: 'google-drive', name: 'Google Drive Backup', version: '1.0.0', category: 'storage', icon: 'cloud' },
  ];

  constructor(private readonly prisma: PrismaService) {}

  manifests(): PluginManifest[] { return PluginsService.BUILTIN; }

  list() { return this.prisma.plugin.findMany({ orderBy: { createdAt: 'desc' } }); }
  get(id: string) { return this.prisma.plugin.findUnique({ where: { id } }); }

  install(input: { tenantId: string; key: string; config?: Record<string, unknown> }) {
    const m = PluginsService.BUILTIN.find((x) => x.key === input.key);
    return this.prisma.plugin.upsert({
      where: { tenantId_key: { tenantId: input.tenantId, key: input.key } },
      update: { isEnabled: true, config: (input.config ?? {}) as never },
      create: {
        tenantId: input.tenantId,
        key: input.key,
        name: m?.name ?? input.key,
        version: m?.version ?? '1.0.0',
        config: (input.config ?? {}) as never,
      },
    });
  }

  toggle(id: string, isEnabled: boolean) {
    return this.prisma.plugin.update({ where: { id }, data: { isEnabled } });
  }

  uninstall(id: string) { return this.prisma.plugin.delete({ where: { id } }); }
}
