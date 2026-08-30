# Open items and questions

Everything found while building the React portal that needs someone else to
act. Grouped by **who can act**, because only the first section is the backend
developer's to fix — the rest are sandbox data, product decisions, or courtesy
notes about their own client.

Nothing here has been changed by us.

**Status key:** 🔴 blocks a feature · 🟠 blocks verification only · ⚪ informational · ✅ resolved

**Last checked against `backend-artifact-2.md` (22 Aug 2026) and the resynced
GarpAppv1 source on 2026-08-24.** A8–A12 were added the same day, from building
the exam-setup wizard against the live sandbox. Resolved items are kept rather
than deleted so the history is readable; see the summary at the bottom.

---

# A. Needs an Apex change

## A1. 🔴 `errataForm` returns an empty option map for every programme

**Class:** `GARP_Portal_ErrataService` — `bookOptions()` and `dependentValues()`
**Found:** 2026-08-24 · **Re-checked against the resynced source: STILL OPEN**
(`GARP_Portal_ErrataService.cls:147` still iterates `Section__c` as the
controlling field)

`GET /memberportal/errataForm?programType=frm` answers **HTTP 200** with:

```json
{ "statusMessage": "Success", "statusCode": 200, "errataPicklistOption": {} }
```

The same for every programme. Access is fine — this is not the 403 branch; the
map is simply always empty, so the two cascading selects cannot be populated
and no erratum can be reported by anyone.

### Why

The two picklists are used the wrong way round. `bookOptions()` iterates
`Section__c` as the **controlling** field:

```apex
for (Schema.PicklistEntry controlling
     : Errata__c.Section__c.getDescribe().getPicklistValues()) {
    String label = controlling.getLabel();
    if (label == null || !label.toLowerCase().contains(search.toLowerCase())) {
        continue;
    }
    options.put(label, dependentValues(controlling.getValue()));
}
```

…but the org says the dependency runs the other way:

```
Section__c             dependentPicklist=True   controllerName=Book_Practice_Exam__c
Book_Practice_Exam__c  dependentPicklist=False  controllerName=None
```

(from `sf sobject describe --sobject Errata__c` on `devjuly25a`)

So the search term is matched against the wrong field's labels:

| Field | Active values | Contain a programme name? |
|---|---|---|
| `Book_Practice_Exam__c` | 7 — `2026 FRM Exam Part I`, `2026 FRM Exam Part II`, `2026 FRM Practice Exam Part II`, `Additional 2026 FRM Practice Exam`, `2026 SCR Exam`, `2026 RAI Exam`, `2026 RAI Japanese Exam` | **yes** |
| `Section__c` | 26 — `Foundations of Risk Management`, `Quantitative Analysis`, `Climate Change Risk`, … | **no** |

Searching `Section__c` for `"frm"` matches none of the 26 topic names, so the
map comes back empty. `dependentValues()` decodes the `validFor` bitmap in the
same inverted direction and has to be swapped with it.

### The write path is already correct

Worth stressing, because it pins the diagnosis rather than being a second bug.
`submit()` does:

```apex
Book_Practice_Exam__c = input.studyMaterial,   // the map KEY
Section__c            = input.book,            // the DEPENDENT value
```

That is exactly what a corrected `bookOptions()` would produce. **Only the read
is transposed.** No change to `submit()` is needed or wanted.

### Notes

- The same endpoint backs GarpAppv1's errata page, so that page will be showing
  empty selects too, whatever its status chip says.
- On our side the empty map renders an honest empty state rather than two dead
  dropdowns, so nothing looks broken — the feature simply cannot be used.
- Our submit path is written and unit-tested but **has never been exercised
  against the org**. Worth a joint check once the picklists come back.

---

## A2. ✅ RESOLVED — `X-GARP-Dev-Contact` branch adopted

**Class:** `GARP_Portal_Core` — `currentContact()` and `contactIdFromDevHeader()`
**Dropped:** twice · **Fixed by the backend developer, confirmed 2026-08-24**

