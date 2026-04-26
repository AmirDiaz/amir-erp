/**
 * Amir ERP — white-label branding (per-tenant). Lets the Flutter app pull a
 * theme spec at startup and render dynamically.
 *
 * Author: Amir Saoudi.
 */
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { APP_AUTHOR, APP_NAME, APP_TAGLINE } from '../../common/branding';

export interface BrandingSpec {
  appName: string;
  tagline: string;
  logoUrl: string | null;
  iconUrl: string | null;
  primaryColor: string;
  accentColor: string;
  backgroundColor: string;
  surfaceColor: string;
  fontFamily: string;
  rtl: boolean;
  modules: string[];
  signature: string;
}

const DEFAULT: BrandingSpec = {
  appName: APP_NAME,
  tagline: APP_TAGLINE,
  logoUrl: null,
  iconUrl: null,
  primaryColor: '#2E5BFF',
  accentColor: '#7C5CFF',
  backgroundColor: '#0B1020',
  surfaceColor: '#11172A',
  fontFamily: 'Inter',
  rtl: false,
  modules: [
    'dashboard', 'accounting', 'invoicing', 'payments', 'sales', 'crm',
    'inventory', 'pos', 'manufacturing', 'projects', 'hr', 'reports', 'settings',
  ],
  signature: `Powered by ${APP_AUTHOR}`,
};

@Injectable()
export class BrandingService {
  constructor(private readonly prisma: PrismaService) {}

  async forTenant(tenantId: string): Promise<BrandingSpec> {
    const tenant = await this.prisma.unscoped((db) => db.tenant.findUnique({ where: { id: tenantId } }));
    const overrides = (tenant?.branding as Partial<BrandingSpec> | null) ?? {};
    return { ...DEFAULT, ...overrides, signature: DEFAULT.signature };
  }

  async update(tenantId: string, patch: Partial<BrandingSpec>): Promise<BrandingSpec> {
    const merged = { ...(await this.forTenant(tenantId)), ...patch };
    await this.prisma.unscoped((db) =>
      db.tenant.update({ where: { id: tenantId }, data: { branding: merged as never } }),
    );
    return merged;
  }
}
