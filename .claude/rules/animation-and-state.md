---
paths:
  - "**/uiBundles/**/*.ts"
  - "**/uiBundles/**/*.tsx"
---

# Animation and global state

## Animation — `@react-spring/web` only

- **Required** for interactive motion (open/close panels, overlays, chevrons, sheet transitions, enter/leave).
- Prefer **physics configs** (`mass`, `tension`, `friction`) over duration/easing CSS animations.
- Use `useSpring`, `useTransition`, and `animated.*` from `@react-spring/web`.
- **Do not** add Framer Motion, GSAP, or other animation libraries.
- **Gestures:** `@use-gesture/react` (pmndrs' own companion to react-spring) is the sanctioned pointer/drag layer — it produces gesture *state*, never animation, and every value it yields is still driven through a spring. It does not loosen the rule above: react-spring remains the only animation library.
- **Do not** use CSS `@keyframes` / `transition-*` as the primary mechanism for UI chrome motion (mega-menus, mobile nav, overlays). Tailwind transitions for trivial hover color/opacity on static controls are fine.
- Before writing spring code, fetch current docs via Context7 for `@react-spring/web`.

```tsx
// ✅ Physics-based spring
const styles = useSpring({
  opacity: open ? 1 : 0,
  config: { mass: 0.9, tension: 320, friction: 26 },
})

// ❌ Duration-driven UI chrome
className="transition-all duration-300 ease-in-out"
```

## Global store — Zustand only

- Cross-component / shell client state lives in **Zustand** stores under `src/store/`.
- Use `create` from `zustand`. Prefer **selector subscriptions** (`useStore((s) => s.field)`) over selecting the whole store.
- **Do not** add Redux, MobX, Jotai, Recoil, or Context-as-global-store for app-wide UI state.
- Local UI state that does not cross the tree stays in `useState` / component state.
- Before writing store code, fetch current docs via Context7 for `zustand`.

```ts
// src/store/example-store.ts
import { create } from "zustand"

type ExampleState = {
  open: boolean
  setOpen: (open: boolean) => void
}

export const useExampleStore = create<ExampleState>((set) => ({
  open: false,
  setOpen: (open) => set({ open }),
}))
```
