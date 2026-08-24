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
| garp_portal routes | **15** (feature screens + `/`, `/Login`, program-detail, nested program exam results, nested order detail, `/cpd`, `/cpd/activities`, and legacy `/order-details` redirect) |
| Legacy screens **fully rebuilt** | 13 |
| Legacy screens **rebuilt as a tab or folded** into another route | 5 |
| Legacy screens **intentionally deep-linked back** to MyGarp | 4 |
| Legacy screens with **no equivalent at all** | **5** |

**Sidebar parity is exact, plus one deliberate addition.** garpApp2's `side-nav.component.html` links to `/dashboard`, `/programs`, `/study-materials`, `/membership`, `/events`, `/help-center`, plus a profile row to `/my-account`. `SIDE_NAV_ITEMS` in [side-nav-items.ts](force-app/main/default/uiBundles/garpportal/src/config/navigation/side-nav-items.ts) is the same six, same order, same labels. **Every primary-navigation destination is built.** A seventh row, **CPD Credits**, is spliced in after Programs for members whose `hasCPDProgram` is true — legacy reached CPD only from a dashboard card, but it carried the same flag on its own side-nav component.

**The gap is entirely below the sidebar** — routes legacy reached from dashboard cards, in-page CTAs, and secondary tabs. The remaining clusters are **Work Experience** (4 routes — UI effort only; see the §4.2 correction) and the **registration/checkout wizard** (19 routes, deliberately still legacy). **CPD is complete** across all four legacy routes. Smaller remaining gaps: **Study Materials Archive**, plus low-effort **Errata** link fix and **directory search URL**. Order History + Order Detail are rebuilt (list folded into My Account; detail nested under `/my-account/orders/…`). **Exam Results** is rebuilt under `/programs/$programType/results` (program-scoped, not legacy’s flat `/exam-results`).

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
| 17 | `exam-results` | Exam results listing | [`/programs/$programType/results`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/programs/$programType/results/index.tsx) — program-scoped; listing card + program-detail CTA | ✅ Done (see §4.3) |
| 18 | `errata/:programType` | Errata submission | Program detail rail links to `garp.org/{program}` marketing instead | ❌ Missing (see §4.7) |
| 19 | `study-materials-archive` | Archived eBooks | — | ❌ Missing (see §4.4) |
| 20 | `cpd` | CPD home | [`/cpd`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/cpd/index.tsx) | ✅ Done — read + writes (Phases A/B); write path unverified, see §4.1 |
| 21 | `cpd-activities` | CPD activities list | [`/cpd/activities`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/cpd/activities/index.tsx) — `?type=&area=&provider=&sort=&page=` | ✅ Done (Phase C) |
| 22 | `cpd-activities-detail/:activityId` | CPD activity detail | Details expand in the card; "Submit Credits" opens the pre-filled claim form | 🔀 Folded — a deep-link route for one catalogue row earned nothing the card does not |
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
| [`/programs/$programType/results`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/programs/$programType/results/index.tsx) | Rewrite IA — legacy used a top-level `exam-results` that every Part I / Part II / “See All” link hit. Nested under the program so FRM vs SCR land on different pages; payload filtered client-side from member-wide `examResults`. |
| `_appLayout` / `_authLayout` | Pathless layout routes (auth guard + shell). Structural, not user-facing. |

### 3.4 sfdcApp (older AngularJS app) — context only

sfdcApp holds ~110 ui-router states. garpApp2 never replaced most of them, so they are **not** rewrite scope. They matter here only because garp_portal deep-links into four of them. Notable states garpApp2 also lacks: `cpe_credits`, `cpe_activities`, `settings_profile` / `settings_directory` / `settings_chapters` / `settings_membership`, `public_directory`, `secure_checkout`, `payorder-checkout/:orderId`, `myprograms/*`, `exam_results`, `errata/:regType`, `multimedia`, `risk_net`, `volunteer`, `notifications`.

---

## 4. What is actually missing — detail

Sections marked ✅ were gaps at first inventory and have since been rebuilt; kept here so the original numbering and rationale stay searchable.

### 4.1 CPD (Continuing Professional Development) — 4 routes ✅ done

**Legacy:** `cpd`, `cpd-activities`, `cpd-activities-detail/:activityId`. Components under `pages/cpd-home/` and `pages/cpd-activities/`: cycle chart, attestation dialog, add/edit/view/delete activity dialogs, activities table with filter + sort. A `cpd-card` also sits on the legacy dashboard, and the legacy side-nav component carries a `hasCPDProgram` flag.

