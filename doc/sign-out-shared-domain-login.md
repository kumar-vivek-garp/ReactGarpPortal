# Sign Out redirect to My GARP `/Login`

## One-line summary

> Logout works; on the shared Experience domain Salesforce still routes auth through My GARP’s `/Login` when other site cookies exist. Clean browser/incognito is fine. Real fix is a separate domain or retiring My GARP as the root login — not more React changes.

## Simple explanation

Several Experience Cloud apps share one domain (`garp--devjuly25a.sandbox.my.site.com`). **My GARP** (Visualforce) owns the **root** `/Login` page. The new React UI Bundle (**garpportal**) lives under `/garpportal`.

| Site | Path | Login |
| --- | --- | --- |
| My GARP | domain root | VF `/Login` |
| garpportal | `/garpportal` | React SPA `/Login` (client-side) |
| Other apps (GarpAppv1, GarpLWR, …) | their own prefixes | each site’s own config |

When a user **Sign Out** of garpportal, Salesforce ends the session via `/secur/logout.jsp`. On this **shared domain**, the platform often then sends the browser through **My GARP’s** `/Login?startURL=…`, especially in a normal tab where cookies/sessions from other apps on the same domain are still present.

**Incognito works** because the browser is clean — no leftover My GARP/session cookies — so `/garpportal` loads as a guest and the React app shows its own Login.

This is mainly a **Salesforce multi-site-on-one-domain** behavior, not a React UI bug. Changing **garpportal** Login & Registration does **not** reassign root `/Login` and does **not** affect other sites’ login settings (as long as only garpportal’s Workspaces are edited).

## What we already tried (app / site)

- Post-logout `startURL` to `/garpportal/Login` → platform bounced to My GARP `/Login`.
- Admin **Logout Page URL** on garpportal → save works, but normal-tab logout can still hit My GARP `/Login`.
- Site-prefixed `/garpportal/secur/logout.jsp` → **404** (that pattern is for LWR sites, not this React UI Bundle).
- Domain-root `/secur/logout.jsp?retURL=<absolute /garpportal/>` → correct logout shape for UI Bundle; still can bounce when shared-domain cookies exist in a normal tab.

React UI Bundle Admin → Login & Registration has **no** classic “Login Page Type” (VF / Experience Builder) picker. Login UI is the SPA; platform logout return is **Logout Page URL**.

## How to fix it

| Approach | What to do |
| --- | --- |
| **Proper (org)** | Give **garpportal** its **own custom domain**, **or** when My GARP is retired, make this app own login on the domain. |
| **Acceptable for now** | Keep React login under `/garpportal` with public guest access. Treat post-logout bounce to My GARP `/Login` as a known shared-domain limitation. |
| **Testing** | Always verify Sign Out in **incognito**, or clear cookies for `*.my.site.com` before testing in a normal tab. |

## What not to do

- Do **not** change **My GARP** → Administration → Login & Registration to point at the React app (breaks the old Angular portal and anything else using root `/Login`).
- Do **not** keep chasing this only in React if the org will not change domain / root login ownership.

## Related URLs (sandbox)

- New app: `https://garp--devjuly25a.sandbox.my.site.com/garpportal`
- Typical bad bounce after logout: `https://garp--devjuly25a.sandbox.my.site.com/Login?startURL=%2Fgarpportal%2F` (My GARP VF login)
