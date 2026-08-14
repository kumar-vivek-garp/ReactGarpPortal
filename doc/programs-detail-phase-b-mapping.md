# Program detail mapping — MyGarp vs GarpAppv1 vs garpportal

**Purpose:** Finish the Phase B (Phase 2) inventory — what the **in-app program detail** page contains in MyGarp, what GarpAppv1 built (sandbox), and what `garpportal` `/programs/{type}` currently shows vs still missing.

**Date:** 2026-08-13 (updated after sandbox sync)  
**Scope:** Detail page behind **View Details** (not listing CTAs alone).  
**Related:** [`programs-comparison-mygarp-garpappv1-garpportal.md`](./programs-comparison-mygarp-garpappv1-garpportal.md)

**Repos**

| Repo | Role |
|------|------|
| **MyGarp** | Production detail (`garpApp2` `/programs/:program`) |
| **GarpAppv1** | React UI Bundle **deployed on `devjuly25a`** — includes Programs listing + detail + exam-setup **read** UI |
| **garpportal** | Current React UI Bundle — Phase B **thin** read-only detail |

### Important: local GarpAppv1 git was stale

The **checked-in** GarpAppv1 repo (sidebar → garp.org, no `/programs`) is **behind the org**.

Synced from sandbox on 2026-08-13:

```bash
sf project retrieve start -o devjuly25a \
  --metadata "UIBundle:GarpAppv1" \
  --metadata "ApexClass:GARP_Portal_ProgramDetailService" \
  # …plus related Portal / MemberPortal Apex
  --target-metadata-dir .sandbox-sync
```

Retrieved sources live under:

`GarpAppv1/.sandbox-sync/unpacked/unpackaged/uiBundles/GarpAppv1/`

Key sandbox files:

| File | Role |
|------|------|
| `…/pages/PortalPrograms.tsx` | Listing (In Progress / Completed / Explore) |
| `…/pages/PortalProgramDetail.tsx` | Detail behind View Details |
| `…/pages/PortalExamSetup.tsx` | Exam setup step 1 (read; Next disabled) |
| `…/api/portalApi.ts` | `fetchPrograms`, `fetchProgramDetail`, `fetchExamSetup` |
| `…/config/navigation.ts` | Sidebar **Programs** → `/programs` (in-app) |
| `…/routes.tsx` | `programs`, `programs/:programType`, `programs/exam-setup/:programType` |

**Primary React reference for Phase B parity = sandbox GarpAppv1 `PortalProgramDetail`, not the stale local git tree.**

---

## 1. Executive verdict

| Question | Answer |
|----------|--------|
| Did local git GarpAppv1 have Programs? | **No** (stale). |
| Does **sandbox** GarpAppv1 have Programs detail? | **Yes** — substantial MyGarp-aligned read UI. |
| Did we finish Phase B in garpportal? | **No** — thin shell vs sandbox GarpAppv1 / MyGarp. |
| Best path to complete Phase B? | Port UI patterns from **sandbox `PortalProgramDetail`** onto garpportal (same Apex `programDetail`). |
| Before Phase C? | Close detail read parity first; exam-setup writes still blocked. |

---

## 2. Routes and entry

| Capability | MyGarp (garpApp2) | GarpAppv1 (**sandbox**) | garpportal |
|------------|-------------------|-------------------------|------------|
| Listing | `/programs` | ✅ `/programs` | ✅ `/programs` |
| Detail | `/programs/:program` | ✅ `/programs/:programType` | ✅ `/programs/$programType` (thinner) |
| Exam setup | `/programs/exam-setup/:program` | ✅ `/programs/exam-setup/:programType` (read; Next disabled) | ❌ |
| View Details | In-app | ✅ In-app for certification types | ✅ In-app FRM/ERP/SCR/RAIJ/RiskAI; MyGarp for FFR/FRR/micro |
| Breadcrumb | Programs → name | ✅ Home icon + Programs → formalName | ✅ Back + title |
| Sidebar Programs | In-app | ✅ `/programs` | ✅ `/programs` |

**API (all React portals):** `GET …/memberportal/programDetail?programType=` via `GARP_Portal_ProgramDetailService`.

Sandbox GarpAppv1 also calls `programs`, `examSetup`, and related Portal actions from the same `portalApi` base.

---

## 3. Program types on detail

