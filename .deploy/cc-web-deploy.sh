#!/usr/bin/env bash
# Auto-deploy: pull origin/main and mirror it into the site docroots.
# Installed to /usr/local/bin/cc-web-deploy.sh and run by cron every 2 min.
# Targets: main site (repo root) -> www docroot, plus investor/portal/borrowers/admin subdomains
# (subdomains/<name>/ -> that subdomain's docroot).
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
BUILD=/opt/cc-website-repo
cd "$BUILD"
git fetch -q origin main
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ] || [ "${1:-}" = "--force" ]; then
  git merge -q --ff-only origin/main || true

  # ── main site -> www docroot (subdomains/ stays OUT of the public www root) ──
  D=$(ls -d /home/*/htdocs/www.caninecapitalfund.com)
  OWN=$(stat -c '%U:%G' "$D/index.html")
  rsync -a --delete \
    --exclude='.git' --exclude='.gitignore' --exclude='.deploy' --exclude='subdomains' \
    --exclude='README.md' --exclude='.well-known' \
    --exclude='*.bak' --exclude='index.html.bak-*' \
    "$BUILD/" "$D/"
  chown -R "$OWN" "$D"

  # ── subdomains -> their own docroots ──
  for sub in investor portal borrowers admin; do
    SD=$(ls -d /home/*/htdocs/"$sub".caninecapitalfund.com 2>/dev/null) || continue
    [ -d "$BUILD/subdomains/$sub" ] || continue
    SOWN=$(stat -c '%U:%G' "$SD/index.html" 2>/dev/null || stat -c '%U:%G' "$SD")
    rsync -a --delete --exclude='.well-known' --exclude='*.bak' \
      "$BUILD/subdomains/$sub/" "$SD/"
    chown -R "$SOWN" "$SD"
  done

  echo "$(date -u +%FT%TZ) deployed $(git rev-parse --short HEAD)" >> /var/log/cc-web-deploy.log
fi
