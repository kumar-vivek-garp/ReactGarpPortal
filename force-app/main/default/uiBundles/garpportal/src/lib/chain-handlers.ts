type Props = Record<string, unknown>

function isHandler(value: unknown): value is (...args: unknown[]) => unknown {
	return typeof value === "function"
}

/**
 * Merges two prop objects, **chaining** any key both of them supply as a
 * function instead of letting the second win.
 *
 * A plain spread is a trap wherever two behaviours want the same DOM event.
 * `@use-gesture` picks its event family at import time — `onPointerDown` in a
 * browser, `onTouchStart` where pointer events are missing — so the exact key
 * that collides with a press-feedback binding is not knowable from the source,
 * and a spread drops one of them silently and only in production.
 *
 * `a` runs first, then `b`.
 */
export function chainHandlers<A extends Props, B extends Props>(
	a: A,
	b: B,
): A & B {
	const merged: Props = { ...a }

	for (const key of Object.keys(b)) {
		const ours = a[key]
		const theirs = b[key]
		merged[key] =
			isHandler(ours) && isHandler(theirs)
				? (...args: unknown[]) => {
						ours(...args)
						theirs(...args)
					}
				: theirs
	}

	return merged as A & B
}
