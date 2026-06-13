#!/usr/bin/env bash
# Auto-deploy: pull origin/main and mirror it into the www docroot.
# Installed to /usr/local/bin/cc-web-deploy.sh and run by cron every 2 min.
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
BUILD=/opt/cc-website-repo
D=$(ls -d /home/*/htdocs/www.caninecapitalfund.com)
OWN=$(stat -c '%U:%G' "$D/index.html")
cd "$BUILD"
git fetch -q origin main
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ] || [ "${1:-}" = "--force" ]; then
  git merge -q --ff-only origin/main || true
  rsync -a --delete \
    --exclude='.git' --exclude='.gitignore' --exclude='.deploy' \
    --exclude='README.md' --exclude='.well-known' \
    --exclude='*.bak' --exclude='index.html.bak-*' \
    "$BUILD/" "$D/"
  chown -R "$OWN" "$D"
  echo "$(date -u +%FT%TZ) deployed $(git rev-parse --short HEAD)" >> /var/log/cc-web-deploy.log
fi
