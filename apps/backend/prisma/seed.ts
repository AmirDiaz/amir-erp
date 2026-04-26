/**
 * Amir ERP — database seed.
 *
 * Creates a demo tenant, owner user, system roles, chart of accounts, taxes,
 * a default warehouse, sample products, partners, and an OPEN POS session
 * so a fresh checkout works immediately.
 *
 * Author: Amir Saoudi.
 */
import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

const DEMO_TENANT = { slug: 'demo', name: 'Demo Company' };
const DEMO_USER = {
  email: 'admin@demo.amir-erp.local',
  fullName: 'Amir Saoudi',
  password: 'AmirAdmin#2026',
};

const SYSTEM_ROLES = [
  { name: 'Owner', permissions: ['*'], isSystem: true, description: 'Tenant owner — full access' },
  { name: 'Admin', permissions: ['accounting.*', 'invoicing.*', 'payments.*', 'taxes.*', 'reports.*', 'sales.*', 'crm.*', 'inventory.*', 'pos.*', 'manufacturing.*', 'projects.*', 'hr.*', 'payroll.*', 'expenses.*', 'assets.*', 'partners.*', 'workflows.*', 'plugins.*', 'branding.*', 'users.*', 'tenants.read', 'companies.*', 'warehouses.*', 'procurement.*', 'quotations.*', 'contracts.*', 'notifications.*'], isSystem: true, description: 'Administrator' },
  { name: 'Accountant', permissions: ['accounting.*', 'invoicing.*', 'payments.*', 'taxes.*', 'reports.*', 'expenses.*', 'partners.read'], isSystem: true, description: 'Finance & accounting' },
  { name: 'Sales', permissions: ['sales.*', 'crm.*', 'quotations.*', 'contracts.*', 'invoicing.read', 'invoicing.create', 'partners.*'], isSystem: true, description: 'Sales rep' },
  { name: 'Cashier', permissions: ['pos.*', 'inventory.read', 'partners.read'], isSystem: true, description: 'POS cashier' },
  { name: 'Warehouse', permissions: ['inventory.*', 'warehouses.*', 'procurement.*', 'partners.read'], isSystem: true, description: 'Warehouse staff' },
  { name: 'HR', permissions: ['hr.*', 'payroll.*', 'expenses.*', 'assets.*'], isSystem: true, description: 'HR manager' },
  { name: 'Viewer', permissions: ['*.read'], isSystem: true, description: 'Read-only' },
];

// Standard chart of accounts (Saudi/GCC-friendly + universal)
const COA = [
  { code: '1000', name: 'Cash', type: 'ASSET' },
  { code: '1010', name: 'Bank', type: 'ASSET' },
  { code: '1100', name: 'Accounts Receivable', type: 'ASSET' },
  { code: '1200', name: 'Inventory', type: 'ASSET' },
  { code: '1500', name: 'Fixed Assets', type: 'ASSET' },
  { code: '2000', name: 'Accounts Payable', type: 'LIABILITY' },
  { code: '2100', name: 'Tax Payable (VAT)', type: 'LIABILITY' },
  { code: '2200', name: 'Salaries Payable', type: 'LIABILITY' },
  { code: '3000', name: 'Equity', type: 'EQUITY' },
  { code: '3100', name: 'Retained Earnings', type: 'EQUITY' },
  { code: '4000', name: 'Sales Revenue', type: 'INCOME' },
  { code: '4100', name: 'Service Revenue', type: 'INCOME' },
  { code: '5000', name: 'Cost of Goods Sold', type: 'EXPENSE' },
  { code: '5100', name: 'Salaries Expense', type: 'EXPENSE' },
  { code: '5200', name: 'Rent Expense', type: 'EXPENSE' },
  { code: '5300', name: 'Utilities Expense', type: 'EXPENSE' },
  { code: '5400', name: 'Office Supplies', type: 'EXPENSE' },
  { code: '5500', name: 'Marketing Expense', type: 'EXPENSE' },
  { code: '5900', name: 'Other Expenses', type: 'EXPENSE' },
] as const;

