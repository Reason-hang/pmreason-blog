#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${TMPDIR:-/tmp}/pmreason-verify-public-$$"
SITE_URL="${SITE_URL:-https://pmreason.top}"

cleanup() {
  rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: missing command: $1" >&2
    exit 1
  fi
}

echo "== check commands =="
need_cmd git
need_cmd hugo
need_cmd curl

cd "$ROOT_DIR"

echo "== git status =="
git status --short --branch

echo "== submodule =="
git submodule update --init --recursive
git submodule status --recursive

echo "== hugo version =="
hugo version

echo "== build =="
rm -rf "$BUILD_DIR"
hugo --minify --destination "$BUILD_DIR"

echo "== generated files =="
test -f "$BUILD_DIR/index.html"
test -f "$BUILD_DIR/index.xml"
test -f "$BUILD_DIR/index.json"
find "$BUILD_DIR" -maxdepth 2 -type f | wc -l
du -sh "$BUILD_DIR"

echo "== local output checks =="
grep -qi "<title" "$BUILD_DIR/index.html"
grep -qi "PMReason" "$BUILD_DIR/index.html"

echo "== live checks =="
curl -fsSI "$SITE_URL/" >/dev/null || echo "WARN: live homepage is not reachable: $SITE_URL/"
curl -fsSI "$SITE_URL/index.xml" >/dev/null || echo "WARN: live RSS is not reachable: $SITE_URL/index.xml"
curl -fsSI "$SITE_URL/index.json" >/dev/null || echo "WARN: live search index is not reachable: $SITE_URL/index.json"

echo "OK: verify passed"
