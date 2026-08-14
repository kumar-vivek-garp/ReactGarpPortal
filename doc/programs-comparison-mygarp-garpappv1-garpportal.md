# My Programs — three-repo comparison

**Purpose:** Document what MyGarp has for Programs, what GarpAppv1 implemented (or deferred), and what the new `garpportal` app already has vs what still needs frontend / backend work.

**Constraint:** New portal must use the new Apex REST stack (`GARP_Portal_*` via `/services/apexrest/memberportal/*`) and GraphQL/Data SDK where appropriate. **Do not use legacy `@RemoteAction` / `garpAppRemoter` / `GARP_MS_MemberPortal`.**

**Related detail inventory:** [`programs-detail-phase-b-mapping.md`](./programs-detail-phase-b-mapping.md) — MyGarp vs **sandbox-synced GarpAppv1** (`PortalProgramDetail`) vs garpportal. Local GarpAppv1 git was stale; org has Programs listing + detail. Use that doc to finish Phase B before Phase C.

| Repo | Role |
|------|------|
| **MyGarp** | Legacy production portal (AngularJS `sfdcApp` + newer Angular `garpApp2`) |
| **GarpAppv1** | Earlier React UI Bundle experiment — member portal without My Programs |
| **garp_portal** (`garpportal` UI Bundle) | Current React portal + new `GARP_Portal_*` Apex |

---

## 1. Executive summary

| Layer | Status |
|-------|--------|
| **Listing API** `GET …/memberportal/programs` | **Ready** in Apex (`GARP_Portal_ProgramsService`). Used by `garpportal`. **Not used** by GarpAppv1. |
| **Detail API** `GET …/memberportal/programDetail` | **Ready** in Apex (`GARP_Portal_ProgramDetailService`) with known gaps (see §5). **Read-only UI** in `garpportal` (`/programs/$programType`). Not used by GarpAppv1. |
| **Exam setup form API** `GET …/memberportal/examSetup` | **Partial** — read form is ported; write/wizard completion and order guard not ready (see §5). |
| **Exam registration checkout** | **Not in new portal API** — still lives in MyGarp registration flows (separate app / remoter). Listing CTA must deep-link out or wait for a new registration API. |
| **GarpAppv1 Programs UI** | **Explicitly deferred** — sidebar “Programs” → `garp.org`; no `/programs` route; no `fetchPrograms`. |
| **garpportal Programs UI** | **Listing + read-only detail** — tabs/cards; View Details in-app for FRM/ERP/SCR/RAIJ/RiskAI; Register → MyGarp; Learn More → garp.org. |

**Takeaway from GarpAppv1:** Programs was skipped because product/API work was incomplete for a full in-portal experience. The **listing + detail GET APIs now exist** in `garp_portal` Apex, so listing CTAs and a read-only (or mostly read) detail page are unblocked. Pay/register/setup **writes** and some study-resource fields are still blocked or partial.

---

## 2. How MyGarp structures Programs

MyGarp has **two** UI generations. Prefer **garpApp2** as the card-grid peer to the new React listing; use **legacy AngularJS** for the full action surface on the detail page.

### 2.1 garpApp2 (card listing — closest peer)

**Listing page:** In Progress / Completed / Explore Other sections with `app-program-card`.

| Card state | Fields | Primary CTA | Secondary CTA |
|------------|--------|-------------|---------------|
| **inProgress** | Logo, formal name, admin Part I/II names | **View Details** → `/programs/{type}` | — |
| **completed** | Logo, congrats copy | **View Details** → `/programs/{type}` | — |
| **other** (reg open) | Logo, name, description | **Register Now** → registration by `registrationPath` / type (`riskai`→`rai`, micro→`micro/{code}`) | **Learn More** → `https://www.garp.org/{type}` |
| **other** (reg closed) | Open-date copy | **Learn More** only | — |

**Detail page:** `/programs/:programType` — manage exam, pay/view order, setup, results, CV submission, completed-program actions (LinkedIn, certificate, etc.).

### 2.2 Legacy AngularJS (rich detail)

