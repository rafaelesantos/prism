#!/bin/bash
set -euo pipefail

# Build Prism documentation site using MkDocs Material
# Usage: ./scripts/docs.sh [serve]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_DIR/docs-site"

if [ "${1:-}" = "serve" ]; then
    echo "Starting documentation dev server at http://127.0.0.1:8000 ..."
    cd "$DOCS_DIR"
    mkdocs serve
else
    echo "Building Prism documentation..."
    cd "$DOCS_DIR"
    mkdocs build
    echo ""
    echo "Documentation built at $DOCS_DIR/site/"
    echo "Open $DOCS_DIR/site/index.html in a browser to preview."
fi