The branch is now carried in their own copy: `contactIdFromDevHeader()` at
`GARP_Portal_Core.cls:557`, wired into `currentContact()` at line 608 with the
`DEV_FALLBACK_CONTACT` else. A full-stack deploy will keep it from now on.
**Thank you — this was the durable fix.** Original report kept below.

---

The localhost contact picker depends on a small branch in `currentContact()`
that reads the `X-GARP-Dev-Contact` header for **internal (Standard licence)
sessions only**. It is inert on Experience, because the UI that sends the header
is gated on `isLocalViteHost()`.

Every full redeploy of the portal classes removes it. When it goes, every local
session silently falls back to `DEV_FALLBACK_CONTACT` (`003gP000009J6u3QAC`) —
a member with no CPE contract — so the symptom is not "the picker broke", it is
"a member mysteriously has no CPD, no CV and no orders". It has cost a
diagnosis both times.

**The durable fix is to carry the branch in your own copy of the class** so a
full-stack deploy keeps it. See `doc/local-dev-contact-picker.md` for the
snippet. Restoring it from our side after each deploy is a slower loop, not a
fix.

---

## A3. 🟠 Exam results: Understanding and Percentile are not on the wire

The legacy exam-results page shows a bell curve and an
Understanding / Percentile readout. Neither value appears in any payload we
receive, so the React page currently ships quartile bars and the results letter
only.

**Question:** are those two values derivable server-side, or were they dropped
deliberately? We cannot build that part of the page either way until they exist.

---

## A4. ✅ RESOLVED — exam-setup fees now have an endpoint

`GARP_Portal_ExamSetupService` (1044 lines) and `GARP_Portal_ExamSetupFees`
(803 lines) landed on 22 Aug, exposing `examSetup`, `examSetupId`,
`examSetupFees` and `examSetupAuthorize`. Exam setup is no longer blocked on us.

**One nuance carried forward, not a blocker:** fees are still priced *after*
`examSetupId` records the modification, on the Pay Fees branch — there is no
live re-price as the member changes a dropdown, which is what the legacy did.
The artifact says why that is acceptable: there is no pricebook, only four
literal amounts (FRM administration change 250, SCR/RAIJ/RAI 150, OSTA location
40/part, OSTA data 10, refunds negative). We will **not** duplicate those in
React — pricing stays server-side — so a member still sees the bill one step
after choosing. Worth confirming that is the intended UX before we build the
wizard.

---

## A5. ⚪ `cpdHandbookURL` is never populated

The CPD service never returns it, so the Download Handbook link has no server
value. We ship a fallback URL, so nothing is blocked — but the field is dead as
it stands. Either populate it or drop it.

---

## A6. ⚪ Attachment failures carry `data.message`, not `statusMessage`

The router only lifts a field named `statusMessage` into the envelope, so
`errorMessage` is null on any `cvAttachment` failure and the real reason
("Work Experience not found", "A file is required", "Error uploading file") is
only inside `data`.

Not a bug in the service, and we read `data.message` deliberately — but a client
that reads the envelope shows **one generic string for every distinct failure**.
Worth either renaming the field or documenting it, since it is easy to miss.

---

## A7. ⚪ Partially resolved — `eBookAccessLinks` still has no caller

`examWindow` is now called, via the batch action (`portalApi.ts:206`), and
`restoreCard` has gained a consumer in `PortalDashboard.tsx`. 

`eBookAccessLinks` still has **no call site in either client** — confirmed by
search across the resynced GarpAppv1 source. It fetches several reader links in
one request; the archive page currently mints them one at a time. Either wire it
up or drop it.

---

## A8. 🔴 Exam setup has no way to raise the fee order — the paid path is unreachable

**Found while building the in-app exam-setup wizard (2026-08-24).** The free
path is shipped and working; anything that costs money cannot be completed.

`examSetupId` raises an `Exam_Registration_Modification__c` and answers
`nextScreen: 'Pay Fees'`. `examSetupFees` then prices it — correctly, and with
the full line items:

```json
{ "fees": [ { "productCode": "FRM1", "glCode": "4040", "amount": 250, … } ],
  "deferralSubType": "Deferral Standard", "transactionType": "…" }
```

