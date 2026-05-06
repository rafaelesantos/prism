#!/usr/bin/env bash
#
# Build all Prism library targets and verify strict imports.
# Test targets are compiled by `swift test` — no need to build them twice.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

swift build \
    --explicit-target-dependency-import-check error
