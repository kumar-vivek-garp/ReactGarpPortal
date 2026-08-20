# Route parity — MyGarp (legacy) vs garp_portal (React rewrite)

**Purpose:** A route-by-route inventory of the legacy member portal versus the new `garpportal` UI Bundle, so it is unambiguous which screens are **done**, which are **folded into a tab**, which are **deliberately handed back to legacy**, and which are **genuinely missing**.

**Per [`legacy-rewrite.md`](../.claude/rules/legacy-rewrite.md):** MyGarp is the source of truth for **screens, copy, fields, and user flows**. This document is the screen/flow inventory half of that rule. It is deliberately *not* an API plan — endpoint availability lives in [`programs-comparison-mygarp-garpappv1-garpportal.md`](./programs-comparison-mygarp-garpappv1-garpportal.md) and [`programs-detail-phase-b-mapping.md`](./programs-detail-phase-b-mapping.md).

---

## 1. Where the routes actually come from

MyGarp has **no LWC and no Aura** — `force-app/main/default/lwc/`, `aura/`, `flexipages/`, and `applications/` are all empty. The portal is two Angular SPAs shipped as static resources and mounted by Visualforce pages:

| App | Static resource | VF page | Router | Base URL shape |
|-----|-----------------|---------|--------|----------------|
| **garpApp2** | `staticresources/garpApp2/` (ships `main.js.map`) | `pages/garpApp2.page` | Angular `RouterModule.forRoot` | `<base href="./garpapp2">` → path routing, e.g. `/garpapp2/dashboard` |
| **garpApp** | `staticresources/garpApp/` | `pages/garpApp.page` | Angular | same shape, **older build** of garpApp2 |
| **sfdcApp** | `staticresources/sfdcApp_extracted/` | `pages/sfdcApp.page` | AngularJS `ui-router` | hash routing, e.g. `/sfdcApp#!/myprograms/frm` |

Route inventories in this doc were extracted from ground truth, not inferred:

- **garpApp2** — original `src/app/app-routing.module.ts` recovered from `main.js.map`'s `sourcesContent` (46 route entries).
- **garpApp** — `path:"…"` literals in the minified `main.js` (27 entries; a strict subset of garpApp2 minus the whole `registration/*` tree).
- **sfdcApp** — `state("…",{url:"…"})` definitions in `build/main.min.js` (~110 states).
- **garp_portal** — `src/routeTree.gen.ts` plus each page's `validateSearch` schema in `src/config/*.ts`.

**garpApp2 is the current generation** and the only fair peer for the rewrite. sfdcApp is the older app that garpApp2 has not fully replaced — garpApp2 itself, and now garp_portal, still deep-link into it for registration, checkout, and legacy program detail.

---

## 2. Executive summary

| | Count |
|---|---|
| garpApp2 routes (incl. redirects and wildcard) | **46** |
| garp_portal routes | **12** (8 feature screens + `/`, `/Login`, program-detail param, nested order detail, and legacy `/order-details` redirect) |
| Legacy screens **fully rebuilt** | 9 |
| Legacy screens **rebuilt as a tab** on another route | 4 |
| Legacy screens **intentionally deep-linked back** to MyGarp | 4 |
| Legacy screens with **no equivalent at all** | **9** |

**Sidebar parity is exact.** garpApp2's `side-nav.component.html` links to `/dashboard`, `/programs`, `/study-materials`, `/membership`, `/events`, `/help-center`, plus a profile row to `/my-account`. `SIDE_NAV_ITEMS` in [side-nav-items.ts](force-app/main/default/uiBundles/garpportal/src/config/navigation/side-nav-items.ts) is the same six, same order, same labels. **Every primary-navigation destination is built.**

