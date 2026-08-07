# Theme tokens only — no hardcoded colors, ever

**STRICT — no exceptions, applies to every component tier (atoms/molecules/organisms/pages) and to all future work, not just the current task.**

All color, radius, and font values in the UI Bundle come from the theme tokens defined in `src/styles/global.css` (`:root`, `.dark`, `@theme inline`). Never introduce a color any other way.

## Forbidden

- Raw color literals anywhere in component code: hex (`#00A2DD`), `rgb()`, `hsl()`, `oklch()` written inline.
- Tailwind arbitrary-value color syntax: `bg-[#00A2DD]`, `text-[oklch(0.67_0.14_233)]`, etc.
- Tailwind's *stock* palette utilities that bypass our tokens: `bg-blue-500`, `text-red-600`, `border-gray-300`, `bg-white`, `text-black`, and so on for any built-in Tailwind color name.
- Inline `style={{ color: ... }}` / `style={{ backgroundColor: ... }}` for any brand or semantic color.
- Hardcoded `border-radius` values or arbitrary `rounded-[Npx]` — use the `--radius`-derived utilities (`rounded-sm/md/lg/xl/full`).

## Required instead

Use the Tailwind utility classes that resolve through our tokens:

- **Semantic slots** (preferred for anything that's a UI role, not a brand hue): `bg-background`, `text-foreground`, `bg-card`, `bg-primary`/`text-primary-foreground`, `bg-secondary`/`text-secondary-foreground`, `bg-muted`/`text-muted-foreground`, `bg-accent`/`text-accent-foreground`, `bg-destructive`/`text-destructive-foreground`, `border-border`, `bg-input`, `ring-ring`, `bg-sidebar*`, `bg-toolbar`/`text-toolbar-foreground`. These slot names are stable across palette changes — use them by name, they're safe to hardcode in this rule.
- **Named brand tokens** (for direct brand-hue usage — badges, category tags, charts): **the current brand palette is a living value, not something this rule should enumerate.** Before using one, open `src/styles/global.css` and read the `@theme inline` block plus the `:root` block — every brand color is declared there as `--color-<name>` / `--color-<name>-foreground`, and that pairing is mandatory: never assume `white`/`black` text works on a brand swatch without checking its declared `-foreground` partner (several brand colors fail WCAG contrast with the "obvious" text choice — check the one-line provenance comment next to each token in `global.css`, which tags it `live-verified`, `inferred`, or `AA-safe deviation from live`). If `global.css` and this rule ever disagree about what brand tokens exist, **`global.css` is the source of truth** — update this rule's wording, not the other way around. Do not re-add a hardcoded token list here even for illustration; it will go stale again the next time the palette changes (this has already happened once — an entire cyan-based palette was built, shipped into this rule, and turned out to be themed after the wrong, retired app).
- **Fonts**: `font-sans` and `--font-heading` are applied at the base layer already (`body` and `h1`–`h6` respectively) — check `global.css`'s `@layer base` for the current font-family assignment rather than assuming which family is which, and don't hardcode a font name in components.

## If a design needs a color that doesn't exist yet

Do not hardcode it "just this once." Add a new token to `global.css` first — following the existing pattern (raw value in `:root`/`.dark`, mirrored into `@theme inline`, tagged with a provenance comment) — then consume it via its generated utility class. This is the entire point of the token system: a designer (or future you) can change one value in one file and have it propagate everywhere, with zero component edits.

## Before trusting any color/font as "the current live theme"

Names like "legacy," "unreleased," or "the old app" are claims about which Salesforce app is actually live in production — not something to infer from Salesforce metadata (Network/CustomTab config) alone, since sandbox config can silently diverge from what's actually deployed and wired up in production. If a task depends on knowing what's *currently live*, verify by directly inspecting the running production app (e.g. via browser devtools / computed styles), not by reading org metadata and assuming it matches. This exact mistake already happened once in this project — an entire theme was built from a retired app because sandbox metadata pointed at it.

## Why

The whole theme layer (`global.css`) was deliberately built as a single source of truth so that future color/size/radius changes are a one-file edit, not a hunt-and-replace across every component. Hardcoding anything — even "temporarily" — defeats that and reintroduces the exact problem this system was built to solve.
