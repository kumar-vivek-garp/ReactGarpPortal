# Registration forms — guest and member

FRM (`components/forms/frm/`) is the **reference implementation**. Every other
programme form — SCR, RAI/RAIJ, FRR, FFR, affiliate — follows the shape
described here. Read this before starting any of them.

This rule assumes `legacy-rewrite.md` (which repo is which), `commands.md`
(where to run builds), `project-structure.md` (the four component tiers) and
`theming.md` (tokens only). It does not repeat them.

---

## 1. Before writing anything: read GarpAppv1 for **logic only**

**STRICT. This is the rule that matters most, and the one most easily skipped.**

When asked to implement a registration form, the first action is to read how
`GarpAppv1` does it. Not to design a form. Not to guess field names. Not to
infer an endpoint from its name.

### Read the *deployed* copy, not the local checkout

The local `/Users/vivek.kumar/Documents/poc/GarpAppv1` working tree is **stale**
— it has already been out of date by entire features (it predated the whole
affiliate/membership programme kind, and a plan was written against the wrong
checkout because of it). Retrieve the live bundle first:

```bash
sf project retrieve start \
  --metadata UiBundle:GarpAppv1 \
  --target-org <alias> \
  --output-dir /tmp/garpv1bundle
# then read: /tmp/garpv1bundle/**/uiBundles/GarpAppv1/src/
```

If a claim about GarpAppv1 came from the local checkout, say so and re-check it
against the retrieved copy before relying on it.

### Take exactly these things

| Take from GarpAppv1 | Why |
|---|---|
| **Which endpoints exist**, and the order they are called | Invented endpoints fail at runtime, not at build |
| **Request/response shapes** and exact field names | Apex reads specific keys; a near-miss is silently dropped |
| **Validation rules**, character-for-character | ID formats, name character sets, length limits are regulatory, not cosmetic |
| **Conditional logic** — what shows when, what becomes required | The rules are non-obvious (payment type by country, OSTA by exam centre) |
| **Which branches key off `isAuthenticated`** | Guest vs member behaviour is a server contract, not a design choice |

### Take **none** of these

- Its components, JSX, class names, layout or styling.
- Its fetch layer, error handling, routing or state management.
- Its information architecture — where it puts a field on screen is its
  decision, not ours.

The instruction that produced this codebase was explicit: *"We will copy the
logic, of course, but not the UI UX. We will follow our UI UX, the modern style
design pattern."* A form that looks like GarpAppv1 has failed the brief even if
it works.

### Never read `sfdcapp` for this

It is a different application and will contradict GarpAppv1. Direct
instruction: *"in GarpAppv1 do not see what is in sfdcapp It will confuse you."*

### When the sources disagree

- `MyGarp` is the source of truth for **screens, copy and user flow**.
- `GarpAppv1` is the source of truth for **which APIs exist and their shapes**.
- If MyGarp shows a flow and GarpAppv1 has no API for it, **stop and tell the
  user.** Do not invent a GraphQL join to paper over a missing backend.

### Verify server behaviour against Apex, not against the client

The client is not the contract. Where behaviour matters — what is required,
what is validated, what is idempotent — read the Apex:

```bash
sf data query --use-tooling-api --target-org <alias> \
  -q "SELECT Body FROM ApexClass WHERE Name='GARP_ExamReg_API'"
```

Facts established this way that are **not** visible from the client: OSTA has no
server-side validation at all (every rule protecting it lives in our form);
`verifyAddress` checks the country only; `payOrder` is **not** idempotent and
must never be retried.

---

## 2. Two audiences, two routes

The same form is served to a signed-in member and to a visitor with no account.

| Audience | Route | Layout group |
|---|---|---|
| Member | `/programs/$programType/register` | `_programsFormLayout` |
| Guest | `/registration/$programType` | `_publicFormLayout` |

`/registration/<type>` is the legacy public address and is already in
circulation in GARP marketing email — keep it.

