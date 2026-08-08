# Local Salesforce CLI gateway

**Localhost only. Never deploy this folder to Salesforce / Experience.**

Proxies Salesforce REST and GraphQL using your Salesforce CLI access token so the React UI Bundle can load real member API data without Experience `Site.login`.

## Prerequisites

1. Salesforce CLI installed (`sf`)
2. Logged in to the sandbox:

```bash
sf org login web --alias devjuly25a
```

## Run

From the **repo root**:

```bash
npm run local-sf
```

Default bind: `http://127.0.0.1:8787`

| Env | Default | Meaning |
|---|---|---|
| `SF_TARGET_ORG` | `devjuly25a` | CLI org alias |
| `LOCAL_SF_PORT` | `8787` | Listen port |

## Endpoints

| Path | Purpose |
|---|---|
| `GET /health` | `{ ok, username, orgId }` — no token |
| `/services/*` | Proxied to the org with `Authorization: Bearer <cli token>` |

## UI Bundle

In another terminal (from the **repo root**):

```bash
npm run local-ui
```

Open http://localhost:5173 → Login → **Continue with Salesforce CLI**.

Vite proxies `/__local_sf` → this gateway (development only).
