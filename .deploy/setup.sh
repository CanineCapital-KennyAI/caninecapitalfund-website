#!/usr/bin/env bash
# One-time setup for hands-off Git auto-deploy of www.caninecapitalfund.com.
# Run once, as root, in the Hostinger VPS Browser terminal:
#   curl -fsSL https://raw.githubusercontent.com/CanineCapital-KennyAI/caninecapitalfund-website/main/.deploy/setup.sh | bash
set -euo pipefail
REPO=https://github.com/CanineCapital-KennyAI/caninecapitalfund-website.git
BUILD=/opt/cc-website-repo

# clone (or update an existing) build checkout
if [ -d "$BUILD/.git" ]; then
  git -C "$BUILD" fetch -q origin main && git -C "$BUILD" reset -q --hard origin/main
else
  git clone -q "$REPO" "$BUILD"
fi
git config --global --add safe.directory "$BUILD"

D=$(ls -d /home/*/htdocs/www.caninecapitalfund.com)
[ -e "${D}.predeploy-bak" ] || cp -a "$D" "${D}.predeploy-bak"
echo "docroot backup: ${D}.predeploy-bak"

# install the recurring deploy script + run the first sync
install -m 0755 "$BUILD/.deploy/cc-web-deploy.sh" /usr/local/bin/cc-web-deploy.sh
/usr/local/bin/cc-web-deploy.sh --force

# install cron (every 2 min; idempotent)
( crontab -l 2>/dev/null | grep -v cc-web-deploy.sh; echo "*/2 * * * * /usr/local/bin/cc-web-deploy.sh >/dev/null 2>&1" ) | crontab -

echo "---- CRON ----"; crontab -l | grep cc-web-deploy || true
echo "---- LOG ----";  cat /var/log/cc-web-deploy.log 2>/dev/null || true
echo "---- DONE: pushes to main now auto-deploy within ~2 min ----"