**There is no `/register` or `/registration` route for membership sign-up.**
Affiliate registration lives at `/affiliate`. Do not add one.

### Guards go on the leaf route, never on the layout

Both redirects need `params.programType`, and a pathless layout sitting above
that segment cannot see it. The layout groups exist **only** to supply chrome.

Guards live in `auth/registration-guard.ts` and are shared, not rewritten:

- `redirectGuestToPublicForm` — on the member route
- `redirectMemberToPortalForm` — on the public route

Both must:

- **Resolve the session synchronously on a cache hit.** An `async beforeLoad`
  always returns a Promise, which flashes the pending shell on every
  navigation. Follow the shape in `_appLayout/route.tsx`: `undefined` = not yet
  fetched, `null` = guest, object = member.
- **Carry `search` through the redirect.** A marketing link is
  `?regCode=TEAM24`; losing it on the bounce silently reprices the order.
- **Never redirect a payment return.** See below.

### The member route cannot live under `_appLayout`

`_appLayout`'s `beforeLoad` throws a guest to `/Login`, and a parent guard runs
before any child can decide otherwise. That is the entire reason
`_programsFormLayout` exists. It wears the same chrome via the shared
`components/organisms/app-layout-shell.tsx`. Both groups are pathless, so the
URL is unchanged.

### The payment return is sacred

The checkout success URL is built from `window.location` at submit time, so the
provider returns to **whichever route started the payment**, carrying `oid`/`on`
and nothing else. At that moment the order is already charged.

- Guards resolve the session but **suppress the redirect** when
  `isPaymentReturn(search)`.
- The outcome screen renders **before any query runs** — re-rendering the form
  behind a completed payment invites a second registration.

---

## 3. Folder structure for one form

**Only the component folder is per-programme.** Everything below it is shared
by programme *kind* — one `@RestResource` serves them all, so SCR and RAI reuse
the exam layer rather than forking it. Adding `scr-registration.ts` next to
`exam-registration.ts` is the wrong instinct.

```
src/
├── api/registration/            # SHARED — by kind, not by programme
│   ├── examreg-fetch.ts         # transport for every programme
│   ├── exam-types.ts            # contract for exam-kind programmes
│   ├── exam-registration.ts     # endpoint functions
│   ├── affiliate.ts             # membership-kind lives beside it
│   └── query-options.ts         # query keys
├── lib/                         # SHARED, pure, tested
│   ├── registration-presentation.ts   # rules + .test.ts
│   ├── registration-payloads.ts       # request builders
│   └── registration-paths.ts          # route patterns both guards import
├── hooks/                       # SHARED
│   ├── use-exam-registration.ts         # load + derived selection state
│   └── use-exam-registration-submit.ts  # the submit sequence
├── auth/registration-guard.ts   # SHARED
└── components/forms/<programme>/        # ← the only per-programme folder
    ├── <programme>-registration-panel.tsx   # load / skeleton / outcome switch
    ├── <programme>-registration-form.tsx    # layout + react-hook-form owner
    ├── <programme>-form-values.ts           # typed values + seed function
    └── sections/                            # one file per card
```

`components/forms/program-registration/program-registration-panel.tsx` is the
dispatcher: it branches on programme slug and renders the built form, falling
back to a placeholder so an unbuilt programme still gets a page rather than a
dead end. Register a new form there.

**Split by section, not by one large file.** Direct instruction: *"split logic
into multiple files under a form-specific folder."*

**Every rule that can be a pure function must be** — put it in `lib/` with a
test. `registration-presentation.ts` is the model: country/payment eligibility,
ID formats, which sections show, the submit label. A rule buried in JSX cannot
be tested and will be re-derived slightly differently in the next form.

---

## 4. Data access

Follow `salesforce-data-access.md` and `api-client-and-errors.md`. Registration
adds one thing:

### A guest cannot use the Data SDK

