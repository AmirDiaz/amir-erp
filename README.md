# Amir ERP

> Modern multi-tenant SaaS ERP — Flutter universal client (Android · iOS · Web · Windows · Linux · macOS) backed by a NestJS modular monolith.

**Author:** Amir Saoudi · **Contact:** amirsaoudi620@gmail.com

---

## Features

- **Accounting** — Double-entry general ledger, journals, chart of accounts, financial reports (P&L, Balance Sheet, Cash Flow).
- **Invoicing & Payments** — Multi-currency, taxes engine, partial payments, receipts, refunds.
- **Sales & CRM** — Leads pipeline, opportunities, quotations, contracts.
- **Inventory** — Multi-warehouse, stock movements, lot/serial tracking, valuation.
- **Procurement** — Purchase orders, suppliers, RFQs.
- **POS** — Offline-first, barcode, cart, discounts, split payments, refunds, sync engine, conflict resolution.
- **Manufacturing (MRP)** — BoM, work orders, routings.
- **Projects** — Tasks, timesheets, milestones.
- **HR** — Employees, departments, leaves, payroll, expenses, assets.
- **SaaS Core** — Multi-tenant, multi-company, multi-branch, RBAC + ABAC, audit logs, workflow engine, automation rules, plugin system, feature flags.
- **White-label** — Per-tenant branding (logo, colors, fonts, modules, dashboards) applied dynamically.
- **i18n** — Arabic + English with full RTL support.

## Tech Stack

| Layer | Choice |
|---|---|
| Frontend | Flutter 3.x (Android, iOS, Web, Windows, Linux, macOS) |
| State | Riverpod, GoRouter, Freezed, Drift (offline DB) |
| Backend | NestJS 10 (TypeScript, Node 20) |
| ORM | Prisma |
| Database | PostgreSQL 16 |
| Cache / Queue | Redis 7 + BullMQ |
| Search | Meilisearch |
| File storage | MinIO (S3-compatible) |
| Auth | JWT (access + refresh rotation), Argon2id, CASL RBAC/ABAC |
| Realtime | Socket.IO over Redis adapter |
| Reverse proxy | Caddy (auto-HTTPS) |
| Observability | Prometheus + Grafana + Loki + OpenTelemetry |

## Quickstart (one shot)

```bash
git clone https://github.com/AmirDiaz/amir-erp.git ~/projects/amir-erp
cd ~/projects/amir-erp
./infra/scripts/bootstrap.sh
pnpm backend:dev   # http://localhost:3000  (Swagger at /api/docs)

# In another terminal, on Web:
pnpm mobile:web
```

The bootstrap script:
1. Runs `pnpm install`.
2. Brings up the infra stack (Postgres, Redis, MinIO, Meilisearch, Prometheus/Grafana/Loki, Mailhog, Caddy).
3. Generates the Prisma client, applies the schema (`db push`), seeds the demo tenant.
4. Generates the Flutter platform folders (`flutter create .` for android/ios/web/linux/windows/macos), runs `flutter pub get` and `gen-l10n`.

Manual variant:

```bash
pnpm install
pnpm compose:up
cp apps/backend/.env.example apps/backend/.env
pnpm --filter @amir-erp/backend exec prisma generate
pnpm --filter @amir-erp/backend exec prisma db push
pnpm backend:seed
pnpm backend:dev
```

Default seeded credentials (dev only):

```
Tenant:   demo
Email:    admin@demo.amir-erp.local
Password: AmirAdmin#2026
```

## Repo Layout

See [`docs/architecture.md`](docs/architecture.md) for full details.

```
apps/
  backend/   # NestJS modular monolith (Prisma + Postgres + Redis + BullMQ)
  mobile/    # Flutter universal app
packages/
  shared-types/
  eslint-config/
infra/
  docker-compose.yml
  caddy/  prometheus/  grafana/  loki/  scripts/
docs/
.github/workflows/
```

## License

Proprietary — see [`LICENSE`](LICENSE).

---

Built by **Amir Saoudi**.
