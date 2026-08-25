# Registration Forms — Build To-Do (garp_portal)

Source of truth for scope: **GarpAppv1** (`doc/backend-artifact-2.md`).
Only registration forms are listed here. Everything unchecked is not started.

Legend: `[ ]` not started · `[~]` in progress · `[x]` done

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

- [ ] `frm`
- [ ] `scr`
- [ ] `riskai` (URL alias `rai`)
- [ ] `raij`
- [ ] `frr`
- [ ] `frr25`
- [ ] `ffr`
- [ ] `mem` — resolves to `kind=membership`
- [ ] `affiliate` — `isAffiliate=true`, `addOns=(AFREE)`
- [ ] `micro` — course code + reg code

**Cross-cutting pieces of this form**

- [ ] Load form (`GET examreg/info`) — eligibility, exam parts, administrations, sites, study materials, countries, membership upsell
- [ ] Reg-code resolution — affiliate code, then B2B deal seat; unresolved code must fail the load, not be ignored
- [ ] Lazy typeaheads (`GET examreg/options`) — company and school
- [ ] Cart pricing (`POST examreg/fees`) — main product, FRM enrolment, China OSTA fees, complimentary membership, paid membership upsell, study materials, shipping, processing fee, wire/ACH tax
- [ ] B2B seat pricing — swaps main product for `Team_Product__c`, `hasBilling=false`
- [ ] Customer identify (`POST examreg/verifyCustomer`) — existing contact, forced sign-in, `Form_Data__c` session id
- [ ] Address validation (`POST examreg/verifyAddress`) — per `Country_Code__c` payment methods, province / postal requirements
- [ ] Order write (`POST examreg/register`)
- [ ] Payment exits — Card → Stripe Checkout · Wire/ACH or zero total → `payOrder` + `paymentStatus` (poll x3) · abandoned → `rollback`

---

## 2. Event / Chapter Meeting / Webcast Registration — `EventRegistration`

Single form component; the variant is fixed by the route.

**GarpAppv1 routes**

- [ ] `/registration/event/:eventId` — `Event__c`
- [ ] `/registration/event/:eventId/:regCode` — team code accepted, nothing reads it yet
- [ ] `/registration/chaptermeeting/:eventId` — `Chapter_Meeting__c`
- [ ] `/registration/webcast/:eventId` — `Webcast__c` (free by construction, no rate object)
- [ ] `/registration/event` — no id, "choose an event" picker

**Legacy URL shapes that must render the same form (no redirect)**

- [ ] `/event/registration/:eventId`
- [ ] `/event/registration/:eventId/public`
- [ ] `/chaptermeeting/registration/:eventId`
- [ ] `/webcast/registration/:eventId`
- [ ] Redirect `/event-registration?eventId=…&eventType=…` → `/registration/event/:eventId`

**Cross-cutting pieces of this form**

- [ ] Load (`GET examreg/event/info?eventId=&eventType=`) — rate window per caller (member / non-member / alumni), returns `amountDue`
- [ ] Register (`POST examreg/event/register?eventType=`) — free vs paid fork decided server-side, never from the client
- [ ] Paid path → `POST examreg/checkout` (same hosted Stripe session as the exam form)
- [ ] Guest (unauthenticated) registration must work — `isAuthenticated:false`
- [ ] Attendance vocabulary normalisation — `Delivery_Method__c` [Online Only | In-Person Only | Hybrid] vs restricted Attendance [In-Person | Virtual]
- [ ] Do **not** port the client-side `amountDue > 0` block that replaced the whole form with a notice

---

## 3. Exam Setup Wizard — `PortalExamSetup` (authenticated)

**GarpAppv1 route:** `/programs/exam-setup/:programType` (reached from "Schedule Exam")
**API:** `memberportal/examSetup` → `GARP_Portal_ExamSetupService`

- [ ] Step 1 — Exam Details (current sittings, administrations, sites)
- [ ] Step 2 — ID Information (ID + OSTA details, country and month options)
- [ ] Step 3 — Setup Completed, branching on server-returned `nextScreen`:
  - [ ] `Pay Fees`
  - [ ] `Check Authorization`
  - [ ] `Setup Complete`
- [ ] Fee re-pricing on the Pay Fees branch — re-price from the recorded modification, never from the client cart
- [ ] Modification must resolve through the signed-in member's own registrations (legacy fetched by bare id — security fix, do not port the legacy behaviour)

---

## 4. Registration Survey — `PortalRegistrationSurvey`

**GarpAppv1 routes:** `/registration/survey`, `/registration/information`
Rendered outside `PortalShell` — no chrome.

- [ ] `/registration/survey`
- [ ] `/registration/information`

---

## 5. Account Self-Registration — `Register`

**GarpAppv1 route:** `/register` → `UIBundleRegistration`

- [ ] `/register` sign-up form

---

## Known gaps carried over from GarpAppv1

Flagged in `doc/backend-artifact-2.md` — verify rather than assume when building.

- [ ] Paid **chapter meeting** registration is untested in GarpAppv1 (only events ran end to end; chapter meetings write to a different object with its own restricted picklists)
- [ ] `/registration/mem` has never had a real order put through it, and it does take money
- [ ] B2B live registration blocked in sandbox — no open exam rate has `Team_Product__c` populated
- [ ] Real deferral cannot be constructed in sandbox — only one administration open per exam type
- [ ] Three B2B deal fields unapplied in GarpAppv1: `OSTA_Fee_Paid_by_Institution__c`, `GST_Fee_Paid_by_Institution__c`, `Free_Membership__c`