Before any POST the SDK fetches a CSRF token from `/ui-api/session/csrf`, a
Connect-family endpoint guests are not entitled to. `examregFetch` therefore
picks its transport: a memoised `GET examreg/whoami` probe up front, plus a
retry on the Connect refusal.

**This is the one sanctioned exception to "never call `fetch` for org data.**"
Do not generalise it, and do not remove it — without it every guest POST fails
while the initial GET still succeeds, which presents as *"the form loads but
nothing works."*

`whoami` is a real action of the module (`UserInfo.getUserType() != 'Guest'`),
guest-granted like the rest of it.

---

## 5. UI/UX contract

The registration form is a **checkout**, not a settings page.

- **70/30 split** — form in `lg:col-span-7`, order summary rail in
  `lg:col-span-3`. The rail does not scroll with the form.
- **One sticky bar** carries back link (members only), title, live total and the
  submit button. Fully opaque — content scrolling under a translucent bar reads
  as a rendering fault. **No negative margins**: they make the bar wider than
  its scroll parent and clip the back arrow.
- **The form title is the page's `h1`.** On the public route it is the only
  heading the document has, and that page is linked from marketing email — it
  must not be an `h2` under nothing. A guest also gets a larger title plus a
  muted supporting line naming the certification in full (GARP's own wording,
  not invented), because nothing else occupies the left of the bar for them and
  two lines balance the total-plus-button block opposite. A member keeps the
  single smaller line — the back link already sits there.
- **Reserve space for values that arrive late.** The total block is always
  rendered at a fixed `h-10` showing `Total —` before pricing, because a block
  that appears later resizes the bar and makes the header jump.
- **Animate value changes** with `@react-spring/web` (`AnimatedAmount`), and
  blur the total while re-pricing. Never CSS transitions — see
  `animation-and-state.md`.
- **Debounce pricing** (400ms) and key the query by the request so an
  out-of-order response cannot overwrite a newer total. `keepPreviousData` holds
  the last figure so it updates rather than blinking away.

### What a guest does **not** get

| Thing | Why |
|---|---|
| A back link | Every in-app parent is behind the session guard. Sending them to garp.org is *leaving*, not *back* — a back arrow must not promise that. Drop the adjacent divider with it |
| Any prefilled value | There is no contact record. `toFrmFormValues(null, …)` returns the empty set |
| Links to `/programs` or `/dashboard` | Both bounce to Login. The outcome screen offers garp.org and Sign In instead |
| The portal sidebar / alert bar | `_publicFormLayout` has its own chrome |

`_publicFormLayout`'s toolbar **must** stay `h-16` / `app:h-20` with a matching
spacer. This is load-bearing, not cosmetic: the forms size themselves with
`h-[calc(100vh-4rem)]` / `app:h-[calc(100vh-5rem)]`, so any other header height
pushes the sticky submit bar off-screen.

### Sign-in offers must be honest

Signing in is a full page navigation and **the form is not persisted**. Offer it
in the chrome, before anything is typed — not as a rescue halfway down. Where an
existing account is detected at submit (`mustSignIn`), the message must carry an
actual link and say plainly that they will start again.

Build the link with `getReturnPath(location)` and `LOGIN_PATH`. Do **not** copy
GarpAppv1's `handleSignIn`: it sends an absolute URL, which our own
`isSafeStartUrl` rejects, and its param casing differs from `AUTH_REDIRECT_PARAM`.

---

## 6. react-hook-form specifics

Follow `forms.md`. Registration forms add these, all learned the hard way:

- **Express conditional requiredness through `validate` closures reading
  `getValues` — never through a toggled `rules` object.** RHF registers `rules`
  once at mount and never re-reads them, so a rule switched off by a later
  choice carries on being enforced and the form becomes unsubmittable.
- **The submit button is disabled until the form is valid.** That needs
  `mode: "onTouched"` (not `onSubmit`, where `isValid` is not maintained;
  `onChange` re-renders far more and shouts at people mid-typing).
