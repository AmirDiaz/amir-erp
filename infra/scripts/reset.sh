#!/usr/bin/env bash
# Amir ERP — wipe local data and redo bootstrap.
# Author: Amir Saoudi
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

docker compose -f infra/docker-compose.yml down -v
rm -rf infra/.volumes
exec ./infra/scripts/bootstrap.sh