async function main(): Promise<void> {
  // eslint-disable-next-line no-console
  console.log('▶ Amir ERP — seeding database (Author: Amir Saoudi)');

  const tenant = await prisma.tenant.upsert({
    where: { slug: DEMO_TENANT.slug },
    update: { name: DEMO_TENANT.name },
    create: { slug: DEMO_TENANT.slug, name: DEMO_TENANT.name, status: 'ACTIVE' },
  });

  // Roles
  for (const role of SYSTEM_ROLES) {
    await prisma.role.upsert({
      where: { tenantId_name: { tenantId: tenant.id, name: role.name } },
      update: { permissions: role.permissions, description: role.description, isSystem: true },
      create: { tenantId: tenant.id, ...role },
    });
  }

  // Owner user
  const passwordHash = await argon2.hash(DEMO_USER.password, { type: argon2.argon2id });
  const user = await prisma.user.upsert({
    where: { email: DEMO_USER.email },
    update: {},
    create: { email: DEMO_USER.email, fullName: DEMO_USER.fullName, password: passwordHash, status: 'ACTIVE' },
  });
  await prisma.userTenant.upsert({
    where: { userId_tenantId: { userId: user.id, tenantId: tenant.id } },
    update: { isOwner: true, roleIds: [] },
    create: { userId: user.id, tenantId: tenant.id, isOwner: true, roleIds: [] },
  });

  // Company + branch
  const company = await prisma.company.upsert({
    where: { id: `${tenant.id}-company` },
    update: {},
    create: {
      id: `${tenant.id}-company`,
      tenantId: tenant.id,
      name: 'Demo Company',
      legalName: 'Demo Company LLC',
      currency: 'USD',
      country: 'SA',
      address: 'Riyadh, Saudi Arabia',
      branches: { create: [{ name: 'Main Branch', address: 'Headquarters' }] },
    },
  });

  // Chart of accounts
  for (const a of COA) {
    await prisma.account.upsert({
      where: { tenantId_code: { tenantId: tenant.id, code: a.code } },
      update: {},
      create: { tenantId: tenant.id, code: a.code, name: a.name, type: a.type, currency: 'USD' },
    });
  }

  // Taxes
  await prisma.tax.upsert({
    where: { id: `${tenant.id}-vat15` },
    update: {},
    create: { id: `${tenant.id}-vat15`, tenantId: tenant.id, name: 'VAT 15%', rate: '0.15', type: 'PERCENT' },
  });
  await prisma.tax.upsert({
    where: { id: `${tenant.id}-vat20` },
    update: {},
    create: { id: `${tenant.id}-vat20`, tenantId: tenant.id, name: 'VAT 20%', rate: '0.20', type: 'PERCENT' },
  });

  // Warehouse
  const warehouse = await prisma.warehouse.upsert({
    where: { tenantId_code: { tenantId: tenant.id, code: 'WH-MAIN' } },
    update: {},
    create: { tenantId: tenant.id, code: 'WH-MAIN', name: 'Main Warehouse' },
  });

  // Products (POS-friendly with barcodes)
  const products = [
    { sku: 'COFFEE-LRG', barcode: '8001234567890', name: 'Large Coffee', price: '4.50', cost: '1.20' },
    { sku: 'COFFEE-MED', barcode: '8001234567891', name: 'Medium Coffee', price: '3.50', cost: '1.00' },
    { sku: 'CROISSANT', barcode: '8001234567892', name: 'Croissant', price: '2.75', cost: '0.80' },
    { sku: 'BAGEL', barcode: '8001234567893', name: 'Bagel', price: '2.25', cost: '0.60' },
    { sku: 'WATER-500', barcode: '8001234567894', name: 'Water 500ml', price: '1.00', cost: '0.30' },
    { sku: 'JUICE-OR', barcode: '8001234567895', name: 'Orange Juice', price: '3.00', cost: '0.90' },
    { sku: 'SANDWICH', barcode: '8001234567896', name: 'Club Sandwich', price: '7.50', cost: '2.80' },
    { sku: 'SALAD', barcode: '8001234567897', name: 'Caesar Salad', price: '8.50', cost: '3.10' },
  ];
  for (const p of products) {
    const product = await prisma.product.upsert({
      where: { tenantId_sku: { tenantId: tenant.id, sku: p.sku } },
      update: {},
      create: { tenantId: tenant.id, ...p, type: 'STORABLE' },
    });
    // initial stock
    await prisma.stockMove.create({
      data: {
        tenantId: tenant.id,
        productId: product.id,
        toWarehouseId: warehouse.id,
        quantity: '100',
        unitCost: p.cost,
        reason: 'PURCHASE',
        reference: 'opening-stock',
      },
    });
  }

  // Partners (1 customer + 1 supplier)
  await prisma.partner.upsert({
    where: { id: `${tenant.id}-cust1` },
    update: {},
    create: {
      id: `${tenant.id}-cust1`,
      tenantId: tenant.id,
      type: 'CUSTOMER',
      name: 'Acme Inc.',
      email: 'billing@acme.test',
      phone: '+966500000001',
      country: 'SA',
    },
  });
  await prisma.partner.upsert({
    where: { id: `${tenant.id}-sup1` },
    update: {},
    create: {
      id: `${tenant.id}-sup1`,
      tenantId: tenant.id,
      type: 'SUPPLIER',
      name: 'Wholesale Supplier Co.',
      email: 'orders@supplier.test',
      country: 'SA',
    },
  });

  // Employees
  await prisma.employee.upsert({
    where: { id: `${tenant.id}-emp1` },
    update: {},
    create: {
      id: `${tenant.id}-emp1`,
      tenantId: tenant.id,
      fullName: 'Sample Employee',
      email: 'employee@demo.amir-erp.local',
      jobTitle: 'Cashier',
      department: 'Operations',
      salary: '3000',
      currency: 'USD',
      hireDate: new Date(),
    },
  });

  // POS session (open)
  await prisma.posSession.upsert({
    where: { id: `${tenant.id}-pos1` },
    update: {},
    create: {
      id: `${tenant.id}-pos1`,
      tenantId: tenant.id,
      cashierId: user.id,
      openingCash: '100',
      status: 'OPEN',
    },
  });

  // eslint-disable-next-line no-console
  console.log(`✓ Seed complete.
  tenant   : ${tenant.slug}
  email    : ${DEMO_USER.email}
  password : ${DEMO_USER.password}
  company  : ${company.name}
`);
}

main()
  .catch((e) => {
    // eslint-disable-next-line no-console
    console.error('Seed failed:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
