# Registration Forms — Build To-Do (garp_portal)

Source of truth for scope: **GarpAppv1** (`doc/backend-artifact-2.md`).
Only registration forms are listed here. Everything unchecked is not started.
Status last updated 26 Aug 2026, after the full-form E2E test pass and parity fixes.

Legend: ⬜ not started · 🔶 in progress · ✅ done

---

## 1. Exam / Program Registration — `ExamRegistration`

Single form component in GarpAppv1 serving all program types.

**GarpAppv1 routes**
- `/registration/:programType`
- `/registration/:programType/:regCode` (B2B deal code or EPP affiliate code)
- `/registration/micro/:courseCode/:regCode` (micro courses — B2B only, code required)

**GarpAppv1 API chain** — `/services/apexrest/examreg/*`
`info` → `options` → `fees` → `verifyCustomer` → `verifyAddress` → `register` → `checkout` / `payOrder` → `paymentStatus` / `rollback`

**Program types to cover (10)**

- ✅ `frm`
- ✅ `scr`
- ✅ `riskai` (URL alias `rai`)
- ✅ `raij` — form done; closed in devjuly25a, so only the refusal screen is verifiable
- ✅ `frr` — retired; renders the server's own "not currently available" refusal
- ✅ `frr25`
- ✅ `ffr`
- ⬜ `mem` — resolves to `kind=membership` (needs `riskNetOffer` support)
- ✅ `affiliate` — `isAffiliate=true`, `addOns=(AFREE)` — bespoke form at `/registration/affiliate`
- ⬜ `micro` — course code + reg code (API layer and query keys already accept `courseCode`; no form or route)

**Cross-cutting pieces of this form**

- ✅ Load form (`GET examreg/info`) — eligibility, exam parts, administrations, sites, study materials, countries, membership upsell
- ✅ Reg-code resolution — resolution is server-side (`GARP_ExamReg_TeamReg`); the client carries the code through info/fees/register from both `?regCode`/`?teamCode` and the path form `/registration/:programType/:regCode`, and an unresolved code renders the server's refusal (verified live: "The Team Registration code given is not currently valid")
- ✅ Lazy typeaheads (`GET examreg/options`) — company and school, fetched only once the OSTA card is on screen
- ✅ Cart pricing (`POST examreg/fees`) — main product, FRM enrolment, China OSTA fees, complimentary membership, paid membership upsell, study materials, shipping, processing fee, wire/ACH tax
- ✅ B2B seat pricing — client side only: the `hasBilling=false` rendering path (no payment card, plain "Register" label) is built and proven by the affiliate form; the product swap is server-side, and live verification stays blocked by the sandbox gap below
- ✅ Customer identify (`POST examreg/verifyCustomer`) — on identity blur AND at submit, existing-contact advisory, forced sign-in, `Form_Data__c` session id reused between the two
- ✅ Address validation (`POST examreg/verifyAddress`) — per `Country_Code__c` payment methods, province select + `provinceRequired`, `postalCodeRequired`
- ✅ Order write (`POST examreg/register`) — proven end to end: order W3869960 written from the browser as a guest, 26 Aug 2026
- ✅ Payment exits — Card → Stripe Checkout · Wire/ACH or zero total → `payOrder` + `paymentStatus` (poll x3) · abandoned → `rollback` · wire exit proven live; the Stripe hosted page itself can't be completed from local dev

---

## 2. Event / Chapter Meeting / Webcast Registration — `EventRegistration`

Single form component; the variant is fixed by the route.

**GarpAppv1 routes**

- ⬜ `/registration/event/:eventId` — `Event__c`
- ⬜ `/registration/event/:eventId/:regCode` — team code accepted, nothing reads it yet
- ⬜ `/registration/chaptermeeting/:eventId` — `Chapter_Meeting__c`
- ⬜ `/registration/webcast/:eventId` — `Webcast__c` (free by construction, no rate object)
- ⬜ `/registration/event` — no id, "choose an event" picker

**Legacy URL shapes that must render the same form (no redirect)**

- ⬜ `/event/registration/:eventId`
- ⬜ `/event/registration/:eventId/public`
- ⬜ `/chaptermeeting/registration/:eventId`
- ⬜ `/webcast/registration/:eventId`
- ⬜ Redirect `/event-registration?eventId=…&eventType=…` → `/registration/event/:eventId`

