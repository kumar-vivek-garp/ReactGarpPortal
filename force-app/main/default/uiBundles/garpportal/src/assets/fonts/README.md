# Fonts

Side-nav icons use **lucide-react** (bundled SVG). No Material Symbols icon font.

Self-hosted under `src/assets/fonts/` (Vite-hashed → long cache):

- **Nunito Sans** — Regular / Bold / ExtraBold as **woff2** (from HubSpot TTFs; OFL)
- **Klinic Slab** — Book / Bold as **woff2** (from HubSpot portal faces)

Critical body + heading faces are `<link rel="preload">`’d from `__root` so the
browser discovers them without waiting on the CSS `@font-face` chain.

Brand images live in `src/assets/brand/` (and `public/brand/` for the pre-JS boot splash).
