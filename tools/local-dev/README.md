# Local Salesforce CLI gateway

**Localhost only. Never deploy this folder to Salesforce / Experience.**

Proxies Salesforce REST and GraphQL using your Salesforce CLI access token so the React UI Bundle can load real member API data without Experience `Site.login`.

## Prerequisites

1. Salesforce CLI installed (`sf`)
2. Logged in to the sandbox you want to proxy, and make it the CLI default:

```bash
sf org login web --alias preprod
sf config set target-org preprod
```

The gateway proxies whichever org `sf config get target-org` reports. The
project-local `.sf/config.json` wins over the global `~/.sf/config.json`, so
the default is per-developer and per-checkout. To switch orgs, change the
default and restart the gateway. The startup banner prints the org it resolved
and where it came from.

## Run

From the **repo root**:

```bash
npm run local-sf
```

Default bind: `http://127.0.0.1:8787`

| Env | Default | Meaning |
|---|---|---|
| `SF_TARGET_ORG` | CLI default (`sf config get target-org`) | One-off override of the org alias for this process |
| `LOCAL_SF_PORT` | `8787` | Listen port |

## Endpoints

| Path | Purpose |
|---|---|
| `GET /health` | `{ ok, username, orgId, targetOrg, targetOrgSource }` — no token |
| `/services/*` | Proxied to the org with `Authorization: Bearer <cli token>` |

## UI Bundle

In another terminal (from the **repo root**):

```bash
npm run local-ui
```

Open http://localhost:5173 → Login → **Continue with Salesforce CLI**.

Vite proxies `/__local_sf` → this gateway (development only).
