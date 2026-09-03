import { Globals } from "@react-spring/web"
import { afterAll, beforeAll } from "vitest"

/**
 * Per-file opt-in: react-spring springs jump straight to their end state, so
 * `onRest` fires without real time passing — for components whose phases hang
 * off spring completion (e.g. the alert bar). Call at the top level of a test
 * file; restores on teardown. Deliberately NOT global: the bento-grid drag
 * tests exercise real springs.
 *
 * WARNING — do NOT use in a file that renders any component whose spring gets
 * fresh `to`/interpolation/`onRest` props every render. Known offenders:
 * `useSubpageTransition` (the registration panels) and `useSidebarCollapse`
 * (`AppSidebar`). With `skipAnimation` each such update settles synchronously
 * and re-notifies `animated.*`, producing an infinite re-render loop that
 * spins the worker until it dies ("Worker exited unexpectedly", tests
 * reporting 0ms). Verified empirically in Phases 4–5.
 */
export function skipSpringAnimations() {
	beforeAll(() => {
		Globals.assign({ skipAnimation: true })
	})
	afterAll(() => {
		Globals.assign({ skipAnimation: false })
	})
}