**The API is already there.** An earlier revision of this section said CPD "needs write APIs before UI work starts." That was wrong. `GARP_Portal_API` already exposes the whole surface, and the four `GARP_Portal_Cpd*Service` classes are byte-identical in GarpAppv1 and MyGarp — deployed code, not a test-repo prototype. Every one of the seven CPD calls garpApp2 makes has a port:

| garpApp2 (`garpAppRemoter`) | New endpoint |
|---|---|
| `getComponentCPDInfo(loadKey)` | `GET cpd` |
| `getCPDListingInfo()` | `GET cpdProgram` + `cpdActivityTypes` + `options` (composite) |
| `getCPDClaimFormInfo()` | `GET cpdActivityTypes` + `options` (composite) |
| `setCPDClaimInfo(claim)` | `POST cpdClaim` |
| `deleteCPDClaim(claimId)` | `POST cpdClaimDelete` |
| `setCPDAttestation(id)` | `POST cpdAttest` |
| `getCPDActivitiesBrowseFormInfo(...)` | `GET cpdActivities` |

**Do not port two of them.** `setCPDActivityAsClaim` has a remoter wrapper but zero component callers, and `getFeaturedCPDActivitiesInfo` is commented out in the legacy itself ([`GARP_BC_MemberPortal.cls:1412`](../../MyGarp/force-app/main/default/classes/GARP_BC_MemberPortal.cls)).

**CPD has no file upload.** An earlier revision said members "upload evidence." No legacy CPD template contains a file input — that is Work Experience / CV (§4.2).

**garp_portal:** **Phases A and B shipped.** [`/cpd`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/cpd/index.tsx) has the cycle picker (`?cycle=`), credit bars, pending/approved activity tables, certificates, a dashboard CPD card, and a `hasCPDProgram`-gated sidebar item — the app's first conditional nav row. Phase B added the writes: add/edit, view, delete, and the two-checkbox attestation that unlocks certificate downloads. Phase C added [`/cpd/activities`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/cpd/activities/index.tsx) — Browse Credit Opportunities, with server-side paging, sort and facets all carried in the URL, and "Submit Credits" pre-filling the Phase B form. **All four legacy CPD routes now have an equivalent.**

> ⚠️ **The write path and the catalogue have never been exercised against real records.** The `devjuly25a` sandbox holds **zero `CPE_Activity_Type__c` and zero `CPE_Claim__c` rows** (verified by SOQL 2026-08-21), so `GET cpdActivityTypes` correctly returns `[]` and the Add Credits form cannot be completed — it renders an "Activity types are unavailable" state instead. What *is* verified live: the dialog opens, `cpdActivityTypes` and `options` fetch lazily on open, and the 21 Area of Study picklist values load. What is **not**: the dynamic `showFields` mechanism, create/edit/delete/attest against Apex, and in particular **whether Apex accepts the `cpdClaim` body shape** — that was built by reading `ClaimInput` and is covered only by unit tests against a mocked SDK. One successful save would settle it.
>
> Phase C is in a better position: `CPE_Activity__c` is also empty (0 rows), so no catalogue row has ever rendered, **but its request contract is verified against live Apex** — `GET cpdActivities` accepts the serialized params (`activityTypes=A;B`, `sortOrder`, `pageSize`, `pageCurrent`), answers 200, and returns `sortOptions` exactly matching the four labels in `CPD_SORT_OPTIONS`. What is unverified there is rendering: activity cards, the pagination control (needs >20 rows), and facet checkboxes (needs facet values).
>
> Seed `CPE_Activity_Type__c` (with `*_Label_Text__c` populated, since those drive the dynamic fields), `CPE_Activity__c`, and a few `CPE_Claim__c` rows to exercise the rest.

**Reviewed against the backend team's own port (2026-08-22).** Endpoint names, query params and POST body shapes match theirs exactly. Three things came out of that review and are now applied here:

- **A 401 is matched on the payload, not the status.** Apex answers a refusal with its own code *plus* the reason (`data.statusCode: 401`, `errorMessage: "CPD Contract not found"`), while a request that could not run — an expired session above all — answers the same 401 with an empty `data`. Our first cut keyed on the status alone, so a signed-out member would have been shown "no CPD programme" instead of an error. `memberPortalRefusalPayload()` in `api/client/` now discriminates the two; the idea is lifted from their transport's `isEmptyPayload` check. Other domains can adopt it as needed.
- **`/programs` no longer carries rail cards at all.** Legacy puts a CPD card, an Exam Notifications card and an Exam Results card in a right-hand rail. The CPD one is redundant here — legacy had no CPD entry in its side nav, whereas ours is permanent and gated on the same `hasCPDProgram` flag. The Exam Results card was a ~280px preview of rows the member leaves the page to read, capped at two, and every element in the legacy version pointed at the same flat `/exam-results` — a route this rewrite deliberately does not have. Both were replaced by a **"Results" chip in each programme card's badge row**, springing in once `examResults` resolves and deep-linking to that programme's own `/programs/$programType/results`. It costs no page height, needs no rule about which tabs may show it, and surfaces *more* than the card did: a member with FRM, RAIJ and SCR results saw only the first two in the old preview.
- **Still missing from `/programs`: the Exam Notifications rail card** (`newNotification`). We consume `examNotifications` only on program detail. Not ported; recorded here so it is not mistaken for parity.
- **The handbook URL now prefers a server value.** `cpdProgram` does not return `cpdHandbookURL` yet — the legacy hardcoded it in `GARP_BC_MemberPortal.getCPDListingInfo` — so `CPD_HANDBOOK_URL` stands in as a fallback and the payload wins the moment Apex sends one. The backend port disabled the button outright over this; worth agreeing on one answer.

**Two things to carry forward:**

- **RAI credits legitimately disagree.** `GET cpd` requires 10, `GET cpdProgram` requires 20, because `GARP_BC_MemberPortal` and `GARP_BC_CPD` disagree and both ports reproduce it deliberately. The rewrite reproduces it too. Do not "fix" one side — aligning them in the new portal alone would make the two portals disagree while both are live. Pinned by tests in `lib/cpd-presentation.test.ts`.
- **The write endpoints return HTTP 200 on failure.** `SaveResult` carries no `statusCode`, so a refused write comes back `200` with envelope `status: "Success"` and `data.status: "Failed"`. Phase B must inspect `data.status` and throw, or "Claim not found" is swallowed. Send dates as ISO `yyyy-MM-dd`.

### 4.2 Work Experience — 4 routes 🔴

**Legacy:** `work-experience` plus a 3-step `manage/…` flow (entries → addresses → review). Components include add/delete dialogs, a drop-box uploader, and an attachments dialog. This is the FRM certification requirement flow.

**garp_portal:** Zero — no route, no component, no API domain. The string does not appear anywhere in `src/`.

> ⚠️ **Correction (2026-08-23): this is NOT API-blocked.** Earlier revisions of this section — and of §6 — said Work Experience "needs write + upload APIs, scope with backend first." That was wrong, and it is the most expensive error in this file: it would send someone to scope APIs that already exist.
>
> The **"Certification CV"** endpoints in `GARP_Portal_API` *are* the Work Experience flow. They were listed in the API header the whole time and simply were not connected to the feature name:
>
> | Read | Write |
> |---|---|
> | `GET cv?programType=FRM\|ERP` | `POST cvExperience` |
> | `GET cvExperience?programType=&experienceId=` | `POST cvExperienceDelete` |
> | `GET cvAttachments?experienceId=` | `POST cvAddress` |
> | `GET cvAttachmentDownload?attachmentId=` | `POST cvSubmit` |
> | | `POST cvDocumentRequirement` |
> | | `POST cvAttachment { experienceId, fileName, fileText }` ← **the base64 upload** |
> | | `POST cvAttachmentDelete` |
>
> The backend team's own React port lists all four Work Experience routes as **Ported** ([garpapp Route Atlas](./backend-artifact.md)), which is independent evidence the endpoints work. Their atlas also documents legacy bugs their port fixed and ours would otherwise inherit: the legacy route carries no `:programType`, so it calls the service with an empty string and every CTA builds a broken URL; there is no branch for an approved CV, so a certified member sees an empty card; and the address step applies each country's postal rules in a loop, so the last country in the list wins rather than the selected one.

**Why it matters:** File upload + multi-step submission with a review gate. Blocking for FRM candidates completing certification — but blocked on **UI effort only**, not on backend work.

### 4.3 Exam Results — 1 route ✅ done

**Legacy:** Top-level `exam-results` → flat list of all attempts. Dashboard / programs “Exam Results” card linked Part I, Part II, and “See All” to that **same** page.

**garp_portal:** Program-scoped [`/programs/$programType/results`](force-app/main/default/uiBundles/garpportal/src/pages/_appLayout/programs/$programType/results/index.tsx) (chrome matches program detail: back to `/programs/$programType`, brand hero, summary counts, rich result cards). Intentionally **not** a 1:1 clone of legacy’s sparse list UI.

