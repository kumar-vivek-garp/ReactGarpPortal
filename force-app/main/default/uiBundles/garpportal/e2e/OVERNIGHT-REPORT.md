# Overnight Playwright build — run report

## MORNING SUMMARY (read this first)

**Everything asked for was built, and everything passes.**

| Suite | Specs | Result | Runtime |
|---|---|---|---|
| mocked (fabricated data, all routes + money flows) | 25 spec files / **117 tests** | **117/117 GREEN** | ~22s |
| live (REAL org reads, devjuly25a, mutation-proof) | 6 spec files / **19 tests** | **19/19 GREEN** | ~42s |
| Vitest (untouched tonight, re-verified) | 397 files / 2497 tests | GREEN | ~15s |

- **Zero APP-LIMIT failures** — nothing had to be left red; every failure
  during the night was a test-authoring bug, fixed in the test.
- **The Big Rules held, provably**: no git writes, no Salesforce writes
  (the live guard aborted the one probe mutation and recorded zero
  attempted writes across all pages), no backend changes, no frontend
  changes (`src/` diff is empty; the only rules-file touch is the
  sanctioned testing.md addendum).
- **How to run**: `npm run app:e2e` (mocked) · `npm run app:e2e:live` (live —
  if its webServer times out, first run
  `SF_TARGET_ORG=devjuly25a npm run local-sf` from the repo root) ·
  reports: `npm run app:e2e:report` / `app:e2e:live:report`.
- Findings worth your attention are inline per phase below; the top three:
  the study-materials 403-upsell HTTP-mirroring question (M5), the
  gateway org-pinning trap that the live gate caught for real (L0), and
  the router's JSON param serialization quirks now pinned by tests (M1/M6).

Built overnight (2026-09-04) per the approved plan: full-route coverage,
two segregated suites. Phases append their results here as they complete.

## The two suites

| Suite | Config | Data | Runs via |
|---|---|---|---|
| `mocked` | `playwright.config.ts` | fabricated (page.route + typed factories) | `npm run app:e2e` |
| `live` | `playwright.live.config.ts` | REAL org reads (CLI gateway, org pinned `devjuly25a`, mutation-proof guard) | `npm run app:e2e:live` |

Failure classification used throughout: **TEST-BUG** (test was wrong — fixed
during the night) vs **APP-LIMIT** (application/backend limitation — left
RED deliberately per instruction; do not fix without a decision).

## Phase log

### M0 — infrastructure

- `e2e/support/mock-org.ts` — the fabricated org: one dispatcher for CSRF,
  identity (member/guest as explicit answers), memberportal actions,
  examreg family, GraphQL ops; per-test overrides + recorded-call spies;
  payloads typed against `src/testing/factories/*`.
- Config split: default config = mocked only (`e2e/mocked/`); live config
  separate (`e2e/live/`, explicit-run-only).
- Existing 9 smoke specs rewritten onto the mock org (`e2e/mocked/smoke.spec.ts`).
- Result: **9/9 green (1.9s)** after one infra fix worth knowing: a
  long-lived reused `serve` process (from the earlier UI-mode session) had
  been started while `dist/serve.json` was missing, so deep links got the
  static server's own 404. `serve` reads its config at startup — a stale
  server survives `reuseExistingServer: true` forever. Fix: kill :5175 and
  rebuild via `build:e2e`. (The `e2e`/`e2e:*` npm scripts always rebuild,
  so this only bites ad-hoc `npx playwright test` runs after a plain build.)

### M1 — auth & shell (auth-shell.spec.ts, guest-wall.spec.ts)

- **25/25 green** (suite 34, ~3s). No APP-LIMITs.
- Login (guest render, member bounce, startUrl carry, unsafe-startUrl
  rejection ×2), sign-out (+re-walled after), 404 in member AND guest
  chrome, 13-route guest wall with startUrl round-trip, 4 public twins with
  search carried.
- Two TEST-BUGs found+fixed, both worth knowing: (1) an all-digit param
  re-serializes quoted (`oid="801"`) through the twin bounce — the router's
  JSON search codec keeping it a string on re-parse; (2) an unknown path
  UNDER a layout (e.g. /my-account/orders/…, not a real route) fuzzy-matches
  into `_appLayout`, so the auth guard runs and a guest gets Login — only
  fully-unmatched paths reach the session-aware 404.

### M2 — dashboard (dashboard.spec.ts + support/payloads.ts)

