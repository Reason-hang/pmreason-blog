#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_TARGET="${DEPLOY_TARGET:-/home/hermes/blog/public}"
NGINX_SOURCE="$ROOT_DIR/deploy/nginx/pmreason.nginx.conf"
NGINX_AVAILABLE="${NGINX_AVAILABLE:-/etc/nginx/sites-available/pmreason.conf}"
NGINX_ENABLED="${NGINX_ENABLED:-/etc/nginx/sites-enabled/pmreason.conf}"
SITE_URL="${SITE_URL:-https://pmreason.top}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: missing command: $1" >&2
    exit 1
  fi
}

echo "== check commands =="
need_cmd git
need_cmd hugo
need_cmd rsync
need_cmd curl

cd "$ROOT_DIR"

echo "== pull theme =="
git submodule update --init --recursive

echo "== build site =="
rm -rf public
hugo --minify

echo "== deploy static files =="
if [ -d "$(dirname "$DEPLOY_TARGET")" ] && [ -w "$(dirname "$DEPLOY_TARGET")" ]; then
  mkdir -p "$DEPLOY_TARGET"
  rsync -a --delete public/ "$DEPLOY_TARGET"/
else
  echo "WARN: no write permission for $DEPLOY_TARGET"
  echo "Run manually:"
  echo "  sudo mkdir -p $DEPLOY_TARGET"
  echo "  sudo chown -R \$(whoami):\$(id -gn) $(dirname "$DEPLOY_TARGET")"
  echo "  rsync -a --delete public/ $DEPLOY_TARGET/"
fi

echo "== nginx config =="
if command -v nginx >/dev/null 2>&1; then
  if [ "$(id -u)" = "0" ]; then
    mkdir -p "$(dirname "$NGINX_AVAILABLE")" "$(dirname "$NGINX_ENABLED")"
    cp "$NGINX_SOURCE" "$NGINX_AVAILABLE"
    ln -sf "$NGINX_AVAILABLE" "$NGINX_ENABLED"
    nginx -t
    if command -v systemctl >/dev/null 2>&1; then
      systemctl reload nginx || true
    fi
  else
    echo "INFO: nginx detected. To install config, run:"
    echo "  sudo cp $NGINX_SOURCE $NGINX_AVAILABLE"
    echo "  sudo ln -sf $NGINX_AVAILABLE $NGINX_ENABLED"
    echo "  sudo nginx -t"
    echo "  sudo systemctl reload nginx"
  fi
else
  echo "WARN: nginx not installed"
fi

echo "== local checks =="
test -f public/index.html
test -f public/index.xml
test -f public/index.json

echo "== live checks =="
curl -fsSI "$SITE_URL/" >/dev/null || echo "WARN: live homepage is not reachable yet: $SITE_URL/"
curl -fsSI "$SITE_URL/index.xml" >/dev/null || echo "WARN: live RSS is not reachable yet: $SITE_URL/index.xml"
curl -fsSI "$SITE_URL/index.json" >/dev/null || echo "WARN: live search index is not reachable yet: $SITE_URL/index.json"

echo "OK: restore finished"
