# Local CLI development (never in production)

Use your Salesforce CLI admin session to call real sandbox APIs from localhost without Experience `Site.login`.

## Does this affect other Experience apps?

**No.** This is a local Node process + Vite DEV proxy only. Do not change Digital Experiences Login & Registration.

## Prerequisites

1. Salesforce CLI (`sf`)
2. Org login, then make that org the CLI default:

```bash
sf org login web --alias preprod
sf config set target-org preprod
```

The gateway proxies the CLI default org (`sf config get target-org`), so
switching between sandboxes is `sf config set target-org <alias>` plus a
gateway restart. The startup banner prints which org it resolved.

## Run (two terminals)

**Terminal 1 — gateway (repo root):**

```bash
npm run local-sf
```

Expect: `listening on http://127.0.0.1:8787`, `target org: <alias> (…)` and `authenticated as …`

**Terminal 2 — UI Bundle (repo root):**

```bash
npm run local-ui
```

Open http://localhost:5173 → **Continue with Salesforce CLI**.

## What works / what does not

| | Local CLI gateway | Experience site |
|---|---|---|
| Member REST (`/memberportal/*`) | Yes (via CLI token) | Yes (session cookie) |
| GraphQL `currentUser` | Yes (usually your **admin** user) | Community member |
| `Site.login` / shared Experience logout | No — bypassed | Yes — use deployed URL |

Real Sign In / Sign Out / shared session with other apps: still test on

`https://garp--devjuly25a.sandbox.my.site.com/garpportal`

## Production safety

- Gateway code lives in `tools/local-dev/` (not deployed with the UI Bundle).
- Binds `127.0.0.1` only.
- React path is `import.meta.env.DEV && localhost` only.
- Production `vite build` must not include `/__local_sf` usage (verify after build).

## Env

| Variable | Default | Meaning |
|---|---|---|
| `SF_TARGET_ORG` | CLI default (`sf config get target-org`) | One-off override of the org alias for this process |
| `LOCAL_SF_PORT` | `8787` | Gateway port |

## No Apex required for basic Continue

Basic **Continue with Salesforce CLI** uses the org `DEV_FALLBACK_CONTACT` without headers.

Contact picker + `X-GARP-Dev-Contact` override: see [local-dev-contact-picker.md](./local-dev-contact-picker.md) (deploy Apex change to the sandbox for Phase 2).
