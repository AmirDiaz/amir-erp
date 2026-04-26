#!/usr/bin/env bash
# Amir ERP — one-shot local bootstrap.
# Author: Amir Saoudi
#
# Usage:  ./infra/scripts/bootstrap.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

say() { printf "\n\033[1;36m▸ %s\033[0m\n" "$*"; }

say "Installing pnpm dependencies"
pnpm install --frozen-lockfile=false

say "Starting infra (postgres, redis, minio, meilisearch, observability)"
docker compose -f infra/docker-compose.yml up -d

say "Waiting for postgres..."
for i in {1..40}; do
  if docker exec amir-erp-postgres pg_isready -U amir -d amir_erp >/dev/null 2>&1; then break; fi
  sleep 1
done

say "Preparing backend env"
if [ ! -f apps/backend/.env ]; then
  cp apps/backend/.env.example apps/backend/.env
fi

say "Running prisma migrations"
pnpm --filter @amir-erp/backend exec prisma generate
pnpm --filter @amir-erp/backend exec prisma migrate deploy || pnpm --filter @amir-erp/backend exec prisma db push

say "Seeding demo tenant"
pnpm --filter @amir-erp/backend run seed

if command -v flutter >/dev/null 2>&1; then
  say "Generating Flutter platform folders (idempotent)"
  pushd apps/mobile >/dev/null
  flutter create . --platforms=android,ios,web,linux,windows,macos --org com.amirsaoudi --project-name amir_erp --description "Amir ERP" || true
  flutter pub get || true
  flutter gen-l10n || true
  popd >/dev/null
else
  say "Flutter not found in PATH; skipping mobile bootstrap (run later in apps/mobile)"
fi

cat <<'BANNER'

╔════════════════════════════════════════════════════════════════╗
║                       Amir ERP — Ready                         ║
║                       Author: Amir Saoudi                      ║
╠════════════════════════════════════════════════════════════════╣
║  Backend:    pnpm backend:dev  →  http://localhost:3000        ║
║  Swagger:    http://localhost:3000/api/docs                    ║
║  Mobile web: pnpm mobile:web                                   ║
║  Grafana:    http://localhost:3001  (amir / amir)              ║
║  MinIO:      http://localhost:9001  (amir / amirminio)         ║
║  Meili:      http://localhost:7700                             ║
║  Mailhog:    http://localhost:8025                             ║
║                                                                ║
║  Demo login: admin@demo.amir-erp.local / AmirAdmin#2026        ║
╚════════════════════════════════════════════════════════════════╝
BANNER