- **Anything not owned by RHF must be checked separately.** The exam selection
  is cascading state in a hook, so `isValid` cannot see it — sitting and exam
  centre are validated alongside it. Whatever else lives outside the form must
  be too.
- Conditionally-rendered required fields are safe: a field that unmounts stops
  counting towards `isValid`. Verified against the current version — if it ever
  changes, switching payment type would strand the button disabled with no
  visible field to fix.
- **`useWatch`, never the destructured `watch()`** — the latter returns a fresh
  function each render and opts the component out of memoisation.
- **Never hand a Radix `Select` a `value` of `undefined`.** It latches into
  uncontrolled mode and renders its placeholder for ever. Use `value ?? ""`.
- **Defaults belong in a pure derivation, not an effect.** Setting state in an
  effect to pre-select a sole option trips `react-hooks/set-state-in-effect`
  and races the first pricing call. `resolvePartSelection` is the pattern.
- **Consents always start unticked.** A tick recorded against a policy the
  candidate did not read this time is worthless.

---

## 7. Traps that have already cost real time

Each of these shipped as a bug once. Recognise them by symptom.

| Symptom | Cause | Fix |
|---|---|---|
| Payment confirmation replaced by an empty form after paying | The router **JSON-parses search values**, so `?stripe_return=1` arrives as the number `1`; `z.string()` rejects it and `.catch(undefined)` drops it silently | Accept `z.union([z.string(), z.number()])` and coerce back. Applies to *any* param that can be all digits — order numbers, team codes |
| Guest stuck on the skeleton for ever | A **disabled** React Query sits at `status: "pending"` permanently, so `profile.isPending` never clears | Gate the wait on actually having something to load |
| Form loads, every submit fails | The Data SDK's CSRF preflight 403s for guests | The transport split in §4 |
| Every request dies as `Failed to fetch` | `SFDC_ENV.apiPath` is `"/"` locally, so `"/" + "/services/…"` becomes `//services/…` — a protocol-relative URL resolving to host `services` | Strip the trailing slash before concatenating |
| A signed-in member shown guest chrome | Using `load.isAuthenticated` (the **server's** view) for a **client-routing** decision. They genuinely disagree on local dev, where the gateway signs in as a non-community user | Server payload governs submit behaviour; the client session governs where links may point |
| Whole files reformatted, huge spurious diff | Running `npx prettier --write` inside the UI bundle. The root `.prettierrc` targets **Apex/XML metadata only**, so it applies 2-space/single-quote defaults to a tabs/double-quote/no-semicolon codebase | **Never run prettier in the UI bundle.** `npm run lint` is the formatter of record |

Local dev caveat worth knowing before debugging auth: the CLI gateway signs
every request as an **admin**, so Apex sees a non-community user and reports
`isAuthenticated: false` with `contact: null`. Guest *UI* branches can be tested
locally via `sessionStorage["garpportal:local-logged-out"] = "1"`; the guest
*transport* cannot, because the local proxy rejects unsigned calls.

---

## 8. Definition of done

From the UI Bundle directory (`commands.md`): `npm run build`, `npm run lint`,
`npx vitest run --exclude "e2e/**"` — all clean. Then exercise it in a browser,
**both audiences**:

- Guest → public route renders with **nothing prefilled**
- Guest → member route redirects to the public form, `regCode` intact
- Member → public route redirects to the in-portal form, `regCode` intact
- Either → `?stripe_return=1&oid=…&on=…` **does not redirect** and shows the
  confirmation, including a purely numeric order number
- Submit disabled on an empty form, enabled only when complete, and **disabled
  again** if a required answer is removed
- The cart prices end to end
- Both themes

Add unit tests for every pure rule and for guard decisions
(audience × route × payment-return). Follow
`lib/registration-presentation.test.ts`.

**A deployed public route 403s until the guest profile is granted
`GARP_ExamReg_API` (Apex Class Access).** That grant lives on the guest Profile,
which is not tracked in this repo — it is an org-side change and a release
prerequisite, not a code bug. Localhost is unaffected.