| Area | Routes / templates | Key actions |
|------|--------------------|-------------|
| Empty explore | `partials/programs.html` | Learn More, Register Now/Today, View/Pay/Remove order |
| Per-program detail | `partials/programs.type.html` + attempt/part cards | State machine: unpaid, setup incomplete/complete, deferred, expired, awaiting/results, register again/next |
| Exam setup | `programs.setup.html` | Wizard + fees checkout |
| Work experience | work-experience submission | Submit / resubmit CV |
| Certified bar | attempt card | Share LinkedIn, Download Certificate (SCR/RAI), Request copy (FRM), Directory Settings |
| Courses FFR/FRR | `programs.fbr.html`, `programs.icbrr.html` | eBook, eLearning SSO, schedule exam, certificate |
| Right rails | Study Center, Resources, My Programs switcher | Study materials, BenchPrep, eBooks |
| Dashboard widget | `dashboard-programs-card` | Condensed states + **View Full Details** |

Legacy data access: **`@RemoteAction` / `garpAppRemoter`** → `GARP_MS_MemberPortal` / `GARP_BC_MyPrograms`. **Do not port this call path into the new app.**

---

## 3. What GarpAppv1 has (and does not)

### 3.1 Explicit deferral

```text
// Programs still lives on the marketing site; there is no portal page for it.
sidebar → https://www.garp.org/frm/program-exams
```

**File:** `GarpAppv1/.../src/features/member-portal/config/navigation.ts`

### 3.2 Implemented member-portal surfaces (for context)

| Feature | Route / API |
|---------|-------------|
| Dashboard | `/dashboard` → `GET …/memberportal/dashboard` |
| My Account | `/my-account` → account + profile |
| Membership | `/membership` |
| Exam results | `/exam-results` → `examResults` |
| Study materials | `/study-materials` → `studyMaterials` (catalogue “programs” ≠ My Programs enrollment) |
| Events | `/events` |
| Help center | `/help-center` |
| Purchase history | `/purchase-history` → `orders` |

**API client:** `portalApi.ts` — **no** `programs`, **no** `programDetail`, **no** `examSetup`. Comments: does not call legacy remoter.

### 3.3 Programs-adjacent only

| Item | Notes |
|------|--------|
| Dashboard `ExamRegistration` card type | Types + design preview; CTA in preview points to **`/programs` which does not exist** |
| Study materials `programs[]` | Catalogue filter (FRM/SCR materials), not enrollment listing |
| Top nav “Program and Exams” | External `garp.org` links |

### 3.4 What GarpAppv1 tells us about API readiness (at the time it was built)

- Team chose **not** to ship an in-app My Programs page.
- They still anticipated a future `/programs` route (preview mock CTA).
- They already consumed other **new** memberportal REST actions — so the pattern for Programs should match that stack once endpoints exist.

**In `garp_portal` Apex today, listing + detail GET exist; GarpAppv1 simply never wired them.**

---

## 4. What `garpportal` (new app) has today

### 4.1 UI

| Item | Status |
|------|--------|
| Route `/programs` with tabs (All / In Progress / Completed / Explore Other) | **Done** |
| Card grid + empty states + loading | **Done** |
| `GET /memberportal/programs` client (`api/programs/*`) | **Done** |
| In Progress / Completed card CTAs (**View Details**) | **Missing** |
| Explore **Register Now** | Present but **disabled** (`url="#"`) |
| Explore **Learn More** | Only if `policyURL` set — MyGarp uses `https://www.garp.org/{type}` |
| Route `/programs/$programType` (detail) | **Missing** |
| `programDetail` / `examSetup` API clients | **Missing** |
| Exam setup wizard UI | **Missing** |
| Registration wizard (in-app) | **Missing** (MyGarp has full `/registration/...`) |
| CPD on programs page | **Missing** (Apex `cpd*` exists; separate product decision) |

**Key files:**

- `uiBundles/garpportal/src/pages/_appLayout/programs/index.tsx`
- `…/components/organisms/programs-panel.tsx`
- `…/components/molecules/program-card.tsx`
- `…/api/programs/*`

### 4.2 Apex already available to the new app (no RemoteAction)

Base: `@RestResource(urlMapping='/memberportal/*')` → `GARP_Portal_API`.

| Action | Service | Programs relevance |
|--------|---------|-------------------|
| `GET programs` | `GARP_Portal_ProgramsService` | Listing buckets — **ready** |
| `GET programDetail?programType=` | `GARP_Portal_ProgramDetailService` | Detail behind View Details — **ready with gaps** |
| `GET examSetup?programType=` | `GARP_Portal_ExamSetupService` | Setup wizard step 1 form — **read ready; writes not** |
| `GET examResults` | `GARP_Portal_ExamResultsService` | Related; page may already exist elsewhere |
| `GET examNotifications` | `GARP_Portal_NotificationsService` | Detail side content |
| `GET studyMaterials` / `myEBooks` / `eBookAccess` | Study materials services | Study Center peer |
| `GET cpd` / `cpdProgram` / … | CPD services | Certified / directory adjacent |
| `GET orders` | Orders | View order on detail (read) |