- **5/5 green** (suite 39, ~4s). No APP-LIMITs.
- The "Unable to load your notifications" toast seen in the old suite is
  now root-caused AND eliminated: the `cpd` + `examNotifications` queries
  carry `meta.toastError`, and a permissive `{}` mock fails their inner
  `statusCode` check. `payloads.ts#dashboardActionSet()` stubs all seven
  dashboard actions with typed, parser-satisfying data; test 1 asserts
  zero /unable to load/i toasts AND audits `org.unhandled` so any future
  new dashboard query fails loudly instead of toasting silently.
- Covered: card renders by name, notifications content, dismiss →
  `dismissCard` POST → undo toast → `restoreCard` POST → card returns,
  alert bar urgent render + minimise/restore round-trip through the spring
  flight, dashboard 500 → error state with chrome intact + server's own
  words in the toast.
- Payload gotchas recorded: manifest names must equal `DASHBOARD_COMPONENT`
  values; alertBar needs inner `statusCode: 200` + non-null `alertStatus`;
  dates render US-format.

### M4 — my-account (4 spec files)

- **14/14 green**, zero APP-LIMITs.
- Tabs are lazy and asserted so: landing on order-history fires `orders`
  only (plus the always-on `account` — source-verified real behavior);
  contact-preferences fires its GraphQL read only on that tab.
- Order detail: unpaid vs paid affordances; **both Pay legs**: 201 zero-value
  close stays in-app (payOrder body asserted), 200 hands off to
  `/stripe_checkout?regType=orders&id=…` with the
  `garp-checkout-session-token` cookie asserted; Cancel journey with toast.
- Contact preferences SMS toggle → `UpdateSmsPreferences` variables + refetch.
- Auto-renew lives HERE (MembershipAccountCard on tab 1) — full on-journey
  asserted (POST + toast + refetched state).
- Profile edit dialog: lazy hydrate, prefill, cancel-fires-nothing, full
  save with `SavePersonalInfo` variables asserted.
- Code finding for the morning: `useAccountContact` is DEAD CODE (nothing
  imports it). Also: on localhost the session contactId comes from the
  /me payload's `identity.contactId`, not the GraphQL Contact — mock
  authors beware.

### M3 — programs (6 spec files)

- **15/15 green** (suite 68, ~9s full). 7 dev-time failures all TEST-BUG
  (strict-mode substring collisions with hidden mega-menu headings — fixed
  with `exact: true`); no APP-LIMITs.
- Covered: listing tabs/views, frm detail hero+rail, exam-setup fee gate
  (asserts NO write before the gate) + save body deep-equal including the
  blank-ID-omits-fields trap, errata submit body (incl. the pinned
  studyMaterial/book inversion), results render + `examResultViewed`
  auto-fire stamped ONLY for the released row, work-experience panel +
  add dialog wire, course detail (frr→FRR mapping).
- Documented e2e-unreachable: the exam-setup AUTHORIZE outcomes —
  `EXAM_SETUP_AUTHORIZE_ENABLED=false` is a build-time constant in dist
  (real Pearson/PSI integration); hand-off + zero-authorize asserted
  instead; unit layer owns the outcomes.

### M5 — membership, content, study materials (+archive) (4 spec files)

- **14/14 green** (suite 93, ~20s full). Zero APP-LIMITs; 3 TEST-BUG
  strict-mode collisions fixed.
- Covered: membership hero/benefits/tabs + lapsed upsell; gated-content
  entitled hand-off (garp.org stubbed, cookie cleared asserted) +
  not-entitled upsell with tracking params + expired-link state;
  study-materials buckets, pill filter, bogus-tab normalization,
  **403-upsell refusal leg**, archive year-map + eBookAccess mint.
- **Finding worth a morning decision**: the study-materials upsell only
  renders for an envelope-200 refusal (`data.statusCode: 403`);
  `fetchStudyMaterials` has NO inner statusCode check and nothing calls
  `memberPortalRefusalPayload` — if the real Apex mirrors 403 into the
  HTTP status, the built app shows the ERROR state, not the upsell.
  Confirm against `GARP_Portal_API` before relying on the upsell.
- Ops note: two agents building dist concurrently can wipe each other's
  mid-run static server (transient 90-fail run, clean on retry) — later
  phases build only at the very end.

### M6 — CPD (3 spec files)

- **11/11 green** (suite 93 twice consecutively). Zero APP-LIMITs.
- Covered: summary/cycle picker (+past-cycle read-only, no refetch),
  claim dialog lazy loads + dynamic fields + POST body deep-equal +
  refetch, delete, attestation (two-tick gate + `cpdAttest` body +
  stubbed cert window.open), activities defaults/facets/joined params,
  deterministic keepPreviousData paging via a gated responder,
  `?activityId` collapse + restore, 500 error leg.