| Concern | Implementation |
|---------|----------------|
| Load | `GET …/memberportal/examResults` via `sdk.fetch` (`api/exam-results/`) |
| Filter | Client-side by program slug (`frm` / `scr` / `riskai` / …) from the member-wide Apex list |
| Mark viewed | Silent `POST …/examResultViewed` once released rows are shown |
| Card content | Outcome `StatusBadge`, message, expected release date, quartile bars, results letter + performance PDF (`resolveExperienceHref`), in-app `/help-center` link when needed |
| Entry points | Programs listing preview when `hasExamResults`; program detail “View Exam Results” (`programResultsPath` / `viewExamResults` action); completed programs get it as a secondary CTA |

**Audited against the backend team's atlas (2026-08-23).** Two legacy defects checked:

- **Results letter hidden behind the quartile gate** — in legacy the "View Exam Results Letter" button sits *inside* the quartile block, so a result with a letter but no quartiles offers no way to read it. **We did not inherit this**: `resultsLetterHref` renders in its own footer conditional, independent of `showQuartiles`.
- **"Contact member services" was a `mailto:`** — legacy routes it to `/help-center`, which is where a case is actually raised. Now fixed: it is an in-app `Link` to `/help-center`. The gate itself already matched legacy (violation / notGraded / noShow). The backend team's port flags the same `mailto:` divergence as an open gap in their own audit.

**Known limits vs legacy (accepted):** no top-level `/exam-results` bookmark redirect yet (§5.3 catch-all still covers unknown paths poorly); staff `?loadKey=` preview is not exposed in the UI.

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
| **P0** | Add catch-all → `/dashboard` (§5.3) | One route. Makes every unbuilt legacy bookmark degrade gracefully (incl. stale `/exam-results`). |
| **P1** | Point "Submit Errata" at the real errata flow (§4.7) | The link currently lands on marketing copy, which reads as working but isn't. |
| **P2** | Study Materials Archive (§4.4) | Self-contained, one route, one list. |
| **P2** | Directory search in the URL (§4.6) | Add `q` to `membershipSearchSchema`; makes results shareable. |
| **P2** | Work Experience (§4.2) | 4 routes, file upload, multi-step review. **Not API-blocked** — the `cv*` endpoints are the whole flow, including a base64 upload (see the correction in §4.2). UI effort only. |
| **✅** | CPD Phase A (§4.1) | Read-only `/cpd`, dashboard card, gated sidebar row. |
| **✅** | CPD Phase B (§4.1) | Add/edit, view, delete, attestation. **Write path unverified — no sandbox data.** |
| **✅** | CPD Phase C (§4.1) | `/cpd/activities` browser. Request contract verified live; rendering unverified — no sandbox data. |
| **✅** | Exam Results (§4.3) | Nested `/programs/$programType/results`; `examResults` + `examResultViewed`; listing preview + detail CTA. |
| **✅** | Order Details (§4.5) + `programOrderHref` (§5.2) | Nested `/my-account/orders/$orderNumber`; pay / cancel / invoice wired; unpaid program CTAs go in-app. |
| **—** | Registration / checkout (§3.2) | Stays in legacy until a registration write API exists. Per `legacy-rewrite.md`, do not synthesize this on the client. |

---

## 7. Dashboard manifest is unconsumed (found 2026-08-22, not CPD)

`GET dashboard` returns `dashboardComponents: [{name, rankOrder}]` — verified live:

```json
"dashboardComponents":[{"rankOrder":1,"name":"Enrolled Programs"},
                       {"rankOrder":20,"name":"Events"},
                       {"rankOrder":30,"name":"Member Directory"}]
```

`DashboardView` in [api/dashboard/types.ts](force-app/main/default/uiBundles/garpportal/src/api/dashboard/types.ts) declares `cards: PortalCard[]` instead. That field is `undefined` at runtime, so `composeDashboardCards` always receives an empty `serverCards` and **the entire server manifest is ignored**. Member Directory is in the live payload and never renders; so would Advertisement, Exam Notifications and the GBI / EPP / BenchPrep cards. Enrolled Programs, Events and CPD appear only because they are composed client-side.

**CPD is unaffected.** `GARP_Portal_DashboardService` gates its `'CPD'` entry on a live CPE contract plus at least one completed certification, which is exactly what `dashboardCreditRows().length > 0` already requires — so manifest-gating the CPD card would add complexity and change nothing.

Fixing the manifest is a dashboard-wide task with its own verification, deliberately not folded into the CPD work.

---

**Before starting any P2/P3 item:** run the `legacy-rewrite.md` sequence — confirm the flow in MyGarp, then check GarpAppv1 for an existing REST endpoint. If MyGarp shows the flow and GarpAppv1 has no matching API, that is a stop-and-report, not a GraphQL join.