But it returns **no `orderId` and no checkout URL**, and `examSetupAuthorize`
skips any attempt whose `Opportunity__r.StageName != 'Closed'` — it requires the
order to be **already paid**. Nothing between the two creates that Opportunity.
`GARP_Portal_ExamSetupService` says so itself:

> A change with fees stays Pending until checkout, where the Opportunity trigger
> picks it up.

…but "checkout" is not an endpoint we have. `payOrder` / `orderCheckout` both
need an `orderId` nobody hands us.

**Where it went.** The legacy did this with a remoting call the port did not
carry over — `createExamRescheduleFeesOrder(examRegId, adminI, adminII, siteI,
siteII)`, which raised the Opportunity and line items and then handed them to
the **registration app's shared cart** (`garpRegistrationService.initializeCart`,
`sfdcapp/modules/exam-setup/components/exam-setup-card.component.js:490-600`).
`getExamSetupFeesCheckoutInfo` and `examSetupAuthorizeRegistrations` were both
ported; the order creation between them was not.

**Question:** is that method intended to land as a portal action, or is the
order meant to be raised elsewhere and polled for? Either answer unblocks us —
we just need to know which.

**Meanwhile:** we gate a fee-incurring selection **client-side, before calling
`examSetupId`**, and hand the member to the MyGarp wizard. Nothing is written on
our side, so no orphan Pending modification is left to collide with the one
MyGarp raises.

---

## A9. 🟠 `Is_OSTA_Information_Required__c` is not on the exam-site payload

`examSetup` returns each site as `{ id, name, isSelected }`. Apex decides both
the OSTA fee and the OSTA form block from
`Exam_Site__r.Site__r.Is_OSTA_Information_Required__c`, which the client never
sees. Two consequences, both real:

1. **We cannot forecast the OSTA fees** (40/part, plus the one-off 10). The
   deferral fee we can — it keys off the administration, which IS on the wire —
   but a member moving into or out of a mainland-China centre can still come
   back `Pay Fees` after the write. We handle that, but it is a catch after the
   fact rather than a clean stop, and by then the modification exists.
2. **`isOSTA` describes where the member sits today, not what they just
   picked.** So someone moving INTO a China centre is not asked for the
   Chinese-name / DOB / gender / working-status block until they come back to
   the page. `writeIdFields` accepts that save silently (it writes the block
   only `if (i.ostaIDLocation != null)`), and today the provider step is a
   MyGarp hand-off which collects those fields anyway — so it is currently
   harmless. **It stops being harmless the moment `examSetupAuthorize` is
   turned on for us.**

**Ask:** add the flag to each `ExamSite` in the `examSetup` payload. One boolean
resolves both. Guessing from `name` is not viable — it is a site label, not a
country.

---

## A10. ⚪ `examSetupId` treats an empty string as a value, so a blank overwrites

Not a defect in anything shipped — recording it because it is the same shape as
D1 and the next client to touch this endpoint will hit it.

`writeIdFields` guards every column with `if (i.field != null)`. An empty string
is not null, so a client that posts `""` for a field the member never touched
overwrites the Contact with blank. We reproduced it: our first test save wiped
`Mobile_Phone_Code__c` on a real Contact (restored since).

The masked read compounds it. `ID_Number__c` holds only the last five characters
in the clear — the whole number lives in `OSTA_Full_ID__c` — so echoing the read
value back on the next save writes those five characters over a real ID.

