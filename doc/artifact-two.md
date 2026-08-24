# What is not done

Outstanding work on `garp_portal`, as of **2026-08-24**.

Companion to [`tell_to_backend_dev.md`](./tell_to_backend_dev.md), which tracks
questions *for* the backend team. This file tracks work on **our** side: what is
not built, what is built but unverified, and whether each item is ready to plan
against.

Everything below was re-verified against source and against the `devjuly25a`
sandbox in this pass — not carried forward from an earlier note.

**Status key:** 🟢 ready to build · 🟡 partly ready · 🔴 blocked

---

# 1. Features not built

## 1.1 ✅ BUILT (2026-08-24) — Exam setup, including defer

`/programs/{slug}/exam-setup`. One page, two sections, one submit. Verified
live against `devjuly25a` as contact `003gP00000TGwKHQA1` (GARP ID 2478736,
both FRM parts).

**Defer was confirmed to be the same wizard, not a separate feature** — the fee
fires on `movedAdmin1 || movedAdmin2`, described as `'Standard exam
administration change fee'`, and `raiseModification()` stamps
`Deferral_Subtype__c = 'Deferral Standard'`.

### What shipped

| Step | Endpoint | Status |
|---|---|---|
| 1 — when & where | `GET examSetup` | ✅ both parts, per-part admin + site |
| 2 — ID info (incl. OSTA China block) | — same payload | ✅ |
| submit | `POST examSetupId` | ✅ both halves in one call |
| fee gate | none — client-side | ✅ stops before any write |
| 4 — authorize | `POST examSetupAuthorize` | ⚠️ built, behind a flag |

`programExamSetupHref()` now returns the in-app route, so **the alert bar's
`Exam Scheduling` action stops leaving the portal** — verified: the live alert
"You have not booked a seat for your exam yet" now links to
`/programs/frm/exam-setup`.

### Still not done here

- 🔴 **The paid path.** `examSetupFees` returns fee lines but no `orderId` and
  no checkout URL, and `authorize()` skips any sitting whose Opportunity is not
  already `Closed`. The legacy filled this with `createExamRescheduleFeesOrder`,
  which raised the Opportunity and handed the line items to the **registration
  app's shared cart** (`garpRegistrationService.initializeCart`). That method
  was never ported. Until it is, a fee-incurring change is gated client-side and
  handed to MyGarp — **nothing is written**, so no orphan modification is left
  behind.
- ⚠️ **`EXAM_SETUP_AUTHORIZE_ENABLED = false`.** `examSetupAuthorize` reaches
  Pearson / PSI / ATA through `ExamRegistrationsStatusCls.updateRegistration`
  from whichever org runs it. Off until the backend team confirms the sandbox
  path is safe; the outcome screen hands off to MyGarp meanwhile. One constant
  to flip.
- ⚠️ **OSTA fees cannot be forecast.** Apex decides them from
  `Exam_Site__r.Site__r.Is_OSTA_Information_Required__c`, which is **not on the
  wire** — the site list carries only `{ id, name, isSelected }`. So a member
  moving into or out of a mainland-China centre can still get `Pay Fees` back
  from the save. That branch is handled (the gate then says the change is
  pending, because by then Apex HAS raised the modification), but it is a
  second-line catch rather than a clean stop.
- ⚠️ **`isOSTA` describes today, not the new choice.** Same missing flag. A
  member moving INTO a China centre is not asked for the Chinese-name / DOB /
  gender block until they return. Apex accepts the save regardless (it writes
  that block only `if (ostaIDLocation != null)`), and today the provider step is
  a MyGarp hand-off that collects them anyway. **This stops being harmless the
  moment authorize is enabled.**

### Two data-safety bugs found and fixed during verification

Both were caught by driving the real sandbox, not by tests, and both are the
same class as the `cvAddress` defect (D1) we reported to the backend team:

1. **Blank fields were overwriting stored data.** Apex guards every ID write
   with `if (field != null)`, and `""` is not null — so an untouched field
   posted a blank. A first save wiped this member's `Mobile_Phone_Code__c`.
   `toIdInput` now omits empties entirely, so they never travel.
