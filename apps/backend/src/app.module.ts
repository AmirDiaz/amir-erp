/**
 * Amir ERP — root NestJS module. Registers infrastructure (config, db, redis,
 * tenancy, auth, audit, workflow, plugin loader, files, queues) and every
 * business module (accounting, invoicing, sales, crm, inventory, pos, hr...).
 *
 * Author: Amir Saoudi.
 */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerModule } from '@nestjs/throttler';

import { AppConfig, configSchema } from './core/config/app.config';
import { PrismaModule } from './core/prisma/prisma.module';
import { RedisModule } from './core/redis/redis.module';
import { QueueModule } from './core/queue/queue.module';
import { TenancyModule } from './core/tenancy/tenancy.module';
import { AuthModule } from './core/auth/auth.module';
import { RbacModule } from './core/rbac/rbac.module';
import { AuditModule } from './core/audit/audit.module';
import { WorkflowModule } from './core/workflow/workflow.module';
import { PluginsModule } from './core/plugins/plugins.module';
import { FilesModule } from './core/files/files.module';
import { BrandingModule } from './core/branding/branding.module';
import { HealthModule } from './core/health/health.module';
import { AboutModule } from './core/about/about.module';
import { MetricsModule } from './core/metrics/metrics.module';

import { AccountingModule } from './modules/accounting/accounting.module';
import { InvoicingModule } from './modules/invoicing/invoicing.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { TaxesModule } from './modules/taxes/taxes.module';
import { ReportsModule } from './modules/reports/reports.module';
import { SalesModule } from './modules/sales/sales.module';
import { CrmModule } from './modules/crm/crm.module';
import { QuotationsModule } from './modules/quotations/quotations.module';
import { ContractsModule } from './modules/contracts/contracts.module';
import { InventoryModule } from './modules/inventory/inventory.module';
import { WarehousesModule } from './modules/warehouses/warehouses.module';
import { ProcurementModule } from './modules/procurement/procurement.module';
import { SuppliersModule } from './modules/suppliers/suppliers.module';
import { PartnersModule } from './modules/partners/partners.module';
import { PosModule } from './modules/pos/pos.module';
import { ManufacturingModule } from './modules/manufacturing/manufacturing.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { HrModule } from './modules/hr/hr.module';
import { PayrollModule } from './modules/payroll/payroll.module';
import { ExpensesModule } from './modules/expenses/expenses.module';
import { AssetsModule } from './modules/assets/assets.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { TenantsModule } from './modules/tenants/tenants.module';
import { CompaniesModule } from './modules/companies/companies.module';
import { UsersModule } from './modules/users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validationSchema: configSchema,
      validationOptions: { allowUnknown: true, abortEarly: false },
      envFilePath: ['.env'],
    }),
    EventEmitterModule.forRoot({ wildcard: true, maxListeners: 50 }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 120 }]),

    AppConfig.forRoot(),
    PrismaModule,
    RedisModule,
    QueueModule,
    TenancyModule,
    AuthModule,
    RbacModule,
    AuditModule,
    WorkflowModule,
    PluginsModule,
    FilesModule,
    BrandingModule,
    HealthModule,
    AboutModule,
    MetricsModule,

    // Business modules
    TenantsModule,
    CompaniesModule,
    UsersModule,
    PartnersModule,
    AccountingModule,
    TaxesModule,
    InvoicingModule,
    PaymentsModule,
    ReportsModule,
    SalesModule,
    CrmModule,
    QuotationsModule,
    ContractsModule,
    InventoryModule,
    WarehousesModule,
    ProcurementModule,
    SuppliersModule,
    PosModule,
    ManufacturingModule,
    ProjectsModule,
    HrModule,
    PayrollModule,
    ExpensesModule,
    AssetsModule,
    NotificationsModule,
  ],
})
export class AppModule {}