**Cross-cutting pieces of this form**

- ⬜ Load (`GET examreg/event/info?eventId=&eventType=`) — rate window per caller (member / non-member / alumni), returns `amountDue`
- ⬜ Register (`POST examreg/event/register?eventType=`) — free vs paid fork decided server-side, never from the client
- ⬜ Paid path → `POST examreg/checkout` (same hosted Stripe session as the exam form)
- ⬜ Guest (unauthenticated) registration must work — `isAuthenticated:false`
- ⬜ Attendance vocabulary normalisation — `Delivery_Method__c` [Online Only | In-Person Only | Hybrid] vs restricted Attendance [In-Person | Virtual]
- ⬜ Do **not** port the client-side `amountDue > 0` block that replaced the whole form with a notice

---

## 3. Exam Setup Wizard — `PortalExamSetup` (authenticated)

**GarpAppv1 route:** `/programs/exam-setup/:programType` (reached from "Schedule Exam")
**API:** `memberportal/examSetup` → `GARP_Portal_ExamSetupService`

Built as a single-page form at `/programs/$programType/exam-setup` rather than
a three-step wizard — same payloads, same `nextScreen` contract, our own UX
(`organisms/exam-setup-panel.tsx`, `api/exam-setup/`, `lib/exam-setup-presentation.ts` + 48 tests).

- ✅ Step 1 — Exam Details (current sittings, administrations, sites) — `ExamSetupSelectionSection`
- ✅ Step 2 — ID Information (ID + OSTA details, country and month options) — `ExamSetupIdSection`; both halves saved together via `POST memberportal/examSetupId`, as Apex takes them
- ✅ Step 3 — outcome branching on server-returned `nextScreen` (`outcomeFrom`; unrecognised value falls back to complete):
  - ✅ `Pay Fees` — deliberately a **fee gate + MyGarp handoff**, not an in-portal payment: `examSetupFees` returns no order and no checkout URL, and the endpoint that raises the reschedule Opportunity (legacy `createExamRescheduleFeesOrder`) was never ported, so a member who paid here would pay into nothing
  - ✅ `Check Authorization` — provider push (`examSetupAuthorize`) implemented with capped retries, but gated OFF behind `EXAM_SETUP_AUTHORIZE_ENABLED` until the backend team confirms the sandbox path is safe (it reaches Pearson / PSI / ATA for real); with it off the outcome shows the MyGarp handoff
  - ✅ `Setup Complete`
- 🔶 Fee re-pricing on the Pay Fees branch — `fetchExamSetupFees(modificationId)` prices from the recorded modification (never the client cart), is written and unit-tested, but is deliberately **not called** until the order-raising endpoint exists server-side; `predictFee` gives the member-facing forecast from Apex's own fee literals in the meantime
- ✅ Modification resolves through the signed-in member's own session — every call sends `programType` only, never a bare record id; the legacy fetch-by-bare-id behaviour was not ported

---

## 4. Registration Survey — `PortalRegistrationSurvey`

**GarpAppv1 routes:** `/registration/survey`, `/registration/information`
Rendered outside `PortalShell` — no chrome.

- ⬜ `/registration/survey`
- ⬜ `/registration/information`

---

## 5. Account Self-Registration — `Register`

**GarpAppv1 route:** `/register` → `UIBundleRegistration`

- ⬜ `/register` sign-up form

---

## Known gaps carried over from GarpAppv1

Flagged in `doc/backend-artifact-2.md` — verify rather than assume when building.

- ⬜ Paid **chapter meeting** registration is untested in GarpAppv1 (only events ran end to end; chapter meetings write to a different object with its own restricted picklists)
- ⬜ `/registration/mem` has never had a real order put through it, and it does take money
- ⬜ B2B live registration blocked in sandbox — no open exam rate has `Team_Product__c` populated
- ⬜ Real deferral cannot be constructed in sandbox — only one administration open per exam type
- ⬜ Three B2B deal fields unapplied in GarpAppv1: `OSTA_Fee_Paid_by_Institution__c`, `GST_Fee_Paid_by_Institution__c`, `Free_Membership__c`
