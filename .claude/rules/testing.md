# Testing — layers, placement, and file discipline

Applies to the UI Bundle only. Assumes `commands.md` (where commands run),
`project-structure.md` (the component tiers), and `context7-required.md`
(fetch current docs for Vitest / Testing Library / MSW / Playwright before
writing test code — test APIs change across majors, and this project is on
Vitest 4 and Playwright 1.49).

## The three layers

Every test belongs to exactly one layer. **Always write the assertion at the
lowest layer that can express it** — a rule that can be tested as a pure
function must not become a component test, and a behavior expressible as a
component test must not become an e2e test.

| Layer | Tool | Environment | What it covers |
|---|---|---|---|
| 1 — Pure logic | Vitest | no DOM rendering | `lib/` rules, payload builders, guard decisions, config derivations, transport selection |
| 2 — Component / hook | Vitest + Testing Library | jsdom | forms, behavioral molecules/organisms, React Query hooks (`renderHook`) |
| 3 — E2E smoke | Playwright | real Chromium against built `dist/` | app boots, routing, guard redirects, 404, both themes |

Layer 3 stays **thin** (order of ~10 specs, not ~100). It exists to catch
"the built app is broken in a real browser", not to re-verify behavior that
layer 2 already covers. It runs against a static `dist/` build with Playwright
route interception — **never against a live org**; org-dependent e2e is not
part of the automated suite.

## Placement — where test files live

- **Co-located, always**: `foo.ts` → `foo.test.ts` in the same folder;
  `foo.tsx` → `foo.test.tsx`. This is the established pattern (58 files
  already follow it). Never create a parallel `__tests__/` tree.
- **E2E specs only in `e2e/`** at the bundle root. Vitest runs exclude them
  (`--exclude "e2e/**"`); Playwright's `testDir` is `e2e/`.
- **Shared test infrastructure in `src/testing/`** — the only new top-level
  `src/` folder testing introduces:

```
src/testing/
├── render.tsx        # renderWithProviders — QueryClient (retries off), router, theme
├── factories/        # one file per API domain (session.ts, exam-load.ts, events.ts, …)
└── msw/
    ├── server.ts     # MSW server setup, wired from vitest.setup.ts
    └── handlers/     # one file per api/ domain, mirroring src/api/'s folders
```

- **Direction of imports is one-way**: test files import from `src/testing/`;
  nothing under `src/` outside a `.test.*` file may ever import from
  `src/testing/`. It must be impossible for a factory or mock to ship.

## Short files — the discipline

- **One source file → one test file** by default.
- When a test file would exceed **~250 lines**, split it **by behavior**, not
  by stuffing more `describe` blocks in: `<source>.<aspect>.test.tsx`.
  Precedent already in-tree: `bento-grid.test.tsx` + `bento-grid.drag.test.tsx`.
  Good aspect names describe the behavior under test
  (`frm-registration-form.country-cascade.test.tsx`), not vague buckets
  (`...part2.test.tsx`).
- The same cap applies to `src/testing/` itself: one factory file per domain,
  one handler file per api domain. A 600-line `factories.ts` is the exact
  failure mode this folder structure exists to prevent.
- Extract repeated setup into a local helper *inside* the test file first;
  promote it to `src/testing/` only when a second test file actually needs it
  — same promotion rule as molecules in `project-structure.md`.

## What to test — and what not to

- **Test observable behavior, not implementation.** Query the DOM by
  accessible role/label/text (`getByRole`, `getByLabelText`) — never by CSS
  class, never by DOM traversal. A test that breaks on a styling refactor is
  asserting the wrong thing.
- **No snapshot tests.** They assert everything and therefore nothing, and
  they rot into "press u to update".
- **Purely presentational components get no test.** A test that renders JSX
  and asserts the JSX rendered is maintenance weight with zero protection.
  Test a component only when it has behavior: conditional rendering, user
  interaction, state, derived output.
- **Every client-side trap in `registration-forms.md` §7 gets a regression
  test** — those all shipped as real bugs once, which is the strongest
  possible evidence the test pays for itself. When a new bug is fixed
  anywhere in the bundle, the fix lands with the test that would have caught
  it.
- Guard tests cover the full decision matrix: audience × route ×
  payment-return, per `registration-forms.md` §8.

## Mocking — MSW at the network edge

- **MSW is the standard.** Handlers fake the HTTP responses; everything
  between the component and the wire — the api/ functions, `examregFetch`'s
  guest/CSRF transport split, error normalization in `api/client/` — runs
  for real. That transport code is where real bugs have lived; mocking it
  away un-tests it.
- **`vi.mock` of application modules is the exception, not the default**, and
  each use carries a one-line comment saying why MSW couldn't serve the case
  (e.g. faking the Data SDK singleton itself where no HTTP boundary exists).
- **Legacy pattern — do not imitate:** six pre-MSW tests under `src/api/`
  mock `@salesforce/platform-sdk`'s `createDataSDK` wholesale
  (`vi.mock` + hand-built `Response`). They stay as-is by explicit decision,
  but every NEW api/hook/component test goes through MSW instead — the
  wholesale mock bypasses URL building, CSRF, and retry, which is exactly
  the code MSW exists to exercise.
- The MSW/jsdom shims live in `vitest.setup.ts` and are load-bearing: the
  `caches` stub (the SDK's CSRF manager needs CacheStorage) and the
  `Request`/`fetch` wrappers that resolve the SDK's relative URLs against
  the jsdom origin (Node's fetch rejects them otherwise). Don't remove
  either; symptom of loss is every MSW test failing with `ERR_INVALID_URL`
  or a CacheStorage `ReferenceError`.
- Handlers in `src/testing/msw/handlers/` define the *default* happy-path
  org; individual tests override per-request with `server.use(...)` to model
  errors, delays, and edge payloads. Defaults live in one place so 50 tests
  don't each redefine what a session looks like.
- Factory data must satisfy the generated GraphQL / api types — factories are
  typed against `src/api/`'s types so a contract drift breaks compilation,
  not just runtime.

## Determinism

- **No real timers in tests of debounced/animated code** — `vi.useFakeTimers()`
  and advance explicitly (the 400ms pricing debounce, toast durations).
- **No real dates** — pass fixed dates in, or `vi.setSystemTime`.
- A test that needs `waitFor` with a raised timeout to pass is flaky by
  construction — fix the awaited signal, don't raise the timeout.

## Running

From the UI Bundle directory (`commands.md`):

| Command | Purpose |
|---|---|
| `npx vitest run --exclude "e2e/**"` | The unit/component suite, one-shot (CI shape) |
| `npm run test` | Same suite in watch mode (local dev) |
| `npm run build:e2e` | Build `dist/` + rewrite assets for static serving |
| `npx playwright test` | E2E smoke against the built `dist/` |

Definition of done for any task that touches code: the `commands.md`
checklist **plus** `npx vitest run --exclude "e2e/**"` green. E2E runs when
routing, layout shells, or theming changed.

## Why this shape

Co-location keeps a test next to the thing it protects, so a moved or deleted
source file takes its test with it instead of orphaning it in a parallel
tree. The one-way `src/testing/` folder gives shared setup a single home
without letting it leak into the bundle. The layer rule keeps the suite fast
— 800 layer-1/2 tests currently run in under 4 seconds, and that speed is
itself a feature worth defending: a slow suite stops being run.
