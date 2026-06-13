# caninecapitalfund.com — website

Source for the Canine Capital public site (**www.caninecapitalfund.com**) — static files served from a Hostinger VPS (CloudPanel) document root.

## Contents
- `index.html` — landing page
- `learn/` — the 18-page educational Library
- `disclosures.html`, `sba-lender-match.html` — standalone pages
- `og-image.png`, `canine-capital-card.*`, `og-card.html` — social share card + its template
- `robots.txt`, `sitemap.xml`

The repo root maps directly to the site document root
(`/home/<siteuser>/htdocs/www.caninecapitalfund.com/`), so a checkout of `main`
*is* the deployable site.

## Deploy
Pull-based (the VPS has SSH/port 22 closed by design; deploys must not rely on inbound SSH).
Intended path: CloudPanel Git deployment (server pulls `main`). Until that's wired,
files are updated via the CloudPanel File Manager.

## Not in this repo
Local tooling (`cc-shot.py`, `csp-test.py`), scratch backups, and the
`investor.` / `portal.` subdomain sites (deployed separately).