- Pinned quirk: TanStack serializes ARRAY search params as JSON
  (`?type=%5B%22Webinar%22%5D`); bare `?type=Webinar` fails zod and is
  silently dropped.
- Edit-claim e2e deliberately not written: its seed-wipe defect is pinned
  at layer 2 — copying it up would violate the lowest-layer rule.

### M7 — events (4 spec files)

- **11/11 green** (suite 104, 15.2s). Zero APP-LIMITs.
- Covered: listing + type filter (a Radix Select, not pills), free member
  journey with the register body deep-equaled to the closed DTO, webcast
  plumbing (`eventType` in query string; `event/options` exactly once on
  webcast, zero on plain events), RSVP accept (zero writes) + decline
  (body asserted), paid checkout hand-off (successUrl/cancelUrl contract:
  the EVENT cancel URL carries `oid` — that is what powers
  rollback-on-cancel), cancelled-return rollback exactly once, payment
  return with all write endpoints at zero, already-registered, 500 leg.
- Idiom recorded: member register panels hydrate via the
  `PersonalInfoEditContact` GraphQL op — leave it unanswered and the panel
  toasts; stub it via `personalInfoGraphqlResolvers`.

### M8 — money flows (6 spec files)

- **13/13 green; full mocked suite 117/117 (22.3s)**. Zero APP-LIMITs.
- Wire journey (member, offline): ordered writes asserted equal to
  `[verifyCustomer, verifyAddress, register, payOrder, paymentStatus]`,
  payOrder EXACTLY once with exact body, dialog staging (zero writes while
  open), debounce (+1 fees for a 4-keystroke burst), invoiced outcome.
- Stripe: `[verifyCustomer, register, checkout]` — NO verifyAddress on card
  orders, payOrder 0 forever, register stays 1 after provider return;
  successUrl/cancelUrl contract asserted. Cold payment return: zero writes,
  zero fees, confirmation with the numeric order number; guest variant
  proves the public guard suppresses its bounce on payment returns.
- Affiliate: `[verifyCustomer, register, payOrder]` with blur-session
  reuse (verify total 1), trimmed names + collapsed consent on the wire.
- Help-center submit + directory search (null searchText on the wire when
  empty — pinned) + member dialog.
- Test-author idioms recorded: `getByLabel` breaks on required-field `*`
  (aria-hidden IS included in label-text matching; use getByRole name);
  profile mocks need mailing===billing or the shipping card doubles
  locators; factory countries carry no payment permissions — journeys need
  creditCard/wire/achAllowed set.

### L0 — live infrastructure (boot.spec.ts) — **3/3 GREEN against the real org**

- The org gate WORKED twice tonight, for real: (1) a pre-existing gateway
  from an earlier dev session was pointed at PREPROD via the project-local
  CLI default — the gate refused to run and every live spec skipped with
  the reason; (2) after restarting pinned (`SF_TARGET_ORG=devjuly25a`),
  the gate verified org id 00DgP0000017mtlUAA and proceeded.
- The org-safety guard PROVED itself: a mutation POST attempted from the
  live page was aborted in the browser (negative spec green).
- The app boots against real org data through preview→gateway — the SDK
  CSRF question from planning is answered: it WORKS (dashboard's
  memberportal GETs succeeded under the CLI bearer token).
- Infra flake recorded: the gateway's `sf` JSON parse failed transiently
  under Playwright's webServer start (CLI update-notifier polluting
  stdout on its once-per-interval schedule); a manual pinned start
  succeeded immediately. If `app:e2e:live` ever times out on webServer,
  start the gateway first: `SF_TARGET_ORG=devjuly25a npm run local-sf`.

### L1 — live read smoke (5 spec files) — **16/16 GREEN (19/19 with L0)**

- Every read route loaded against the REAL org: zero error states, zero
  blocked writes, zero skips. Two TEST-BUGs fixed (order-detail route
  shape; a CardTitle div that isn't a heading).
- The live-data picture (org devjuly25a, CLI fallback contact): enrolled
  programme is **SCR**; 19 real orders (first detail opened read-only);
  real events, real help-center cases; contact-preferences GraphQL read
  passed the guard's query inspection; CPD cycle, purchased materials,
  and directory results are genuinely empty (their empty states render);
  exam-setup shows the real "No exam dates are open" refusal;
  `examResultViewed` never fired (no released-unviewed attempt) so the
  neutralization stayed armed but untriggered.
- No org API response ≥400 anywhere on the covered pages.
