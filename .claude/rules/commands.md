# Commands and build discipline

## Two package.json contexts

### 1. Project root

Used for SFDX metadata tooling. Scripts here target LWC/Aura, not the React app.

| Command | Purpose |
|---------|---------|
| `npm run test` | LWC Jest (passWithNoTests) |
| `npm run prettier` | Format metadata files |
| `npm run prettier:verify` | Check Prettier |
| `npm run ui:test` | UI Bundle Vitest suite, one-shot (delegates via `--prefix`) |
| `npm run ui:test:watch` | Same suite in watch mode |
| `npm run ui:test:coverage` | Suite + coverage report (ratchets enforced) |
| `npm run ui:e2e` | Build `dist/` for static serving + Playwright smoke |
| `npm run ui:e2e:ui` | Same, in Playwright's live UI mode |
| `npm run ui:e2e:headed` | Same, watching real Chrome windows |
| `npm run ui:e2e:report` | Open the last Playwright HTML report |

The `ui:*` rows only *delegate* into the UI Bundle package (npm chdirs there
via `--prefix`) — they don't loosen the rule below. `ui:e2e*` always rebuild
via `build:e2e` first, because a plain `build` leaves a `dist/` the static
e2e server can't serve.

**One-time org setup:** `node scripts/org-setup.mjs --target-org <alias>` runs login, deploy, permset assignment, data import, GraphQL schema/codegen, UI Bundle build, and optionally the dev server. Use `--help` for all flags.

### 2. UI Bundle directory (primary workspace)

**ALL dev, build, lint, and test commands MUST be run from inside the UI Bundle directory (`<sfdx-source>/uiBundles/<appName>/`). Never run them from the project root.**

Resolve the correct path from `sfdx-project.json` before running any command. Do not hardcode the path. See `project-structure.md`.

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start Vite dev server |
| `npm run build` | TypeScript check + Vite production build |
| `npm run lint` | ESLint for the React app |
| `npm run test` | Vitest unit tests |
| `npm run preview` | Preview production build |
| `npm run graphql:codegen` | Generate GraphQL types from schema |
| `npm run graphql:schema` | Fetch GraphQL schema from org |

Before running any command, read the UI Bundle's `package.json` to confirm available scripts — do not assume script names.

If dependencies have not been installed yet, run `npm install` in the UI Bundle directory first. Alternatively, run `npm run sf-project-setup` from the project root — it resolves the UI Bundle directory automatically and runs install, build, and dev in sequence.

## Mandatory checklist — after every task, without exception

1. Run `npm run build` from the UI Bundle directory — must pass with zero errors.
2. Run `npm run lint` from the UI Bundle directory — must pass with zero errors.
3. Run `npm run dev` to start the dev server so the user can verify the result.

Do not consider a task complete until all three steps have been run successfully.

**After any JavaScript or TypeScript change, run `npm run build` to validate the change.** If the build fails, read the error output, identify the cause, fix it, and run `npm run build` again. Do not move on until the build passes.
