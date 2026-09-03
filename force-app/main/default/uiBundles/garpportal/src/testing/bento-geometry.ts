import { afterAll, beforeAll } from "vitest"

/**
 * jsdom lays nothing out — every offset reads 0 and `offsetParent` is null —
 * so the bento engine's measuring pass sees an empty grid. This stamps a
 * scripted masonry geometry onto `HTMLElement.prototype`: every element is
 * `cardWidth` × `cardHeight`, stacked `gap` apart under its DIV siblings,
 * exactly the shape `use-bento-layout`'s `readAllRects` reads back.
 *
 * Mutate the returned object mid-test to model a resize; flip `enabled` off to
 * model a grid that has never been measured (a hidden tab). Registers its own
 * beforeAll/afterAll — call once at the top level of a test file.
 *
 * Same scripting idea as `bento-grid.drag.test.tsx`; promoted here once a
 * second file needed it (testing.md's promotion rule).
 */
export type BentoGeometryControl = {
	cardWidth: number
	cardHeight: number
	gap: number
	enabled: boolean
}

export function stubBentoGeometry(
	initial?: Partial<Omit<BentoGeometryControl, "enabled">>,
): BentoGeometryControl {
	const control: BentoGeometryControl = {
		cardWidth: 600,
		cardHeight: 300,
		gap: 24,
		enabled: true,
		...initial,
	}

	const props: Array<[string, (el: HTMLElement) => unknown]> = [
		["offsetParent", (el) => (control.enabled ? el.parentElement : null)],
		["offsetLeft", () => 0],
		["offsetWidth", () => control.cardWidth],
		["offsetHeight", () => control.cardHeight],
		[
			"offsetTop",
			(el) => {
				const siblings = Array.from(el.parentElement?.children ?? []).filter(
					(node) => node.tagName === "DIV",
				)
				const index = siblings.indexOf(el)
				return index < 0 ? 0 : index * (control.cardHeight + control.gap)
			},
		],
	]

	const saved = new Map<string, PropertyDescriptor | undefined>()

	beforeAll(() => {
		for (const [name, get] of props) {
			saved.set(
				name,
				Object.getOwnPropertyDescriptor(HTMLElement.prototype, name),
			)
			Object.defineProperty(HTMLElement.prototype, name, {
				configurable: true,
				get(this: HTMLElement) {
					return get(this)
				},
			})
		}
	})

	afterAll(() => {
		for (const [name, descriptor] of saved) {
			if (descriptor) {
				Object.defineProperty(HTMLElement.prototype, name, descriptor)
			} else {
				delete (HTMLElement.prototype as unknown as Record<string, unknown>)[
					name
				]
			}
		}
		saved.clear()
	})

	return control
}
