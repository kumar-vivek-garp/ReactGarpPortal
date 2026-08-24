import type { BentoRect } from "@/lib/bento-layout"

/** Card ids per column, outer index = column, inner order = top to bottom. */
export type BentoColumns = string[][]

export type BentoSlotRef = { column: number; index: number }

function isColumns(value: unknown): value is BentoColumns {
	return (
		Array.isArray(value) &&
		value.every(
			(column) =>
				Array.isArray(column) && column.every((id) => typeof id === "string"),
		)
	)
}

/** Column-major: every column top to bottom, in column order. */
export function flattenColumns(columns: BentoColumns): string[] {
	return columns.flat()
}

/**
 * Deal ids across columns round-robin.
 *
 * Deliberately height-independent. A balanced shortest-column packing looks
 * marginally tidier, but it cannot run until the cards have been measured — so
 * the grid would visibly re-shuffle when fonts land or data arrives. A
 * deterministic deal is stable from the first paint, and the member can drag
 * anything they dislike.
 */
export function packRoundRobin(
	ids: readonly string[],
	count: number,
): BentoColumns {
	const columns: BentoColumns = Array.from(
		{ length: Math.max(1, count) },
		() => [],
	)
	ids.forEach((id, index) => {
		columns[index % columns.length].push(id)
	})
	return columns
}

export function locate(columns: BentoColumns, id: string): BentoSlotRef | null {
	for (let column = 0; column < columns.length; column += 1) {
		const index = columns[column].indexOf(id)
		if (index !== -1) return { column, index }
	}
	return null
}

/** Moves `id` to `target`, closing the gap it leaves behind. */
export function moveCard(
	columns: BentoColumns,
	id: string,
	target: BentoSlotRef,
): BentoColumns {
	const next = columns.map((column) => column.filter((card) => card !== id))
	const column = Math.max(0, Math.min(next.length - 1, target.column))
	const index = Math.max(0, Math.min(next[column].length, target.index))
	next[column].splice(index, 0, id)
	return next
}

/**
 * Merge a persisted arrangement with the code-defined cards.
 *
 * - unknown ids are dropped (a card was deleted or renamed)
 * - duplicates collapse to their first occurrence
 * - a newly shipped card is inserted after its default predecessor if that
 *   predecessor survived, so it lands near where the design intends rather
 *   than at the bottom of whichever column happens to be shortest
 * - a stored arrangement for a different column count is re-dealt
 *
 * Total by construction: anything unparseable falls back to the default deal.
 */
export function reconcileColumns(
	stored: unknown,
	defaults: readonly string[],
	count: number,
): BentoColumns {
	const width = Math.max(1, count)
	if (!isColumns(stored)) return packRoundRobin(defaults, width)

	const known = new Set(defaults)
	const seen = new Set<string>()
	const cleaned: BentoColumns = stored.map((column) =>
		column.filter((id) => {
			if (!known.has(id) || seen.has(id)) return false
			seen.add(id)
			return true
		}),
	)

	// A layout saved at a different width cannot be honoured slot for slot.
	if (cleaned.length !== width) {
		const flat = flattenColumns(cleaned)
		const missing = defaults.filter((id) => !seen.has(id))
		return packRoundRobin([...flat, ...missing], width)
	}

	for (const id of defaults) {
		if (seen.has(id)) continue
		seen.add(id)
		const previous = defaults[defaults.indexOf(id) - 1]
		const anchor = previous ? locate(cleaned, previous) : null
		if (anchor) cleaned[anchor.column].splice(anchor.index + 1, 0, id)
		else {
			const shortest = cleaned.reduce(
				(best, column, index) =>
					column.length < cleaned[best].length ? index : best,
				0,
			)
			cleaned[shortest].push(id)
		}
	}

	return cleaned
}

export type BentoColumnBounds = { left: number; width: number }

export type ResolveMasonryTargetInput = {
	columns: BentoColumns
	draggingId: string
	/** Frozen at pickup — see the note in `use-bento-layout`. */
	rects: ReadonlyMap<string, BentoRect>
	columnBounds: readonly BentoColumnBounds[]
	/** The dragged card's projected centre, in container space. */
	centroid: { x: number; y: number }
	current: BentoSlotRef
	hysteresis: number
}

/**
 * Which column, and how far down it, the dragged card would land.
 *
 * Masonry makes this a pair of one-dimensional questions — pick a column by x,
 * then an insertion point by y — instead of hit-testing a two-dimensional grid
 * whose auto-placement reflows unpredictably whenever a wide card moves. That
 * is most of why the drag reads as predictable here.
 */
export function resolveMasonryTarget({
	columns,
	draggingId,
	rects,
	columnBounds,
	centroid,
	current,
	hysteresis,
}: ResolveMasonryTargetInput): BentoSlotRef {
	if (columnBounds.length === 0) return current

	// Column: containment, else nearest centre, so a drag past the outer edge
	// still resolves to the column the member is obviously aiming at.
	let column = -1
	for (let index = 0; index < columnBounds.length; index += 1) {
		const bound = columnBounds[index]
		if (centroid.x >= bound.left && centroid.x <= bound.left + bound.width) {
			column = index
			break
		}
	}
	if (column === -1) {
		let nearest = 0
		let best = Number.POSITIVE_INFINITY
		columnBounds.forEach((bound, index) => {
			const distance = Math.abs(bound.left + bound.width / 2 - centroid.x)
			if (distance < best) {
				best = distance
				nearest = index
			}
		})
		column = nearest
	}

	const others = (columns[column] ?? []).filter((id) => id !== draggingId)

	// Insert above the first card whose middle the centroid has not yet passed.
	// The dead band stops a centroid resting on a boundary from strobing.
	let index = others.length
	for (let position = 0; position < others.length; position += 1) {
		const rect = rects.get(others[position])
		if (!rect) continue
		const middle = rect.top + rect.height / 2
		const movingUp = column === current.column && position < current.index
		const threshold = movingUp ? middle - hysteresis : middle + hysteresis
		if (centroid.y < threshold) {
			index = position
			break
		}
	}

	return { column, index }
}