| Type | MyGarp | GarpAppv1 sandbox | garpportal |
|------|--------|-------------------|------------|
| FRM / ERP / SCR / RAIJ / RiskAI | ✅ Full | ✅ `PortalProgramDetail` | ⚠️ Partial |
| FFR / FRR / FRR25 / micro | ✅ Course panels | ❌ (not in this page; listing may still surface) | ❌ MyGarp from listing |

---

## 4. Program-level states

| State | MyGarp | GarpAppv1 sandbox | garpportal |
|-------|--------|-------------------|------------|
| **ExamAttempt** | Notifications, Manage Exam, parts, ID, OSTA, sidebar | Part cards + ID card + deadlines + resources rails | Part cards only (subset) |
| **CVSubmission** | CV card + submit flow | Congrats + `cvStatus` (no submit CTA) | Same idea — message only |
| **EnrollmentExpired** | Expired + Register | Warning + Register Again → MyGarp registration | Message + Register Now |
| **Completed** | Congrats + LinkedIn / cert / request copy | Certified card + Download Certificate + Digital Badge | Congrats + badge/cert + Directory |

---

## 5. Detail layout comparison

| Section | MyGarp | GarpAppv1 sandbox `PortalProgramDetail` | garpportal |
|---------|--------|------------------------------------------|------------|
| Two-column grid | ✅ | ✅ Main + right rail | ❌ Single column |
| Per-part **labelled rows** (Admin, Format, Provider, Date, Site) | ✅ | ✅ Always shows labels (empty ok) | ⚠️ Free-form text lines only |
| Part state–specific copy | ✅ Full machine | ✅ Switch on every `examPartState` + `RESULT_COPY` | ⚠️ Humanized enum + sparse fields |
| Hide stale pass cards | ✅ | ✅ `isResultStale` → hide card | ❌ |
| Edit admin → exam setup | ✅ | ✅ when `isSchedulingOpen` / `isDeferralOpen` | ❌ |
| Schedule Exam / Exam Setup / Take Exam | ✅ | ✅ (`showTakeExam` + access URL; else setup link) | ⚠️ Provider URL only |
| View Order (unpaid) | ✅ | ✅ → `/sfdcApp#!/order/{id}` | ❌ Text only |
| Digital Badge on part | ✅ | ✅ `badgePageURL` | ✅ |
| ID Information card | ✅ Full | ✅ Name + phone (subset of ID fields) | ❌ |
| OSTA card | ✅ | ❌ Not rendered (fields in types) | ❌ |
| Manage Exam / Defer / Add Part II / ADA | ✅ | ❌ Not as separate Manage card | ❌ |
| Notifications card | ✅ | ❌ (type exists; not on detail page) | ❌ |
| Deadlines rail | ✅ | ✅ `examDeadlines` | ❌ |
| Exam Resources rail | ✅ | ✅ Study Materials + Errata + GLP/ADA when URLs exist | ❌ |
| LinkedIn share / Request cert copy | ✅ | ❌ | ❌ / Directory only |

---

## 6. Exam part state matrix (sandbox GarpAppv1 vs garpportal)

| `examPartState` | GarpAppv1 sandbox body | GarpAppv1 CTAs | garpportal |
|-----------------|------------------------|----------------|------------|
| **Unpaid** | Warning + pay-by date | View Order (MyGarp hash) | Unpaid text only |
| **Deferred** | Deferred to admin + setup open date | Edit → setup if open | Admin name only |
| **AwaitingSchedulingToOpen** | “Exam setup opens {date}” | — | Weak / generic |
| **SchedulingOpen** | Scheduled vs “setup is open” + deadline | Schedule Exam / Exam Setup | Provider link if URL |
| **SchedulingClosedNeverScheduled** | Registration expired + register-again copy | — | Partial |
| **SchedulingClosedAwaitingToTakeExam** | “You are scheduled…” | Take Exam if flagged | Provider link possible |
| **SchedulingClosedAwaitingResults** | Statement / preparing | — | Statement if present |
| **SchedulingClosedResultsAvailable** | Legacy `RESULT_COPY` sentences | Digital Badge if URL | Result string only |

---

## 7. CTAs matrix (detail)

