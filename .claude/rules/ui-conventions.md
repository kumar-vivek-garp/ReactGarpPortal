---
paths:
  - "**/uiBundles/**/*.ts"
  - "**/uiBundles/**/*.tsx"
---

# UI, component, and routing conventions

## UI

- **Component library — atomic design:** shadcn/ui primitives generate into `src/components/atoms/` (via `components.json`'s `aliases.ui`), and are used over raw HTML equivalents. `src/components/molecules/` and `src/components/organisms/` hold hand-authored compositions of atoms — shadcn does not generate these, they must be built manually. `src/components/forms/` is the fourth tier: every major form gets its own folder there rather than living in `organisms/` (see `project-structure.md`). **Before importing any component, verify both the file exists AND the named export exists within that file.** Never assume a component or export is available — read the file to confirm the exact exports before importing.
- To add a new atom, run `npx shadcn add <component>` from the UI Bundle directory — it will land in `src/components/atoms/` automatically.
- **Styling:** Tailwind CSS only. No inline `style={{}}`. Use `cn()` from `@/lib/utils` for conditional classes.
- **Icons:** Lucide React.
- **Path alias:** `@/*` maps to `src/*`. Use it for all imports.
- **TypeScript:** No `any`. Use proper types, generics, or `unknown`.
- **Components:** Accept `className?: string` prop. Extract shared state to custom hooks in `src/hooks/`.
- **React apps must not** import Salesforce platform modules (`lightning/*`, `@wire`, LWC APIs).

## Routing

- **TanStack Router, file-based.** The `@tanstack/router-plugin` Vite plugin (configured in `vite.config.ts` and `vitest.config.ts`) scans `src/pages` (`routesDirectory`) and generates `src/routeTree.gen.ts` — never hand-edit the generated file.
- **One folder per page:** `src/pages/<name>/index.tsx` defines the `/<name>` route. Do not use flat sibling files (`pages/dashboard.tsx`) for new pages — keep the folder-per-page convention so page-local files (components, hooks, tests) can live alongside `index.tsx`.
- `src/pages/__root.tsx` is the root route (`createRootRoute`) — renders `<Outlet />` and `<TanStackRouterDevtools />`.
- `src/pages/index.tsx` is the `/` route and only redirects to `/home` via `beforeLoad`/`redirect` — it must not render a page itself.
- Navigation uses the router's `<Link>`/`useNavigate` with absolute paths (`/dashboard`). Non-router imports use dot-relative paths (`./utils`).
- `basepath` (not `basename`) is read from `SFDC_ENV.basePath` in `app.tsx` at router creation — required because Salesforce mounts the bundle at a dynamic, org-specific path. Preserve this exact pattern in any router changes.

## Layout groups (`_appLayout`, `_authLayout`)

Two pathless layout groups exist under `src/pages/`, each a directory named with a leading underscore:

```
pages/
├── _appLayout/
│   ├── route.tsx        # pathless layout for `/_appLayout` — no URL segment added
│   └── home/index.tsx   # -> /home
└── _authLayout/
    ├── route.tsx         # pathless layout for `/_authLayout` — no URL segment added
    └── login/index.tsx   # -> /login
```

- The underscore prefix makes the layout **pathless** — it wraps its children in a component but contributes no URL segment (`_appLayout/home/index.tsx` resolves to `/home`, not `/_appLayout/home`).
- Both `route.tsx` files currently render only `<Outlet />` — **no nav, no chrome**. The visual difference between the app and auth layouts (and any shared nav/shell) is intentionally deferred; do not add navigation to either layout until that's decided.
- **New authenticated/app pages** go under `_appLayout/<name>/index.tsx`. **New unauthenticated/auth pages** (signup, forgot-password, etc.) go under `_authLayout/<name>/index.tsx`. Don't add a page directly under `pages/` outside one of these two groups unless it genuinely belongs to neither layout.
- When the layouts are fleshed out (e.g. auth-guard redirect in `_authLayout`'s `beforeLoad`, shared nav in `_appLayout`), follow atomic design: shared header/nav/footer components belong in `src/components/organisms/`, composed into the layout's `route.tsx`.
