#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUMMARY="${1:-backup: PMReason blog baseline}"
TZ_VALUE="${TZ_VALUE:-Asia/Shanghai}"

cd "$ROOT_DIR"

export TZ="$TZ_VALUE"
TS="$(date +%Y%m%d-%H%M%S)"

echo "== verify before backup =="
bash scripts/verify.sh

echo "== write manifest =="
mkdir -p backup/manifests/generated
MANIFEST="backup/manifests/generated/blog-$TS-bj.txt"
{
  echo "PMReason Blog Backup"
  echo "time_bj=$TS"
  echo "summary=$SUMMARY"
  echo "branch=$(git branch --show-current || true)"
  echo "head_before=$(git rev-parse HEAD)"
  echo "hugo=$(hugo version)"
  echo "posts=$(find content/posts -type f -name '*.md' | wc -l | tr -d ' ')"
  echo "static_files=$(find static -type f | wc -l | tr -d ' ')"
  echo "assets_files=$(find assets -type f | wc -l | tr -d ' ')"
  echo
  echo "tracked_files:"
  git ls-files
} > "$MANIFEST"

git add -A

if git diff --cached --quiet; then
  echo "INFO: no staged changes. Creating tag for current HEAD only."
else
  git commit -m "$SUMMARY"
fi

SHORT_SHA="$(git rev-parse --short=7 HEAD)"
TAG="blog-$TS-bj-$SHORT_SHA"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "ERROR: tag already exists: $TAG" >&2
  exit 1
fi

git tag -a "$TAG" -m "$TAG: $SUMMARY"

echo "== backup version =="
echo "tag=$TAG"
echo "commit=$(git rev-parse HEAD)"
echo
echo "Push with:"
echo "  git push origin main"
echo "  git push origin $TAG"
