import {
	useCallback,
	useEffect,
	useLayoutEffect,
	useMemo,
	useRef,
	useState,
	type FocusEvent as ReactFocusEvent,
	type KeyboardEvent as ReactKeyboardEvent,
	type ReactNode,
} from "react"
import { useSpring, useSprings } from "@react-spring/web"
import type { SpringValues } from "@react-spring/web"
import { useDrag } from "@use-gesture/react"

import {
	BENTO_AUTOSCROLL_MAX_PX_PER_SEC,
	BENTO_AUTOSCROLL_ZONE_PX,
	BENTO_COLUMN_QUERY,
	BENTO_HYSTERESIS_PX,
	type BentoScope,
} from "@/config/bento"
import {
	BENTO_DROP,
	BENTO_GHOST,
	BENTO_LIFT,
	BENTO_LIFT_SCALE,
	BENTO_NEIGHBOUR_DELAY_MAX_MS,
	BENTO_NEIGHBOUR_DELAY_PER_PX,
	BENTO_REVEAL,
	BENTO_REVEAL_STAGGER_MS,
	BENTO_REVEAL_Y,
	BENTO_SETTLE,
} from "@/lib/bento-spring"
import type { BentoRect } from "@/lib/bento-layout"
import {
	flattenColumns,
	locate,
	moveCard,
	reconcileColumns,
	resolveMasonryTarget,
	type BentoColumnBounds,
	type BentoColumns,
	type BentoSlotRef,
} from "@/lib/bento-masonry"
import { scrollParent } from "@/lib/scroll-parent"
import { useBentoLayoutStore } from "@/store/bento-layout-store"

/**
 * One card the grid can arrange. Ids are persisted, so renaming one resets that
 * card's slot for everyone — treat them as a stored contract, and never put a
 * `|` in one (the id list is joined on it to key effects).
 */
export type BentoItemMeta = {
	id: string
	/** Announced by the drag handle and the live region. */
	label: string
	/**
	 * False pins the card: it grows no handle and cannot be picked up. It can
	 * still be displaced by another card landing above it.
	 */
	sortable?: boolean
}

/**
 * The pointer handlers `useDrag` produces. `@use-gesture` declares this type
 * but does not re-export it from its entry point, so derive it from the hook.
 */
type GestureDOMAttributes = ReturnType<ReturnType<typeof useDrag>>

export type BentoHandleProps = GestureDOMAttributes & {
	ref: (node: HTMLElement | null) => void
	type: "button"
	onKeyDown: (event: ReactKeyboardEvent<HTMLElement>) => void
	onBlur: (event: ReactFocusEvent<HTMLElement>) => void
	"aria-label": string
	"aria-roledescription": string
	"aria-describedby": string
	"data-lifted": boolean
}

/** Every animated key a card carries. */
export type BentoSpringValues = {
	x: number
	y: number
	scale: number
	/** 0–1, interpolated into a box-shadow by the card. */
	shadow: number
	opacity: number
}

export type BentoCardSpring = SpringValues<BentoSpringValues>

/** What each card is handed so it can place its own grip. */
export type BentoSlotControls = {
	handleProps: BentoHandleProps | null
}

export type BentoRenderItem = BentoItemMeta & {
	render: (controls: BentoSlotControls) => ReactNode
}

type UseBentoLayoutOptions = {
	scope: BentoScope
	items: readonly BentoItemMeta[]
	reveal?: boolean
}

/**
 * A gesture in flight.
 *
 * One object rather than a dozen refs, so a drag cannot end up half torn down.
 * `pointer` pins the card to the finger; `keyboard` lets it glide with the FLIP
 * like every other card, because there is no finger to track.
 */