**No POST** in `GARP_Portal_API` today for: pay order, cancel order, complete exam setup, submit registration, download certificate request, etc.

---

## 5. New API readiness vs MyGarp actions

Legend: **Ready** = can build UI against existing endpoint · **Partial** = endpoint exists but fields/behavior incomplete · **Blocked** = needs Apex (or external product) before UI · **External** = leave as link out of portal for now

### 5.1 Listing card actions

| Action | MyGarp | New Apex | garpportal UI | Verdict |
|--------|--------|----------|---------------|---------|
| View Details | `/programs/{type}` | `programDetail` | In-app `/programs/{slug}` (Apex-supported types); MyGarp for others | **Implemented** (read-only) |
| Register Now | Registration app by path | `registrationPath` on listing payload; **no portal registration POST** | Disabled stub | **External** link using `registrationPath` / known registration base, **or** Blocked until registration API |
| Learn More | `garp.org/{type}` | `policyURL` on catalogue | Partial | **Ready** (prefer org URL; fallback `policyURL`) |

### 5.2 Detail page — in progress / exam states

| Action / content | MyGarp | New Apex notes | Verdict |
|------------------|--------|----------------|---------|
| Program + part state machine | Yes | `programState`, `examPart1Info` / `examPart2Info` | **Ready** (read) |
| Exam date / site / provider / ID / OSTA display | Yes | Populated on detail DTO | **Ready** (read) |
| View Order | Yes | Order id fields; `orders` list | **Partial** — show if id present; pay/cancel Blocked |
| Pay / Cancel order | Yes | `GARP_BC_Orders` **unported**; no POST | **Blocked** |
| Finish Setup / Exam Setup | Yes | `GET examSetup` form; **no write POST**; pending-reschedule order guard **NOT PORTED** | **Partial read / Blocked write** |
| Visit provider (Pearson/PSI/ATA) | Yes | Access URL fields when present | **Ready** if URL returned |
| View Exam Results | Yes | Detail flags + `examResults` | **Ready** (navigate to results) |
| Register again / Add Part II | Yes | Reg window fields; `CanRegPartI` / `CanAddPartII` **always null** (eligibility unported) | **Partial** — can show open window; eligibility flags missing |
| Work experience submit | Yes | `cvStatus` on detail; submission flow not in Portal API | **Partial / Blocked** for submit |
| Exam resources (eBooks, BenchPrep, ADA) | Yes | Explicitly **NOT PORTED** — nulls | **Blocked** (use study-materials endpoints separately where possible) |

### 5.3 Detail page — completed / certified

| Action | MyGarp | New Apex | Verdict |
|--------|--------|----------|---------|
| Congrats + badge URL | Yes | `digitalBadgheURL`, `certificateDownloadURL` | **Ready** when populated |
| Share on LinkedIn | Yes | Badge URL | **Ready** (client modal + URL) |
| Download Certificate | SCR/RAI | `certificateDownloadURL` | **Ready** if URL set |
| Request copy of certificate | FRM checkout | No portal cert-checkout API found | **Blocked / External** |
| Directory Settings | Yes | Account / membership prefs (existing) | **Ready** (link to My Account / directory) |

### 5.4 Explore / unpaid order on explore cards (legacy)

| Action | Verdict |
|--------|---------|
| View / Pay / Remove pending registration order on explore card | **Blocked** without orders write APIs; optional later via `orders` read + external pay |

---

## 6. Side-by-side matrix (high level)

| Capability | MyGarp | GarpAppv1 | garpportal |
|------------|--------|-----------|------------|
| In-app Programs nav | Yes | External marketing only | Yes (`/programs`) |
| Listing API client | Legacy remoter / Angular services | **None** | **Yes** (`programs`) |
| Listing UI (3 buckets) | garpApp2 yes; legacy different | **No** | **Yes** |
| View Details CTA | Yes | No | **Yes** (in-app for supported types) |
| Register / Learn More wired | Yes | Preview mock only | **Yes** (MyGarp / garp.org) |
| Detail page | Yes | No | **Yes** (read-only) |
| Detail API | Legacy | No client | Apex + **client** (`programDetail`) |
| Exam setup wizard | Yes | No | Apex GET **exists**, UI **missing** |
| Registration checkout | Yes (in-app) | No | **No** (not in Portal API) |
| Certified CTAs | Yes | No | **Partial** (badge/cert URLs when present) |
| Study Center on programs | Yes (rail) | Separate study-materials page | Separate `/study-materials` |
| Uses RemoteAction | **Yes** | **No** (new REST) | **No** (new REST) |