2. **The ID number read is masked.** `ID_Number__c` holds only the last five
   characters in the clear (the whole number lives in `OSTA_Full_ID__c`).
   Seeding the box with it meant the next save wrote those five over a real ID.
   The field is now never seeded — blank means "keep what you have" — matching
   what `osta-id-form` already does. Verified at the database level: the stored
   `OSTA_Full_ID__c` survives a save with the box left empty.

A third, purely client-side: Radix `Select` was handed `undefined` on the first
render and latched into uncontrolled mode, so both selects rendered their
placeholder forever and posted blank. Fixed by mounting the form only once the
payload exists, so `defaultValues` is right the first time.

## 1.2 🔴 Registration

**Not ready to plan. Needs answers first.**

Larger than anything built here so far, and the shape depends on answers we do
not have.

### What exists already

A complete registration backend is **already deployed in `devjuly25a`** — the
standalone `GARP_ExamReg_*` module, 14 Apex classes, ~200KB, at
`/services/apexrest/examreg/*`. Separate from `/memberportal/*` and built
guest-first (`without sharing`, with a `whoami` action for anonymous identity).

Actions: `whoami`, `info`, `options`, `fees`, `verifyCustomer`, `verifyAddress`,
`register`, `payOrder`, `paymentStatus`, `checkout`, `rollback`, plus an
`event/` prefix for events, chapter meetings and webcasts.

GarpAppv1 also has a ~3,000-line React port of it already started
(`features/exam-registration/`).

**So registration is not a backend build. It is a frontend build against an
existing backend** — if that backend is live and if the public pages are ours.

### Why it is not plannable yet

1. **Ownership is unsettled.** If `/registration/*` stays on sfdcapp, we build
   only the member-facing half and this shrinks from the largest remaining item
   to a medium one. Nothing else should be decided before this.
2. **The guest path needs org config we do not control** — guest-profile Apex
   class access, a public LWR page, and the network currently has
   `selfRegistration=false` with admin-only membership.
3. **The Data SDK does not work for guests.** Its CSRF preflight
   (`/ui-api/session/csrf`) 403s for guest users, so GarpAppv1 bypasses the SDK
   with a raw same-origin `fetch`. That **contradicts our own
   `salesforce-data-access` rule** and needs an explicit sanctioned exception,
   not an improvised one.
4. **It is a checkout, not a form.** `register()` creates Account + Contact +
   Opportunity + line items + contact role + Contracts + Exam Attempts in one
   transaction. Around it: fees, promo codes, address verification, shipping for
   physical materials, membership add-on with autorenew, RiskNet, Stripe hosted
   checkout, rollback for abandoned orders, OSTA ID capture, China disclosures,
   GDPR sponsor consent, EPP opt-in, attestations.

### Two unresolved product facts

- **Registering does not grant a login immediately.** The Contact is created
  with `DO_NOT_FIRE__c = true`, which holds back the community-user trigger
  "until payment lands, so an abandoned checkout does not leave a login behind".
  Payment flips it, and `ContactTriggerHelper.createCommunityUser` then creates
  the User.
- **For card payments, nothing we could find flips that flag.** Only
  `completeOfflineOrder()` (wire / ACH / free) does. Checked the Opportunity
  handlers, `ChargentOrderTransactionTriggerHandler`, and the active
  Contact/Opportunity flows — none touch it. Either something we have not found
  handles it, or card payers never get a login.
- **Portal access is a second, separate gate.** `GARP_Portal_Access` returns
  **403** for an account with contracts but no non-Draft **Membership**. An
  exam-only registrant may get a working login and then a paywall.

## 1.3 🟡 Undefer

sfdcapp has both `deferExam` and `undeferExam`. On the Salesforce side
`MemberManagementUnDeferralCls` is `@AuraEnabled` — **staff tooling, not a
member-facing REST path**. Unclear whether members are meant to have this at
all. Low priority until confirmed.

---

# 2. Built but unverified — needs data in `devjuly25a`