type DragState =
	| { kind: "idle" }
	| {
			kind: "pointer" | "keyboard"
			id: string
			/** Arrangement at pickup — every preview is derived from this. */
			base: BentoColumns
			/** Slot the preview currently places the card in. */
			target: BentoSlotRef
			/**
			 * `id`'s measured rect at pickup. Only a pointer drag needs one — a
			 * keyboard lift pins nothing and glides with the FLIP.
			 */
			firstRect: BentoRect | null
			/**
			 * The whole grid's geometry at pickup, frozen for the gesture.
			 *
			 * Hit-testing must not read the *live* rects: a reorder changes the
			 * layout, and the changed layout changes the next hit-test. That feedback
			 * loop is bistable — the arrangement visibly flips back and forth between
			 * two states on consecutive moves, which no amount of hysteresis damps.
			 */
			baseRects: Map<string, BentoRect>
			movement: [number, number]
			/** Pixels the container has auto-scrolled since pickup. */
			autoScroll: number
			/** Latest pointer viewport Y, so the auto-scroll frame needs no event. */
			pointerY: number
			/** Previous frame timestamp, so scroll speed is a rate not a nudge. */
			lastFrameAt: number
	  }

/**
 * Handed from release to the next layout effect, which is the first moment the
 * card's final slot has actually been measured.
 */
type ReleaseState = {
	id: string
	/** Pointer drags were pinned, so they need a positional `from`. */
	pinned: boolean
	visualLeft: number
	visualTop: number
}

const ACTIVATION_KEYS = new Set([" ", "Enter", "Spacebar"])

/** Stable id for the sr-only instructions every handle points at. */
export const BENTO_INSTRUCTIONS_ID = "bento-reorder-instructions"

function clamp(value: number, min: number, max: number) {
	return Math.max(min, Math.min(max, value))
}

/** `null` wherever `matchMedia` is unavailable — a test environment, or SSR. */
function columnQuery(): MediaQueryList | null {
	if (
		typeof window === "undefined" ||
		typeof window.matchMedia !== "function"
	) {
		return null
	}
	return window.matchMedia(BENTO_COLUMN_QUERY)
}

/** Subscribes to the column breakpoint. No-ops where `matchMedia` is absent. */
function useColumnCount(): number {
	const [count, setCount] = useState(() => (columnQuery()?.matches ? 2 : 1))

	useEffect(() => {
		const query = columnQuery()
		if (!query) return
		const sync = () => setCount(query.matches ? 2 : 1)
		sync()
		query.addEventListener("change", sync)
		return () => query.removeEventListener("change", sync)
	}, [])

	return count
}

/**
 * The engine behind `BentoGrid`: reconciles the stored arrangement, measures
 * the grid, and drives every spring.
 *
 * **Masonry, not a row grid.** Cards stack in independent columns, so a short
 * card simply lets the next one start higher — there are no rows, and therefore
 * no ragged gaps to tune away. Measured on the real page, a row grid wasted
 * 395px of whitespace and equalising the columns made it worse; masonry wastes
 * none, by construction. It also makes the drag two one-dimensional questions
 * (which column, how far down) instead of hit-testing a grid whose auto
 * placement reflows unpredictably whenever a wide card moves.
 *
 * **Springs are keyed by card identity, never by slot.** `useSprings` keeps one
 * controller per index for the component's lifetime, so the index has to mean
 * "which card". Indexing by position hands a neighbour the dragged card's lift
 * the moment a preview re-renders, and nothing ever cleans it up.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in
 * `pages/__root.tsx`, which makes every `api.start` resolve immediately.
 */