**The gap is entirely below the sidebar** — routes legacy reached from dashboard cards, in-page CTAs, and secondary tabs. The three material clusters are **CPD** (4 routes), **Work Experience** (4 routes), and the **registration/checkout wizard** (19 routes, deliberately still legacy). Two smaller ones: **Exam Results** and **Study Materials Archive**. Order History + Order Detail are rebuilt (list folded into My Account; detail nested under `/my-account/orders/…`).

---

## 3. Full route mapping

Status key: **✅ Done** · **🔀 Folded into a tab** · **↗️ Deep-links to legacy (by design)** · **❌ Missing**

### 3.1 Core routes

| # | garpApp2 route | Screen | garp_portal | Status |
|---|----------------|--------|-------------|--------|
| 1 | `''` → `/dashboard` | Root redirect | [`/`](force-app/main/default/uiBundles/garpportal/src/pages/index.tsx) → `/dashboard` | ✅ Done |
| 2 | `dashboard` | Home | [`/dashboard`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/dashboard/index.tsx) | ✅ Done |
| 3 | `programs` | Programs listing | [`/programs`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/programs/index.tsx) — tabs `all` / `in-progress` / `completed` / `explore`, `?view=` grid/list | ✅ Done |
| 4 | `programs/:program` | Exam / program detail | [`/programs/$programType`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/programs/$programType/index.tsx) | ✅ Done — read-only; in-app for `frm`/`erp`/`scr`/`raij`/`riskai` only |
| 5 | `study-materials` | Study materials | [`/study-materials`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/study-materials/index.tsx) | ✅ Done |
| 6 | `study-materials-type/:program` | Program-filtered materials | `/study-materials?tab={program}` — `tab` is a free-form program key | 🔀 Folded (param → search param) |
| 7 | `events` | My Events | [`/events`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/events/index.tsx) — tabs `all` / `attending` / `chapter-meetings` / `featured` | ✅ Done (superset of legacy's 2 tabs) |
| 8 | `membership` | Membership benefits | [`/membership`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/membership/index.tsx) `?tab=benefits` | ✅ Done |
| 9 | `member-resources` | Alias of `membership` | `/membership` | ✅ Done (alias not needed) |
| 10 | `member-directory` | Member directory | `/membership?tab=directory` | 🔀 Folded — matches legacy's own tab-row, which routed `member-directory` from the Membership tab bar |
| 11 | `member-directory-search/:searchtext` | Pre-seeded directory search | — | ❌ Missing (see §4.6) |
| 12 | `help-center` | Help center | [`/help-center`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/help-center/index.tsx) — tabs `get-help` / `requests` | ✅ Done |
| 13 | `my-account` | Account settings | [`/my-account`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/my-account/index.tsx) — tabs `account-information` / `contact-preferences` / `order-history` | ✅ Done (superset — legacy had 2 tabs) |
| 14 | `purchase-history` | Purchase history | `/my-account?tab=order-history`, `?orders=all\|unpaid\|paid` | 🔀 Folded — legacy's own `my-account` tab row navigated here |
| 15 | `order-details/:orderNumber` | Order detail | [`/my-account/orders/$orderNumber`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/my-account/orders/$orderNumber/index.tsx) — legacy `/order-details/$orderNumber` redirects here | ✅ Done |
| 16 | `programs/exam-setup/:program` | Exam setup wizard | `programExamSetupHref()` | ↗️ Deep-link — **but see §5.1, the URL looks wrong** |
| 17 | `exam-results` | Exam results listing | — | ❌ Missing (see §4.3) |
| 18 | `errata/:programType` | Errata submission | Program detail rail links to `garp.org/{program}` marketing instead | ❌ Missing (see §4.7) |
| 19 | `study-materials-archive` | Archived eBooks | — | ❌ Missing (see §4.4) |
| 20 | `cpd` | CPD home | — | ❌ Missing (see §4.1) |
| 21 | `cpd-activities` | CPD activities list | — | ❌ Missing (see §4.1) |
| 22 | `cpd-activities-detail/:activityId` | CPD activity detail | — | ❌ Missing (see §4.1) |
| 23 | `work-experience` | Work experience home | — | ❌ Missing (see §4.2) |
| 24 | `work-experience/manage/:programType` | Manage entries | — | ❌ Missing |
| 25 | `work-experience/manage/addresses/:programType` | Submit addresses | — | ❌ Missing |
| 26 | `work-experience/manage/addresses/review/:programType` | Review + submit | — | ❌ Missing |
| 27 | `**` → `/dashboard` | Catch-all | No `notFoundComponent`; TanStack default | ⚠️ Minor gap (see §5.3) |

### 3.2 Registration / checkout wizard (19 routes)

All 19 are `RegistrationFormComponent` + a per-program child form, plus a shared 3-step flow (form → survey → completed).

| garpApp2 routes | garp_portal | Status |
|-----------------|-------------|--------|
| `registration/frm`, `/scr`, `/rai`, `/ffr`, `/frr`, `/frr25`, `/membership` (each also `/:regCode`) — 14 routes | `programRegistrationHref()` → `/sfdcApp#!/registration/{slug}` | ↗️ Deep-link, **by design** |
| `registration/micro/:courseCode`, `…/:regCode` | `programRegistrationHref(…, isMicroCourse)` → `/sfdcApp#!/registration/micro/{code}` | ↗️ Deep-link |
| `registration/survey`, `registration/information` | — | ↗️ Reached inside the legacy wizard |
| `registration/completed` | — | ↗️ Reached inside the legacy wizard |

**This is a deliberate architectural decision, not a gap.** Registration is payment-bearing checkout; the new Apex REST stack has no registration write API. `program-card-links.ts` documents the handoff explicitly. Every one of these sfdcApp targets was verified to exist in `build/main.min.js` — the registration deep-links are correct.

### 3.3 garp_portal routes with no garpApp2 equivalent

| garp_portal route | Note |
|-------------------|------|
| [`/Login`](force-app/main/default/uiBundles/garpportal/src/pages/_authLayout/Login/index.tsx) (`?startUrl=`) | Legacy auth is the Visualforce `Login.page` + Experience Cloud, outside the Angular router. Correct that this is new. |
| [`/my-account/orders/$orderNumber`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/my-account/orders/$orderNumber/index.tsx) | Rewrite IA — legacy used a top-level `order-details/:orderNumber`. Nested under My Account to match folded purchase history. |
| [`/order-details/$orderNumber`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/order-details/$orderNumber/index.tsx) | Replace-redirect → `/my-account/orders/$orderNumber` for bookmarks / older links. |
| `_appLayout` / `_authLayout` | Pathless layout routes (auth guard + shell). Structural, not user-facing. |

### 3.4 sfdcApp (older AngularJS app) — context only

sfdcApp holds ~110 ui-router states. garpApp2 never replaced most of them, so they are **not** rewrite scope. They matter here only because garp_portal deep-links into four of them. Notable states garpApp2 also lacks: `cpe_credits`, `cpe_activities`, `settings_profile` / `settings_directory` / `settings_chapters` / `settings_membership`, `public_directory`, `secure_checkout`, `payorder-checkout/:orderId`, `myprograms/*`, `exam_results`, `errata/:regType`, `multimedia`, `risk_net`, `volunteer`, `notifications`.

---

## 4. What is actually missing — detail

Sections marked ✅ were gaps at first inventory and have since been rebuilt; kept here so the original numbering and rationale stay searchable.

### 4.1 CPD (Continuing Professional Development) — 4 routes 🔴 largest gap

**Legacy:** `cpd`, `cpd-activities`, `cpd-activities-detail/:activityId`. Components under `pages/cpd-home/` and `pages/cpd-activities/`: cycle chart, certificate dialog, add/edit/view/delete activity dialogs, activities table with filter + sort. A `cpd-card` also sits on the legacy dashboard, and the legacy side-nav component carries a `hasCPDProgram` flag.

**garp_portal:** Zero. Only outbound `garp.org/cpd` marketing links in the footer/mega-menu.

**Why it matters:** CPD is a full CRUD surface (members log activities, upload evidence, download a certificate), not a read-only page. It is the single biggest missing feature area and needs write APIs before UI work starts.

### 4.2 Work Experience — 4 routes 🔴

**Legacy:** `work-experience` plus a 3-step `manage/…` flow (entries → addresses → review). Components include add/delete dialogs, a drop-box uploader, and an attachments dialog. This is the FRM certification requirement flow.

**garp_portal:** Zero — no route, no component, no API domain. The string does not appear anywhere in `src/`.

**Why it matters:** File upload + multi-step submission with a review gate. Blocking for FRM candidates completing certification.

### 4.3 Exam Results — 1 route 🟡

**Legacy:** `exam-results` → `ExamResultsListingComponent`, with `exam-result-card` and a `quartile-chart` per attempt.

**garp_portal:** No route. `examResult` appears only as a field in `api/programs/types.ts`, so **some result data already arrives** with program detail. A listing page is likely a presentation-layer task rather than a new backend integration — worth confirming against the Apex payload.

### 4.4 Study Materials Archive — 1 route 🟡

**Legacy:** `study-materials-archive` → archived eBook list, reached from a "View Archive" button on the study materials page.

**garp_portal:** No route and no "archive" reference anywhere in the study-materials panel or API. The current page shows only the live catalogue.

### 4.5 Order Details — 1 route ✅ done

**Legacy:** `order-details/:orderNumber`, reached from purchase history, membership, **and** study materials / program unpaid CTAs.

**garp_portal:** Nested under My Account as [`/my-account/orders/$orderNumber`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/my-account/orders/$orderNumber/index.tsx) (list remains `/my-account?tab=order-history`). Top-level `/order-details/$orderNumber` replace-redirects to the nested path for bookmarks.

| Concern | Implementation |
|---------|----------------|
| Load | `GET …/memberportal/orderDetail?orderNumber=` via `sdk.fetch` |
| Pay | `POST …/payOrder` → Stripe checkout URL + session cookie (same as legacy) |
| Cancel | `POST …/cancelOrder` — UI gated with `canPay` (REST has no `canCancel`) |
| Invoice | VF `/apex/InvoicePrintAsPDF?id=` |
| Entry points | Order History rows, membership “View Order”, `programOrderHref()` |
| Status tones | `order-status.ts` maps Paid / Unpaid / Recurring / Stopped / etc. onto shared `StatusTone` badges |

**Known limits vs legacy (accepted):** detail is summary-only (no line items); no AliPay-specific flags from the current Apex payload.

### 4.6 Member Directory deep search — 1 route 🟢

**Legacy:** `member-directory-search/:searchtext` pre-seeds the directory search from a URL, so dashboard/email links can land on results.

**garp_portal:** `/membership?tab=directory` renders `DirectorySearch`, but search text is component state — not a URL search param. Low effort: add `q` to `membershipSearchSchema`. Worth doing for shareable/bookmarkable results.

### 4.7 Errata — 1 route 🟢

**Legacy:** `errata/:programType` → in-app errata submission form (also an sfdcApp state, `errata/:regType`).

**garp_portal:** [program-detail-rail.tsx:238](force-app/main/default/uiBundles/garpportal/src/components/molecules/program-detail-rail.tsx#L238) renders a "Submit Errata" row, but its href falls back to `programLearnMoreUrl()` → `https://www.garp.org/{program}` — the **marketing overview page, not an errata form**. Functionally a dead end for the user's stated intent. Cheapest correct fix is to point it at the legacy errata route rather than build the form.

---

## 5. Verification items found while mapping

These are not "missing routes" — they are existing garp_portal links whose targets do not match any route in either legacy app. Each should be clicked through in a sandbox before the next release.

### 5.1 `programExamSetupHref()` builds a URL that matches no legacy route

[program-card-links.ts](force-app/main/default/uiBundles/garpportal/src/lib/program-card-links.ts) builds `/sfdcApp#!/programs/exam-setup/{slug}`. Its own comment says the path comes from **garpApp2** — but it is passed through `myGarpSfdcAppHref()`, which targets **sfdcApp**. The two apps do not share a route table:

- garpApp2's route is `programs/exam-setup/:program`, and garpApp2 uses **path** routing under `<base href="./garpapp2">` → the real URL is `/garpapp2/programs/exam-setup/frm`, not a `#!` hash.
- sfdcApp has **no** `programs/exam-setup` state. Its equivalent is `myprograms-setup` → `/myprograms/setup/:examType/:examAttemptId` (note: it also requires an `examAttemptId`).

This is live in the UI via [program-exam-overview.tsx:111](force-app/main/default/uiBundles/garpportal/src/components/molecules/program-exam-overview.tsx#L111) and [program-detail-presentation.ts:113](force-app/main/default/uiBundles/garpportal/src/lib/program-detail-presentation.ts#L113).

### 5.2 `programOrderHref()` — ✅ fixed

Previously built `/sfdcApp#!/order/{id}` (no matching sfdcApp state). Now resolves in-app via [`orderDetailsPath()`](force-app/main/default/uiBundles/garpportal/src/lib/order-paths.ts) → `/my-account/orders/{id}` (Opportunity Id or invoice #). Still used from [program-exam-overview.tsx](force-app/main/default/uiBundles/garpportal/src/components/molecules/program-exam-overview.tsx) and [program-detail-presentation.ts](force-app/main/default/uiBundles/garpportal/src/lib/program-detail-presentation.ts).

### 5.3 No catch-all route

garpApp2 sends `**` → `/dashboard`. garp_portal defines no `notFoundComponent`, so an unknown path falls to TanStack Router's default. A member following a stale legacy bookmark (`/cpd`, `/work-experience`, `/purchase-history`) gets a framework default instead of a redirect. Adding a root-level not-found that redirects to `/dashboard` restores legacy behavior and covers every ❌ row in §3.1 at once.

---

## 6. Suggested order of work

| Priority | Item | Rationale |
|----------|------|-----------|
| **P0** | Fix §5.1 exam-setup deep-link URL | Still a live CTA on program detail that points at a non-existent sfdcApp route. |
| **P0** | Add catch-all → `/dashboard` (§5.3) | One route. Makes every unbuilt legacy bookmark degrade gracefully. |
| **P1** | Point "Submit Errata" at the real errata flow (§4.7) | The link currently lands on marketing copy, which reads as working but isn't. |
| **P1** | Exam Results listing (§4.3) | `examResult` data already flows through `api/programs`; likely presentation-only. Confirm the payload first. |
| **P2** | Study Materials Archive (§4.4) | Self-contained, one route, one list. |
| **P2** | Directory search in the URL (§4.6) | Add `q` to `membershipSearchSchema`; makes results shareable. |
| **P3** | Work Experience (§4.2) | 4 routes, file upload, multi-step review. Needs write + upload APIs — scope with backend first. |
| **P3** | CPD (§4.1) | 4 routes, full CRUD, certificate generation. Largest area; needs its own API scoping pass. |
| **✅** | Order Details (§4.5) + `programOrderHref` (§5.2) | Nested `/my-account/orders/$orderNumber`; pay / cancel / invoice wired; unpaid program CTAs go in-app. |
| **—** | Registration / checkout (§3.2) | Stays in legacy until a registration write API exists. Per `legacy-rewrite.md`, do not synthesize this on the client. |

**Before starting any P2/P3 item:** run the `legacy-rewrite.md` sequence — confirm the flow in MyGarp, then check GarpAppv1 for an existing REST endpoint. If MyGarp shows the flow and GarpAppv1 has no matching API, that is a stop-and-report, not a GraphQL join.