---

## 7. Recommended implementation phases (no code yet — planning only)

### Phase A — Listing CTAs only (**done**)

1. **View Details** on In Progress + Completed — Phase A used MyGarp; Phase B switched Apex-supported types to in-app.
2. **Learn More** → `https://www.garp.org/{mappedType}` (RAI mapping), fallback `policyURL`.
3. **Register Now** when `isRegistrationOpen` — MyGarp `/sfdcApp#!/registration/…`.
4. Do **not** invent registration POST against Portal API.

### Phase B — Program detail (**done** — read-only)

1. Client for `GET programDetail?programType=` (`fetchProgramDetail` / `useProgramDetail`).
2. In-app route `/programs/$programType` + states from `programState` / exam part states (`program-detail-panel`).
3. Wired safe links: provider access URL, badge, certificate download, Membership directory.
4. Unpaid order **read** messaging only; Pay/Cancel deferred.

### Phase C — Exam setup (depends on backend writes + order guard)

1. Consume `GET examSetup` for step 1 UI.
2. **Wait** for Chinnappa: setup save POSTs + pending-reschedule guard (documented NOT PORTED).

### Phase D — Full parity / later

- Work experience submission API + UI  
- Certificate request checkout  
- Eligibility flags (`CanRegPartI` / `CanAddPartII`)  
- Exam resources on detail (or keep Study Materials page as source of truth)  
- FFR/FRR course-specific panels if still in scope  
- Explore-card pending-order pay flow  

---

## 8. Questions for backend (Chinnappa) before Phase C/D

1. Intended URL for **Register Now** from Experience (registration site path / startURL)?
2. Timeline for **Orders** port (pay / cancel / unpaid deferral order id)?
3. Timeline for **exam setup write** endpoints + reschedule-order guard?
4. Should **exam resources** on detail stay null forever and UI use `studyMaterials` / `myEBooks` only?
5. Certificate **request copy** — new Portal action or keep MyGarp checkout URL?

---

## 9. Source index

### MyGarp

- Listing cards: `staticresources/garpApp2/main.js` → `ProgramCardComponent`
- Legacy explore: `…/partials/programs.html`, `…/shared/components/my-programs-exam-info-card/`
- Legacy detail: `…/partials/programs.type.html`, `…/modules/my-programs/components/*`
- Dashboard widget: `…/dashboard-programs-card/`

### GarpAppv1

- Deferral: `uiBundles/GarpAppv1/src/features/member-portal/config/navigation.ts`
- API client: `…/api/portalApi.ts` (no programs)
- Routes: `…/src/routes.tsx`
- Preview mock `/programs` CTA: `…/preview/previewData.ts`

### garp_portal

- Apex router: `classes/GARP_Portal_API.cls`
- Listing: `GARP_Portal_ProgramsService.cls`
- Detail: `GARP_Portal_ProgramDetailService.cls`
- Setup: `GARP_Portal_ExamSetupService.cls`
- UI listing: `uiBundles/garpportal/src/components/{organisms/programs-panel,molecules/program-card}.tsx`
- UI detail: `uiBundles/garpportal/src/components/{organisms/program-detail-panel,molecules/programs-subpage-header}.tsx`
- UI route: `uiBundles/garpportal/src/pages/_appLayout/programs/$programType/index.tsx`
- UI API: `uiBundles/garpportal/src/api/programs/*`

---

## 10. Bottom line

- **MyGarp** = full Programs product (listing + detail + setup + registration + certified actions), on legacy remoter.
- **GarpAppv1** = consciously **skipped** My Programs; marketing links only — useful signal that full parity was not assumed ready then.
- **garpportal** = listing UI + **read-only detail** (`/programs/$programType`) via `programDetail`; Register/Learn More external; setup writes / pay / CV submit still deferred.
- **Phase A + Phase B (read detail) are implemented.** Registration checkout, order payment, setup writes, and some eligibility/resource fields still need backend or external links — **do not use RemoteAction** as a shortcut.