**Our fix, client-side:** empty fields are omitted from the body entirely rather
than sent blank, and the ID number is never seeded (blank means "keep what you
have"). Verified at database level — `OSTA_Full_ID__c` survives a save with the
box empty.

**Suggestion, if it is cheap:** treat blank as absent server-side
(`String.isNotBlank`) so this cannot bite a future caller. No action needed for
us.

---

## A11. 🟠 Is `examSetupAuthorize` safe to call from the sandbox?

`GARP_Portal_ExamSetupService.authorize` pushes through
`ExamRegistrationsStatusCls.updateRegistration`, which is an outbound
integration to Pearson / PSI / ATA. Calling it from `devjuly25a` appears to
reach the real vendor.

We have built the screen and the retry loop but keep every call behind
`EXAM_SETUP_AUTHORIZE_ENABLED = false`; with it off the outcome hands the member
to MyGarp. Flipping one constant ships it.

**Question:** is there a sandbox-safe mode, or should we mock it? This is the
last thing standing between the wizard and a member finishing scheduling
in-app.

---

## A12. ⚪ Two notes on `examSetup`, no action needed

- **The class docblock is stale.** `GARP_Portal_ExamSetupService`'s header still
  says the write half is *"Still unported — setExamSetupIDInfo,
  getExamSetupFeesCheckoutInfo and examSetupAuthorizeRegistrations"*. All three
  exist. Worth a line's edit — it is the first thing anyone reads.
- **Both FRM parts return the same `Exam_Administration__c` Id** with different
  per-part names (`November 14-20, 2026` / `November 21-25, 2026`). That is what
  makes the legacy's same-day travel warning fire for every FRM candidate. We
  render the warning on the same condition, so behaviour matches — flagging only
  in case the shared Id is not intended.

---

## A13. 🔴 Event registration never returns the on-demand / join URL — the "register → watch" flow cannot be built

**Classes:** `GARP_ExamReg_EventDto`, `GARP_ExamReg_EventLoad`, `GARP_ExamReg_EventReg`
**Found:** 2026-08-30, while mapping event registration for the React portal.
**Scope:** blocks only the on-demand/replay branch. Registration for upcoming
events, webcasts and chapter meetings is fully unblocked — this is **not** a
blocker for building the event registration forms.

The legacy portal's one-click flow for a past webcast or a started/past chapter
meeting was: silently create a free registration, then open the recording —
`window.open(Webcast__r.On_Demand_URL__c)` / `window.open(ON24_URL__c)`. The
fields exist and are populated (`Webcast__c.On_Demand_URL__c`,
`Chapter_Meeting__c.ON24_URL__c`, `Event__c.ON24_URL__c`).

The new API carries the *flag* but never the *URL*:

- `GET examreg/event/info` → `EventView` has `isOnDemand: boolean` — and no
  URL field.
- `POST examreg/event/register` → `RegisterResult` has
  `registrationId / orderId / message / amountDue` — and no URL field.

So after a member registers for an on-demand webcast we can only say "you are
registered" with nothing to open. There is no client-side workaround: the URL
is the paywalled asset, and querying `Webcast__c` directly from the client
would bypass the registration gate the module exists to enforce.

**Ask:** return the join/replay URL from the API — for example on
`RegisterResult` after a successful registration, and/or on `event/info` when
`alreadyRegistered` is true. Returning it **only to registered callers** keeps
the gate intact; putting it on the unauthenticated `info` payload would leak
the recording to anyone with the event id.

**Meanwhile:** the React portal will ship registration for all three kinds and
show the confirmation without a watch link; the on-demand branch stays pointed
at the legacy behaviour until the field lands.

---

# B. Needs data seeded in `devjuly25a`

These are **verification** blockers, not bugs. In each case the code is written
and unit-tested, but the populated path has never run against real data — so it
ships unverified. Listed worst-first by how much is riding on it.

| # | What is missing | What it leaves unverified |
|---|---|---|
| B1 | **0 `ERP_Program` contracts** (the record type exists) | The whole ERP branch of the certification CV — the page, the 24-month bar, submission. FRM is fully verified; ERP is code-only. |
| B2 | **0 `CPE_Activity__c` records** | Browse CPD Activities: the populated list, facets, paging, and the new single-activity view. Only the empty and not-found states are verified. |
| B3 | **Exam notifications unreachable** — 17 `Member_Notification_Recipient__c` rows all have `Contact__c = null`, and 0 `Member_Notification_Exam_Site__c` rows | The dashboard Exam Notifications card and its dialog. `GET examNotifications` returns `[]` for every member. |
| B4 | **CPD claims and credits are near-empty** | The CPD page's pending/approved tables and the claim round-trip beyond a smoke test. |
| B5 | **Mobius vendor call-out fails in sandbox** | The eBook **Access** link. `GET eBookAccess` returns "Access link not returned", so the reader handshake is untested. The archive list itself is verified. |
| B6 | **0 `Errata__c` records** | Nothing yet — A1 blocks this regardless. |
| B7 | **No member can be signed in and out of good standing** — see below | The gated-content paywall's refuse-and-upsell branch. |

### B7 in detail — why the paywall's upsell branch cannot be reached

The two gates differ, and the gap between them is where the upsell lives:

- **Portal access** (`GARP_Portal_Access.verify`) needs a **non-Draft**
  Membership contract of any status.
- **Good standing** (`GARP_Portal_Core.inGoodStanding`) needs an **Activated**
  one specifically.

So the refused state needs a member whose newest Membership contract is
`Expired`. Two things make that unreachable here:

1. `Canceled` is **not in the status list** the contract query fetches
   (`Activated`, `Activated ( Auto-Renew )`, `Expired`, `Draft`, `Completed`),
   so all **37** cancelled memberships produce a 403 — no portal access at all,
   rather than access-without-standing.
2. There is exactly **1** `Expired` membership in the org, and its account also
   holds an `Activated` one, which wins.

Confirmed by running `GARP_Portal_Access.verify` over every candidate contact in
anonymous Apex: **zero** members are reachable-but-not-in-good-standing.

**To make it testable, seed one member whose only Membership contract is
`Expired`.** Worth doing — this is the portal's only conversion page and its
upsell path has never rendered.

Also worth confirming, separately: is a member with a cancelled membership
*meant* to be locked out of the portal entirely? That is what the omission of
`Canceled` from the query does today, and it may be deliberate.

**What IS well covered**, for contrast: FRM certification CV end to end
(including a real attachment upload verified byte-exact), the OSTA identity and
address flows, the member directory, the dashboard manifest, orders, and My
Account.

---

# C. Product questions — for GARP, not the backend developer

## C1. ✅ DECIDED — the 400-character minimum is enforced

**Decision (2026-08-24): keep it.** Now wired in the work-experience form with a
live character count, and verified in the browser: a 21-character description is
refused with *"Please write at least 400 characters so GARP can assess this
role."*

**One thing for the backend developer:** Apex still checks nothing, so the rule
holds only in our form. Anything else writing an `Experience__c` — the legacy
app, a data load, a crafted request — can still file a one-line description. If
the rule matters, it belongs in `GARP_Portal_CvService.saveExperience` too.

## C2. ✅ BUILT — gated content

**Decision (2026-08-24): built as a real route, without the auto-redirect.**
In good standing → an explicit "continue to the article" link. Not in good
standing → upgrade or renew. The legacy's two-second self-navigation is dropped:
a page that moves on its own is hostile to anyone reading slowly or using a
screen reader, and the link is right there.

`isMemberInGoodStanding` was already on the wire (confirmed in the live dashboard
identity payload); it is now typed and consumed. **No backend work was needed.**

Shipped at `/content`, with one change to their implementation: the gated URL is
validated against an allow-list before it is followed — see D4.

Original question kept below for context.

---

**Partly answered by artifact 2:** `/content` → `PortalGatedContent`, described
as "gate only — no service call". So there is no backend to build; it is
entirely a client-side decision, which makes the product question below the
*only* thing standing in the way.

The legacy renders `/content` by hijacking the app shell when a `garp_gated_url`
cookie is present, checks membership, and redirects after two seconds. We have
not built it, because guessing the intended behaviour of a **commercial paywall**
from that implementation seemed like the wrong call. Needs a decision on: who
sees it, what the upgrade path is, and whether the two-second auto-redirect is
intentional.

## C3. Should the demographics survey be part of registration?

`/registration/survey` is optional and skippable in the legacy, and it is why
members arrive at My Account with an empty Career Information card. Registration
otherwise lives in the old app — so this is really "do we own this step".

## C4. ✅ DECIDED — no breadcrumbs

**Decision (2026-08-24): deliberately not building them.** Our route tree is
three segments deep at most (`/programs/$programType/work-experience`) and every
subpage already carries a back link via `ProgramsSubpageHeader`. A second
navigation model on a shallow tree is cost without much benefit.

Recorded as a decision rather than left as an open gap, so it does not resurface
as "missing parity" on the next audit.

---

# D. Courtesy notes on GarpAppv1's own client

Not our code and not blocking us — flagged because they affect real members.

## D1. 🔴 `cvAddress` blanks the member's company and phone

**Re-checked against the resynced source on 2026-08-24: STILL OPEN.**
`PortalWorkExperience.tsx:558-565` still omits `company`, and line 488 still
seeds the mailing phone from `cv.ostaPhone`.

`PortalWorkExperience.tsx` builds the mailing address as:

```ts
mailingAddress: { street, city, state, postalCode, country, phone }   // no `company`
...
phone: cv.ostaPhone ?? ""      // seeds the MAILING phone from the OSTA phone
```

`saveAddress` assigns all seven Contact columns unconditionally, so:

- **`company` is never sent** → `Mailing_Address_Company__c` is nulled on every save.
- **`phone` is seeded from `cv.ostaPhone`**, which is null for every non-OSTA
  member → `HomePhone` is **wiped** whenever they save an address. For an OSTA
  member it writes the China phone into the mailing phone.

`GET cv` returns neither `company` nor `phone`, which is the trap — the form has
to be seeded from the personal-info payload instead. We do that, and verified a
save preserves `HomePhone`.

## D2. ✅ WITHDRAWN — our error, not theirs

`DashboardCards.tsx` uses `/gbiapp`, `/garpEPPPortal` and `/BenchPrepSSO` —
all correct. We raised this from artifact 1's *own* gap list, where it was
already marked Fixed; only a stale comment above the code still names the old
paths. Apologies for the noise.

## D4. 🔴 `/content` is an open redirect

`PortalGatedContent.tsx` sends the member to whatever the `garp_gated_url`
cookie contains, with no check on the destination:

```ts
function goToContent() {
	if (!gatedUrl) return;
	clearCookie("garp_gated_url");
	window.location.href = gatedUrl;   // ← unvalidated
}
```

…and the automatic forward does the same two seconds after the page loads.

Anything able to write that cookie can send a signed-in member anywhere. This
is the worst page in the portal for it: the member is *expecting* to be
forwarded, so they will not look twice at the destination, and they arrive from
a "members only" link, which is exactly the pretext a credential-phishing page
would want.

**Our version validates before navigating** — `https:` only, and the host must
be `garp.org` or a true subdomain. Worth copying; the shapes that catch people
out are all covered by tests on our side:

| Input | Why it must be refused |
|---|---|
| `https://garp.org.evil.example/x` | A naive `endsWith("garp.org")` lets this through |
| `//evil.example/x` | Protocol-relative — `new URL` parses it with *their* host |
| `javascript:alert(1)` | Executes rather than navigates |
| `http://www.garp.org/x` | Downgrades the member to plaintext |

---

## D3. ⚪ Their errata page will show empty selects

Same root cause as A1, which is still open — flagged so it is fixed once, not
twice.

---

# Summary — what artifact 2 changed

| Item | Was | Now |
|---|---|---|
| A2 dev-contact header | 🔴 dropped twice | ✅ **adopted in their own class** |
| A4 exam-setup fees | 🟠 no endpoint | ✅ **`examSetupFees` shipped 22 Aug** |
| A7 `examWindow` | ⚪ uncalled | ✅ called via the batch action |
| D2 sibling-app URLs | ⚪ wrong | ✅ **withdrawn — our error** |
| C2 gated content | ❓ unknown scope | Narrowed: no backend, client-only |
| A1 errata picklist | 🔴 | 🔴 **still open** — re-verified in source |
| D1 `cvAddress` data loss | 🔴 | 🔴 **still open** — re-verified in source |
| A3 A5 A6 | 🟠 ⚪ ⚪ | unchanged — not mentioned in artifact 2 |
| Section B (sandbox data) | 🟠 | unchanged; artifact 2 reports its own data gaps too |
| C1 400-char minimum | ❓ | ✅ **decided — enforced client-side** |
| C2 gated content | ❓ | 🟡 **decided — build, no auto-redirect** (not yet built) |
| C4 breadcrumbs | ❓ | ✅ **decided — deliberately not building** |

**The two that matter most are both still open:** A1 blocks errata entirely, and
D1 is live data loss on real Contact records.

## What building exam setup added (2026-08-24)

The wizard is built and verified live; these came out of doing it. A8 is the one
that blocks a feature.

| Item | Status | Effect |
|---|---|---|
| A8 no endpoint raises the fee order | 🔴 | **The paid half of exam setup cannot be completed.** Free changes ship; anything costing money is gated and handed to MyGarp. |
| A9 OSTA flag missing from the site payload | 🟠 | We cannot forecast OSTA fees, and a member moving into a China centre is not prompted for the OSTA block. Currently masked by the MyGarp hand-off. |
| A11 `examSetupAuthorize` sandbox safety | 🟠 | Scheduling stays behind a flag until confirmed. One constant to flip. |
| A10 blank-overwrites-value on `examSetupId` | ⚪ | Handled client-side. Recorded because it is D1's shape and will catch the next caller. |
| A12 stale docblock, shared FRM admin Id | ⚪ | No action. |

**Defer needed no backend work** — it turned out to be the same wizard, priced
by `GARP_Portal_ExamSetupFees`. There is nothing to ask for there.

## New things artifact 2 surfaced that we do not have

Not questions — work on our side, recorded here so it is not lost:

- ~~**`alertBar`**~~ ✅ **BUILT (2026-08-24).** Rendered in the app layout, so one
  fetch serves every page. All eight statuses and all five routes are mapped;
  `Exam Scheduling` and `Exam Registration` still leave for MyGarp, because
  exam setup and registration are not built here yet.
- ~~**`/courses/:courseType`**~~ ✅ **BUILT.** `pages/_appLayout/courses/$courseType/`
  → `CourseDetailPanel`, backed by `api/courses/`. Course detail is split out of
  `/programs/:programType` on our side too.
- ~~**`restoreCard`**~~ ✅ **BUILT (2026-08-24).** Dismiss now toasts an 8-second
  Undo. `api/dashboard/card-visibility.ts` holds both directions, since Apex is
  one method with a flag either way. Verified live against the sandbox: hide →
  Undo → the card returns and survives a reload.
- ~~**A batch action**~~ ⚪ **DECLINED — see D5.**
- ~~**`submitCase`**~~ ✅ **BUILT.** `api/help-center/submit-case.ts` →
  `use-submit-case` → `HelpCenterPanel`. The help centre does raise cases.

## D5. ⚪ We are not using `POST /batch` — and why

Not a defect, and no action wanted. Recording it so the endpoint's author does
not assume the client simply never noticed it.

`GARP_Portal_API.batchOf` is good work — per-action failures recorded rather
than thrown, each payload keeping its own `statusCode`, a sane `MAX_BATCH`. The
measurement in its header comment is real: `me 4 + dashboard 7 + ad 4 +
alertBar 7 + newNotification 5 = 27 SOQL`, roughly halved when batched.

We still fire the GETs in parallel instead, for two reasons:

1. **The saving is in redundant work, not in headroom.** The batch runs all
   actions sequentially in **one** transaction, so twelve actions share one
   10-second CPU budget and one 100-SOQL limit. Unbatched, each request gets its
   own. 27 is far below the per-transaction ceiling either way, so batching
   trades independent budgets for a shared one — and `alertBar` deliberately
   runs its own wide `Exam_Attempt__c` query on top of whatever it is batched
   behind.
2. **Latency becomes `sum` rather than `max`.** Two actions with heavy logic
   queue behind each other instead of overlapping.

React Query also removes most of the motivation: `alertBar` is mounted once in
the app layout with a stale time, so it is fetched about **once per session**
rather than once per page. Verified live — two full page navigations, one
`alertBar` request.

If the transaction ever does become the constraint, the endpoint is there and
adopting it is a client-side change only.