export function useBentoLayout({
	scope,
	items,
	reveal = true,
}: UseBentoLayoutOptions) {
	const itemsKey = items.map((item) => item.id).join("|")

	const stored = useBentoLayoutStore((state) => state.layouts[scope]?.columns)
	const setStoredColumns = useBentoLayoutStore((state) => state.setColumns)

	const columnCount = useColumnCount()

	/**
	 * The code-defined ids, in code order. This never permutes — arranging
	 * changes `columns`, not this — which is what makes it safe as a spring index.
	 */
	const stableIds = useMemo(() => itemsKey.split("|"), [itemsKey])
	const springIndex = useMemo(
		() => new Map(stableIds.map((id, index) => [id, index])),
		[stableIds],
	)

	const storedForCount = stored?.[String(columnCount)]
	const committedColumns = useMemo(
		() => reconcileColumns(storedForCount, stableIds, columnCount),
		[storedForCount, stableIds, columnCount],
	)

	const [previewColumns, setPreviewColumns] = useState<BentoColumns | null>(
		null,
	)
	const [liftedId, setLiftedId] = useState<string | null>(null)
	const [settlingId, setSettlingId] = useState<string | null>(null)
	const [announcement, setAnnouncement] = useState("")

	const columns = previewColumns ?? committedColumns
	const metaById = new Map(items.map((item) => [item.id, item]))

	const containerRef = useRef<HTMLDivElement | null>(null)
	const nodeRefs = useRef(new Map<string, HTMLElement>())
	const handleRefs = useRef(new Map<string, HTMLElement>())
	const columnRefs = useRef(new Map<number, HTMLElement>())
	const rectsRef = useRef(new Map<string, BentoRect>())
	const boundsRef = useRef<BentoColumnBounds[]>([])
	const dragRef = useRef<DragState>({ kind: "idle" })
	const releaseRef = useRef<ReleaseState | null>(null)
	const scrollerRef = useRef<HTMLElement | null>(null)
	const autoScrollRafRef = useRef<number | null>(null)
	const reflowRafRef = useRef<number | null>(null)
	const hasRevealedRef = useRef(false)
	const measuredKeyRef = useRef("")

	// Render-scope values the event handlers need. Written in a layout effect,
	// never during render — the React Compiler lint forbids the latter, and it is
	// unsound under concurrent rendering anyway.
	const columnsRef = useRef(columns)
	const committedRef = useRef(committedColumns)
	const metaRef = useRef(metaById)
	const springIndexRef = useRef(springIndex)
	const columnCountRef = useRef(columnCount)

	useLayoutEffect(() => {
		columnsRef.current = columns
		committedRef.current = committedColumns
		metaRef.current = metaById
		springIndexRef.current = springIndex
		columnCountRef.current = columnCount
	})

	/**
	 * Keyed on `itemsKey`, not on length: react-spring re-declares every surviving
	 * controller with these initial props when the deps change, so a registry
	 * change resets any lift a controller was carrying before it could be
	 * reinterpreted as another card's state.
	 */
	const [springs, api] = useSprings(
		stableIds.length,
		() => ({
			x: 0,
			y: 0,
			scale: 1,
			shadow: 0,
			opacity: 1,
			config: BENTO_SETTLE,
		}),
		[itemsKey],
	)

	const [ghostStyle, ghostApi] = useSpring(() => ({
		x: 0,
		y: 0,
		width: 0,
		height: 0,
		opacity: 0,
		config: BENTO_GHOST,
	}))

	/**
	 * A card's own spring. Exposed instead of the raw array on purpose: an array
	 * invites `springs[slot]`, and a slot is not a card.
	 */
	const springFor = useCallback(
		(id: string): BentoCardSpring | undefined => {
			const index = springIndex.get(id)
			return index === undefined ? undefined : springs[index]
		},
		[springIndex, springs],
	)

	const registerItem = useCallback((id: string, node: HTMLElement | null) => {
		if (node) nodeRefs.current.set(id, node)
		else nodeRefs.current.delete(id)
	}, [])

	const registerHandle = useCallback((id: string, node: HTMLElement | null) => {
		if (node) handleRefs.current.set(id, node)
		else handleRefs.current.delete(id)
	}, [])

	const registerColumn = useCallback(
		(index: number, node: HTMLElement | null) => {
			if (node) columnRefs.current.set(index, node)
			else columnRefs.current.delete(index)
		},
		[],
	)

	/**
	 * One read pass over the whole grid: four layout properties per node, no
	 * interleaved writes, so the browser recalculates layout at most once.
	 *
	 * Offsets rather than `getBoundingClientRect()` — they report *layout*
	 * position, so they are immune both to the transform every card carries and
	 * to the scroll container moving between two reads. The column stacks are
	 * statically positioned, so a card's offset parent is still the container.
	 */
	const readAllRects = useCallback(() => {
		const container = containerRef.current
		const next = new Map<string, BentoRect>()
		if (!container) return next

		for (const [id, node] of nodeRefs.current) {
			if (!node.offsetParent) continue
			next.set(id, {
				left: node.offsetLeft,
				top: node.offsetTop,
				width: node.offsetWidth,
				height: node.offsetHeight,
			})
		}
		return next
	}, [])

	const readColumnBounds = useCallback(() => {
		const bounds: BentoColumnBounds[] = []
		for (let index = 0; index < columnRefs.current.size; index += 1) {
			const node = columnRefs.current.get(index)
			if (!node) continue
			bounds[index] = { left: node.offsetLeft, width: node.offsetWidth }
		}
		return bounds.filter(Boolean)
	}, [])

	const moveGhostTo = useCallback(
		(rect: BentoRect | undefined) => {
			if (!rect) return
			void ghostApi.start({
				x: rect.left,
				y: rect.top,
				width: rect.width,
				height: rect.height,
				opacity: 1,
			})
		},
		[ghostApi],
	)

	/**
	 * The dragged card's transform — the single formula, used by the pointer
	 * handler, the auto-scroll frame and the post-reorder layout effect alike.
	 *
	 * `x` is measured from the card's *live* slot, so it is correct whether or not
	 * a reorder has moved it since pickup: before one, `now === firstRect` and
	 * this is just the raw movement; after one, it rebases automatically.
	 */
	const writeDragTransform = useCallback(() => {
		const drag = dragRef.current
		if (drag.kind !== "pointer" || !drag.firstRect) return
		const now = rectsRef.current.get(drag.id) ?? drag.firstRect
		const x = drag.firstRect.left + drag.movement[0] - now.left
		const y = drag.firstRect.top + drag.movement[1] + drag.autoScroll - now.top
		const target = springIndexRef.current.get(drag.id)
		api.start((index) =>
			index === target
				? { x, y, immediate: (key: string) => key === "x" || key === "y" }
				: false,
		)
	}, [api])

	/**
	 * Invert and play in a single `start` — react-spring applies `from`
	 * synchronously, so there is no frame where a card is painted un-inverted.
	 */
	const playFlip = useCallback(
		(prev: Map<string, BentoRect>, next: Map<string, BentoRect>) => {
			const drag = dragRef.current
			const pinned = drag.kind === "pointer" ? drag.id : null
			const releasing = releaseRef.current?.id ?? null

			api.start((index) => {
				const id = stableIds[index]
				if (id === undefined || id === pinned || id === releasing) return false
				const a = prev.get(id)
				const b = next.get(id)
				if (!a || !b) return false
				const dx = a.left - b.left
				const dy = a.top - b.top
				if (dx === 0 && dy === 0) return false
				return {
					from: { x: dx, y: dy },
					to: { x: 0, y: 0 },
					delay: Math.min(
						BENTO_NEIGHBOUR_DELAY_MAX_MS,
						Math.hypot(dx, dy) * BENTO_NEIGHBOUR_DELAY_PER_PX,
					),
					config: BENTO_SETTLE,
				}
			})
		},
		[api, stableIds],
	)

	/**
	 * Measure after **every** commit. Keying this on a hash of the arrangement is
	 * a bug waiting to happen: the hash is byte-identical on drop, so the effect
	 * would be skipped and the cached rects would go stale exactly when the
	 * release animation needs them. Six cards is cheap.
	 */
	useLayoutEffect(() => {
		const next = readAllRects()
		const prev = rectsRef.current
		rectsRef.current = next
		boundsRef.current = readColumnBounds()

		const key = columns.map((column) => column.join(",")).join("|")
		const arrangementChanged = measuredKeyRef.current !== key
		measuredKeyRef.current = key

		if (prev.size === 0) {
			if (reveal && !hasRevealedRef.current && next.size > 0) {
				hasRevealedRef.current = true
				const flat = flattenColumns(columns)
				api.start((index) => {
					const slot = flat.indexOf(stableIds[index])
					return {
						from: { opacity: 0, y: BENTO_REVEAL_Y },
						to: { opacity: 1, y: 0 },
						delay: Math.max(0, slot) * BENTO_REVEAL_STAGGER_MS,
						config: BENTO_REVEAL,
					}
				})
			}
			return
		}

		// Only a rearrangement animates. A card's own content growing must refresh
		// the geometry silently rather than slide the grid under someone reading it.
		if (arrangementChanged) playFlip(prev, next)

		const release = releaseRef.current
		if (release) {
			releaseRef.current = null
			const now = next.get(release.id)
			const target = springIndexRef.current.get(release.id)
			const results = api.start((index) =>
				index === target
					? {
							from:
								now && release.pinned
									? {
											x: release.visualLeft - now.left,
											y: release.visualTop - now.top,
										}
									: {},
							to: { x: 0, y: 0, scale: 1, shadow: 0 },
							config: BENTO_DROP,
						}
					: false,
			)
			// Resolved by the promise rather than `onRest`: a superseded animation
			// always flushes its pending promise, but only fires `onRest` when it
			// actually changed — so `onRest` can silently never run and leave the card
			// stranded above its neighbours at `z-10`.
			void Promise.all(results).then(() => {
				setSettlingId((current) => (current === release.id ? null : current))
			})
		}

		const drag = dragRef.current
		if (drag.kind !== "idle") {
			moveGhostTo(next.get(drag.id))
			writeDragTransform()
		}
		// Moving a card to another column relocates its DOM node, which drops
		// focus — and `handleBlur` reads that as "the member tabbed away" and
		// commits. Put focus back so a keyboard drag survives crossing a column.
		if (drag.kind === "keyboard") {
			const handle = handleRefs.current.get(drag.id)
			if (handle && document.activeElement !== handle) handle.focus()
		}
	})

	// Geometry can change without a React render: a font swap, a window resize, a
	// native control expanding. Never while a pointer drag is live, though — the
	// rect map is what hit-testing reads.
	useEffect(() => {
		const container = containerRef.current
		if (!container || typeof ResizeObserver === "undefined") return

		const handle = () => {
			if (reflowRafRef.current !== null) {
				cancelAnimationFrame(reflowRafRef.current)
			}
			reflowRafRef.current = requestAnimationFrame(() => {
				reflowRafRef.current = null
				if (dragRef.current.kind !== "idle") return
				rectsRef.current = readAllRects()
				boundsRef.current = readColumnBounds()
			})
		}

		const observer = new ResizeObserver(handle)
		observer.observe(container)
		for (const node of nodeRefs.current.values()) observer.observe(node)
		void document.fonts?.ready.then(handle).catch(() => {})

		return () => {
			observer.disconnect()
			if (reflowRafRef.current !== null) {
				cancelAnimationFrame(reflowRafRef.current)
				reflowRafRef.current = null
			}
		}
	}, [itemsKey, readAllRects, readColumnBounds])

	const announce = useCallback(
		(id: string, verb: string, slot: BentoSlotRef) => {
			const label = metaRef.current.get(id)?.label ?? id
			const total = columnsRef.current[slot.column]?.length ?? 0
			const columnCount = columnsRef.current.length
			const where =
				columnCount > 1
					? ` Column ${slot.column + 1} of ${columnCount}, position ${slot.index + 1} of ${total}.`
					: ` Position ${slot.index + 1} of ${total}.`
			setAnnouncement(`${verb} ${label}.${where}`)
		},
		[],
	)

	const applyTarget = useCallback(
		(
			drag: Extract<DragState, { kind: "pointer" | "keyboard" }>,
			target: BentoSlotRef,
		) => {
			if (
				target.column === drag.target.column &&
				target.index === drag.target.index
			) {
				return
			}
			drag.target = target
			const next = moveCard(drag.base, drag.id, target)
			setPreviewColumns(next)
			columnsRef.current = next
			announce(drag.id, "Moved", target)
		},
		[announce],
	)

	/** Re-runs hit-testing from the frozen pickup frame. No DOM reads. */
	const updateDropTarget = useCallback(() => {
		const drag = dragRef.current
		if (drag.kind === "idle" || !drag.firstRect) return

		// Same numbers the transform uses, so what is painted and what is
		// hit-tested can never disagree.
		const centroid = {
			x: drag.firstRect.left + drag.movement[0] + drag.firstRect.width / 2,
			y:
				drag.firstRect.top +
				drag.movement[1] +
				drag.autoScroll +
				drag.firstRect.height / 2,
		}

		applyTarget(
			drag,
			resolveMasonryTarget({
				columns: drag.base,
				draggingId: drag.id,
				rects: drag.baseRects,
				columnBounds: boundsRef.current,
				centroid,
				current: drag.target,
				hysteresis: BENTO_HYSTERESIS_PX,
			}),
		)
	}, [applyTarget])

	const stopAutoScroll = useCallback(() => {
		if (autoScrollRafRef.current !== null) {
			cancelAnimationFrame(autoScrollRafRef.current)
			autoScrollRafRef.current = null
		}
	}, [])

	/**
	 * The frame loop owns the speed calculation, reading the pointer position the
	 * gesture handler last stored. That is what lets it keep scrolling while the
	 * finger is held **still** in the edge band.
	 */
	const ensureAutoScroll = useCallback(() => {
		if (autoScrollRafRef.current !== null) return

		const step = (now: number) => {
			autoScrollRafRef.current = null
			const drag = dragRef.current
			const scroller = scrollerRef.current
			if (drag.kind !== "pointer" || !scroller) return

			const previous = drag.lastFrameAt
			drag.lastFrameAt = now
			// The first frame only seeds the clock. A rAF timestamp is the *frame
			// start*, which can predate the `performance.now()` taken when the frame
			// was scheduled from an event handler — seeding from that clock yields a
			// negative dt and the scroller never moves. Also clamped at the top end so
			// a backgrounded tab does not jump a thousand pixels on resume.
			const dt = previous === 0 ? 0 : clamp((now - previous) / 1000, 0, 0.05)

			// Bands are clamped to the viewport and recomputed every frame. Caching a
			// raw `rect.bottom` once puts the bottom trigger off-screen whenever any
			// part of the scroller sits below the fold.
			const isDocument =
				scroller === document.scrollingElement ||
				scroller === document.documentElement
			const viewport = window.innerHeight
			const rect = isDocument ? null : scroller.getBoundingClientRect()
			const top = Math.max(rect ? rect.top : 0, 0)
			const bottom = Math.min(rect ? rect.bottom : viewport, viewport)
			// Capped at a third of the visible slice so the two bands cannot overlap
			// in a short panel and fight each other.
			const zone = Math.min(
				BENTO_AUTOSCROLL_ZONE_PX,
				Math.max(0, (bottom - top) / 3),
			)

			let speed = 0
			if (zone > 0) {
				if (drag.pointerY < top + zone) {
					speed =
						-BENTO_AUTOSCROLL_MAX_PX_PER_SEC *
						clamp((top + zone - drag.pointerY) / zone, 0, 1)
				} else if (drag.pointerY > bottom - zone) {
					speed =
						BENTO_AUTOSCROLL_MAX_PX_PER_SEC *
						clamp((drag.pointerY - (bottom - zone)) / zone, 0, 1)
				}
			}
			// Out of the band — stop. A later pointermove restarts the loop.
			if (speed === 0) return

			const before = scroller.scrollTop
			const max = scroller.scrollHeight - scroller.clientHeight
			// Already hard against the end the finger is pulling towards — stop.
			if (speed > 0 ? before >= max : before <= 0) return

			scroller.scrollTop = clamp(before + speed * dt, 0, max)
			const applied = scroller.scrollTop - before
			if (applied !== 0) {
				// The card is transform-positioned inside content that just moved, so
				// compensate or it slides out from under the finger.
				drag.autoScroll += applied
				writeDragTransform()
				updateDropTarget()
			}

			// Re-armed on the seeding frame too, which is why the stop conditions
			// above are about speed and scroll extent rather than about `applied`.
			autoScrollRafRef.current = requestAnimationFrame(step)
		}

		const drag = dragRef.current
		// 0 means "unseeded" — the loop takes its first reading from rAF itself.
		if (drag.kind === "pointer") drag.lastFrameAt = 0
		autoScrollRafRef.current = requestAnimationFrame(step)
	}, [writeDragTransform, updateDropTarget])

	/** Shared by pointer release, keyboard commit and cancel. */
	const finishDrag = useCallback(
		(commit: boolean) => {
			const drag = dragRef.current
			if (drag.kind === "idle") return
			stopAutoScroll()

			const next = commit
				? moveCard(drag.base, drag.id, drag.target)
				: drag.base

			releaseRef.current = {
				id: drag.id,
				pinned: drag.kind === "pointer" && drag.firstRect !== null,
				visualLeft: (drag.firstRect?.left ?? 0) + drag.movement[0],
				visualTop:
					(drag.firstRect?.top ?? 0) + drag.movement[1] + drag.autoScroll,
			}
			dragRef.current = { kind: "idle" }
			scrollerRef.current = null

			if (commit) setStoredColumns(scope, columnCountRef.current, next)
			setPreviewColumns(null)
			setLiftedId(null)
			setSettlingId(drag.id)
			void ghostApi.start({ opacity: 0 })

			announce(
				drag.id,
				commit ? "Dropped" : "Cancelled, returned",
				locate(next, drag.id) ?? drag.target,
			)
		},
		[ghostApi, announce, scope, setStoredColumns, stopAutoScroll],
	)

	const beginDrag = useCallback(
		(id: string, viaKeyboard: boolean) => {
			if (!rectsRef.current.has(id)) rectsRef.current = readAllRects()
			if (boundsRef.current.length === 0) boundsRef.current = readColumnBounds()
			const firstRect = rectsRef.current.get(id) ?? null
			// Only a pointer drag is geometric. Refusing a keyboard lift for want of a
			// measurement would break reordering in exactly the environments that
			// cannot measure — a hidden tab, or a test.
			if (!firstRect && !viaKeyboard) {
				if (import.meta.env.DEV) {
					console.warn(
						`[bento] cannot pick up "${id}" — it has not been measured yet.`,
					)
				}
				return
			}

			const base = committedRef.current.map((column) => [...column])
			const slot = locate(base, id)
			if (!slot) return

			dragRef.current = {
				kind: viaKeyboard ? "keyboard" : "pointer",
				id,
				base,
				target: slot,
				firstRect,
				baseRects: new Map(rectsRef.current),
				movement: [0, 0],
				autoScroll: 0,
				pointerY: 0,
				lastFrameAt: 0,
			}

			setLiftedId(id)
			setSettlingId(null)

			const target = springIndexRef.current.get(id)
			api.start((index) =>
				index === target
					? { scale: BENTO_LIFT_SCALE, shadow: 1, config: BENTO_LIFT }
					: false,
			)
			moveGhostTo(firstRect ?? undefined)
			announce(id, "Picked up", slot)
		},
		[api, announce, moveGhostTo, readAllRects, readColumnBounds],
	)

	const bindDrag = useDrag(
		(state) => {
			const id = state.args[0] as string
			if (metaRef.current.get(id)?.sortable === false) return

			const {
				first,
				last,
				canceled,
				movement: [mx, my],
				xy: [, clientY],
			} = state

			if (last || canceled) {
				finishDrag(!canceled)
				return
			}

			if (first) {
				const container = containerRef.current
				scrollerRef.current =
					(container ? scrollParent(container) : null) ??
					(document.scrollingElement as HTMLElement | null)
				beginDrag(id, false)
				// Deliberately falls through. `useDrag` reports `first` on the first
				// move *past* the tap filter, so this event already carries real
				// movement — returning here would leave the card a frame behind.
			}

			const drag = dragRef.current
			if (drag.kind !== "pointer" || drag.id !== id) return

			drag.movement = [mx, my]
			drag.pointerY = clientY
			writeDragTransform()
			updateDropTarget()
			ensureAutoScroll()
		},
		{
			// A click on the grip must not register as a zero-distance drag.
			filterTaps: true,
			pointer: {
				// We own Space/Enter for the keyboard reorder state machine.
				keys: false,
				/**
				 * Pointer capture OFF, deliberately.
				 *
				 * With capture on (the default) `@use-gesture` binds move/end to the
				 * grip element itself and treats `lostpointercapture` as a pointer-up.
				 * Reordering moves the dragged card's DOM node, the browser releases
				 * capture the moment it does, and the gesture ends by itself — the
				 * card drops mid-drag without the member letting go, then sits
				 * stranded because their pointer is still down.
				 *
				 * With capture off the listeners live on `window`, so relocating the
				 * node is irrelevant and the gesture runs until they actually
				 * release. This is the one config a DOM-reordering sortable cannot
				 * leave at its default.
				 */
				capture: false,
			},
		},
	)

	/**
	 * Arrow keys map onto the masonry directly: up/down walks a column, left/right
	 * crosses to the neighbouring one. With no rows to be ambiguous about, this is
	 * the arrangement the member actually sees.
	 */
	const moveByKeyboard = useCallback(
		(dColumn: number, dIndex: number) => {
			const drag = dragRef.current
			if (drag.kind === "idle") return
			const width = drag.base.length
			const column = clamp(drag.target.column + dColumn, 0, width - 1)
			const preview = moveCard(drag.base, drag.id, { column, index: 0 })
			const height = preview[column].length
			const index =
				dColumn !== 0
					? clamp(drag.target.index, 0, height - 1)
					: clamp(drag.target.index + dIndex, 0, height - 1)
			applyTarget(drag, { column, index })
		},
		[applyTarget],
	)

	const handleKeyDown = useCallback(
		(id: string) => (event: ReactKeyboardEvent<HTMLElement>) => {
			const drag = dragRef.current
			const lifted = drag.kind === "keyboard" && drag.id === id

			if (!lifted) {
				if (ACTIVATION_KEYS.has(event.key) && !event.repeat) {
					event.preventDefault()
					beginDrag(id, true)
				}
				return
			}

			if (ACTIVATION_KEYS.has(event.key)) {
				event.preventDefault()
				finishDrag(true)
				return
			}
			if (event.key === "Escape") {
				event.preventDefault()
				finishDrag(false)
				return
			}
			// Otherwise the `overflow-y-auto` panel scrolls instead.
			if (event.key === "ArrowUp") {
				event.preventDefault()
				moveByKeyboard(0, -1)
			} else if (event.key === "ArrowDown") {
				event.preventDefault()
				moveByKeyboard(0, 1)
			} else if (event.key === "ArrowLeft") {
				event.preventDefault()
				moveByKeyboard(-1, 0)
			} else if (event.key === "ArrowRight") {
				event.preventDefault()
				moveByKeyboard(1, 0)
			}
		},
		[beginDrag, finishDrag, moveByKeyboard],
	)

	const handleBlur = useCallback(
		(id: string) => () => {
			// Never strand the member mid-lift because focus moved on.
			const drag = dragRef.current
			if (drag.kind === "keyboard" && drag.id === id) finishDrag(true)
		},
		[finishDrag],
	)

	// Called during render, so this reads render scope directly rather than the
	// handler refs — memoising it would only hand the cards stale labels.
	const getHandleProps = (id: string): BentoHandleProps | null => {
		const meta = metaById.get(id)
		if (!meta || meta.sortable === false) return null
		return {
			...bindDrag(id),
			ref: (node: HTMLElement | null) => registerHandle(id, node),
			type: "button",
			onKeyDown: handleKeyDown(id),
			onBlur: handleBlur(id),
			"aria-label": `Reorder ${meta.label}`,
			"aria-roledescription": "sortable card",
			"aria-describedby": BENTO_INSTRUCTIONS_ID,
			"data-lifted": liftedId === id,
		}
	}

	/**
	 * Escape abandons a pointer drag. `useDrag` only reports `canceled` when the
	 * gesture itself calls `cancel()`, so without this the only way out of a
	 * pointer drag is to commit it somewhere.
	 */
	useEffect(() => {
		if (liftedId === null) return
		const onKey = (event: KeyboardEvent) => {
			if (event.key !== "Escape") return
			if (dragRef.current.kind !== "pointer") return
			event.preventDefault()
			finishDrag(false)
		}
		window.addEventListener("keydown", onKey)
		return () => window.removeEventListener("keydown", onKey)
	}, [liftedId, finishDrag])

	useEffect(() => stopAutoScroll, [stopAutoScroll])

	return {
		containerRef,
		columns,
		columnCount,
		springFor,
		registerItem,
		registerColumn,
		getHandleProps,
		ghostStyle,
		liftedId,
		settlingId,
		announcement,
	}
}

/**
 * The reconciled arrangement without any of the measuring machinery — for the
 * loading skeleton, which must lay its bones out the way the member arranged
 * them or the whole grid re-shuffles the instant real data lands.
 */
export function useBentoColumns(
	scope: BentoScope,
	defaults: readonly string[],
): BentoColumns {
	const stored = useBentoLayoutStore((state) => state.layouts[scope]?.columns)
	const count = useColumnCount()

	const key = defaults.join("|")
	const storedForCount = stored?.[String(count)]
	return useMemo(
		() => reconcileColumns(storedForCount, key.split("|"), count),
		[storedForCount, key, count],
	)
}