| Action | MyGarp | GarpAppv1 sandbox | garpportal |
|--------|--------|-------------------|------------|
| Visit / Take Exam (provider URL) | ✅ | ✅ Take Exam | ⚠️ “Visit exam provider” |
| Schedule / Exam Setup | ✅ | ✅ → `/programs/exam-setup/{slug}` | ❌ |
| View Order | ✅ | ✅ MyGarp order hash | ❌ |
| Register Again (expired) | ✅ | ✅ MyGarp registration | ✅ |
| Download certificate / Digital badge | ✅ | ✅ | ✅ |
| Directory settings | ✅ | ❌ on this page | ✅ Membership directory |
| CV submit | ✅ | ❌ message only | ❌ message only |
| Pay / Cancel / Defer write | ✅ | 🔒 | 🔒 |
| Exam setup **save** / ID step advance | ✅ | 🔒 Next disabled | 🔒 Phase C |

---

## 8. What sandbox GarpAppv1 still does *not* cover (vs MyGarp)

Even the org-deployed React detail is **not** full MyGarp:

- No Manage Exam card (deferral order, Add Part II, ADA from manage panel)
- No OSTA edit card
- No exam-notifications card on detail
- No LinkedIn share / request certificate copy
- No FFR/FRR/micro course detail components
- Exam resources: many Apex fields still null (NOT PORTED); UI still shows Study Materials + Errata always
- Exam setup: **read-only step 1**; writes + pending-reschedule guard not ported

---

## 9. Gap: garpportal vs sandbox GarpAppv1 (Phase B “complete” target)

Use **sandbox `PortalProgramDetail`** as the checklist for finishing Phase B in garpportal (same Apex):

### High priority (read UI already proven in GarpAppv1)

1. Two-column layout: part cards + **Deadlines** + **Exam Resources** rails  
2. Part cards with **labelled rows** (Format, Provider, Date, Site) + state-specific copy (`RESULT_COPY`, unpaid warning, etc.)  
3. CTAs: **Schedule Exam / Exam Setup** link (route can stub or deep-link later), **Take Exam**, **View Order**, **Digital Badge**  
4. **ID Information** card when part present  
5. Hide `isResultStale` parts  
6. Edit link beside administration when scheduling/deferral open  

### Medium

7. Richer Completed / CVSubmission / EnrollmentExpired copy matching GarpAppv1 strings  
8. Empty / 401 enrollment messaging like GarpAppv1 `PortalEmpty`  
9. Extend React `ProgramDetail` types to include ID, deadlines, resources, notifications (Apex already returns them)

### Leave for Phase C / D

- Exam setup wizard writes + ID step save  
- Pay / cancel / deferral order APIs  
- Work-experience submit  
- Eligibility Register / Add Part II  
- Full MyGarp Manage Exam / OSTA / LinkedIn / cert-checkout  

---

## 10. Apex note

Sandbox also has `GARP_MemberPortal_Programs` (older MemberPortal stack) **and** `GARP_Portal_ProgramDetailService` / `GARP_Portal_ProgramsService`.  
GarpAppv1 sandbox UI comments and `portalApi` target the **Portal** REST actions (`programs`, `programDetail`, `examSetup`) — same family garpportal uses.

---

## 11. Key paths

### MyGarp

- `staticresources/garpApp2/main.js` (compiled exam-details)

### GarpAppv1 sandbox retrieve (authoritative for React detail)

- `GarpAppv1/.sandbox-sync/unpacked/unpackaged/uiBundles/GarpAppv1/src/features/member-portal/pages/PortalProgramDetail.tsx`
- `…/PortalPrograms.tsx`, `…/PortalExamSetup.tsx`
- `…/api/portalApi.ts`, `…/types.ts`, `…/routes.tsx`

### garpportal

- `uiBundles/garpportal/src/components/organisms/program-detail-panel.tsx`
- `…/api/programs/program-detail.ts`, `types.ts`
- `…/pages/_appLayout/programs/$programType/index.tsx`

---

## 12. Bottom line

- Local GarpAppv1 git looked empty for Programs because it was **out of sync** with `devjuly25a`.  
- **Sandbox GarpAppv1 already implemented** listing + a MyGarp-aligned **read-only detail** (+ exam-setup read).  
- **garpportal Phase B is behind that sandbox UI.** Completing Phase 2 means bringing garpportal detail up toward `PortalProgramDetail`, then Phase 3 for setup writes.  
- Next practical step: keep using `.sandbox-sync` as reference (or re-retrieve into the GarpAppv1 working tree) and port section-by-section into `program-detail-panel.tsx`.
