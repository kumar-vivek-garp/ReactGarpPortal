# Adding UI components — check before installing, install before hand-writing

**STRICT — follow this order every time a component is needed. Never skip straight to hand-writing one.**

## 1. Check if it already exists locally

Look in `src/components/atoms/`, `src/components/molecules/`, `src/components/organisms/`, and `src/components/forms/` first. If a component that does the job already exists, reuse it — do not reinstall it via the shadcn CLI and do not hand-author a duplicate.

## 2. Check whether shadcn/ui provides it

If it's not already present locally, check whether shadcn/ui has this component before doing anything else. Use the `context7` MCP tools (per `context7-required.md`) to query current shadcn/ui documentation/registry and confirm:
- the component actually exists in shadcn's registry,
- its exact registry name (for the install command),
- its current API/props, since shadcn's components do change across versions.

Do not rely on memory/training data for whether shadcn has a given component — verify via Context7 every time.

## 3. If shadcn provides it: install it, don't hand-write it

Run `npx shadcn@latest add <component>` from the UI Bundle directory (per `commands.md`). Never hand-author a component that shadcn already ships — even a "simple" one. It lands in `src/components/atoms/` automatically via `components.json`'s `aliases.ui`.

## 4. If shadcn does NOT provide it: hand-author it, but classify it first

Only write a component by hand when Context7 confirms shadcn's registry has no equivalent. Before writing any code, decide which atomic-design tier it belongs to (per `project-structure.md` / `ui-conventions.md`):

- **Atom** (`src/components/atoms/`) — a single, indivisible primitive with no composition of other custom components. Rare to hand-author here, since shadcn covers most primitives — only for a genuinely project-specific low-level element shadcn has no equivalent for.
- **Molecule** (`src/components/molecules/`) — a small, hand-composed combination of existing atoms (e.g. a labeled form field, a stat tile).
- **Organism** (`src/components/organisms/`) — a larger hand-composed section built from atoms/molecules (e.g. a page header, a results panel).
- **Form** (`src/components/forms/<form-name>/`) — a major form a person fills in and submits. Its own folder, never `organisms/`. See `project-structure.md`.

Build hand-authored molecules, organisms and forms out of existing atoms — don't reinvent a primitive shadcn/Radix already provides just because it's being used inside a bigger composition.

## Why

Reinstalling or hand-writing something that already exists creates drift — two different implementations of the same control, styled slightly differently, both technically "the theme" but not actually consistent. Checking local-first, then shadcn's registry, then hand-authoring as the last resort keeps every component either (a) shadcn's own maintained implementation or (b) a deliberate, classified addition — never an accidental reinvention.