Code written and unit-tested; the populated path has never run against real
data. Detail in `tell_to_backend_dev.md` section B.

| # | Missing data | Leaves unverified |
|---|---|---|
| B1 | 0 `ERP_Program` contracts | The whole ERP branch of the certification CV. FRM is fully verified; ERP is code-only. |
| B2 | 0 `CPE_Activity__c` records | Browse CPD Activities — populated list, facets, paging, single-activity view. |
| B3 | Exam notifications unreachable (17 recipient rows all `Contact__c = null`) | Dashboard Exam Notifications card and dialog. |
| B4 | CPD claims and credits near-empty | CPD pending/approved tables, claim round-trip. |
| B5 | Mobius vendor call-out fails in sandbox | eBook **Access** link handshake. |
| B6 | 0 `Errata__c` records | Nothing extra — A1 blocks errata regardless. |
| B7 | No member reachable-but-not-in-good-standing | The gated-content paywall's upsell branch — the portal's only conversion page. |

Expected to clear when we test against pre-prod.

---

# 3. Blocked on a backend change

| # | Item | Cost |
|---|---|---|
| A1 | 🔴 `errataForm` returns an empty option map for every programme | **Blocks errata entirely.** |
| A8 | 🔴 Nothing raises the Opportunity a fee order needs | **Blocks the paid half of exam setup** — deferrals are gated and handed to MyGarp. |
| A3 | 🟠 Exam results: Understanding and Percentile not on the wire | Blocks the bell curve. Quartiles are built. |
| A9 | 🟠 `Is_OSTA_Information_Required__c` missing from the site payload | OSTA fees cannot be forecast; a member moving into a China centre is not prompted for the OSTA block. |
| A11 | 🟠 `examSetupAuthorize` sandbox safety unconfirmed | In-app exam scheduling stays behind a flag. |
| D1 | 🔴 `cvAddress` blanks the member's company and phone | Live data loss on real Contacts — their client, already reported. |
| D4 | 🔴 `/content` is an open redirect | Their client. |
| A5 | ⚪ `cpdHandbookURL` never populated | CPD Download Handbook stays disabled. |
| A6 | ⚪ Attachment failures carry `data.message`, not `statusMessage` | Cosmetic error handling. |
| A7 | ⚪ `eBookAccessLinks` still has no caller | Informational. |
| A10 | ⚪ `examSetupId` treats `""` as a value | Handled client-side; recorded because it is D1's shape. |

Full write-ups in [`tell_to_backend_dev.md`](./tell_to_backend_dev.md) — A8–A12
were added on 2026-08-24 from building the wizard.

---

# 4. Deliberately not building

Recorded so they are not re-raised as gaps.

- **`POST /batch`** — evaluated and declined. Batching trades independent
  per-request governor limits for one shared transaction budget, and makes
  latency `sum` rather than `max`. React Query already reduces the fetch count
  (`alertBar` is ~once per session). Reasoning in `tell_to_backend_dev.md` D5.
- **Breadcrumbs** — reviewed against the legacy and deliberately skipped.

---

# 5. Questions outstanding

Full list of 15 sits with the backend team. The three that **change what we
build**:

1. After `examSetupFees` returns fee lines, **what creates the Opportunity and
   takes payment?** (blocks the paid half of exam setup)
2. **Does `/registration/*` move into this app, or stay on sfdcapp?** (sizes
   registration; nothing else about it should be decided first)
3. **Does an exam-only registrant get portal access, or hit the Membership
   paywall?** (changes the whole post-registration experience)

The rest are detail and can be answered while we build.

---

# 6. Are we good to start build planning?

**Exam setup and defer: ✅ done.** See 1.1 — built, verified live, all three
gates green. What is left of it is the paid path (blocked on the missing
order-creation endpoint) and turning the provider push on.

**Registration: 🔴 still do not plan.** Not because it is hard — because
question 2 changes its size by an order of magnitude, and questions 8–11 depend
on org configuration decisions that are not ours to make alone. Planning before
those answers would be planning something we may not build.

**Next:** send the questions — the exam-setup payment gap and the registration
ownership call are the two that unblock real work.
