import type { KeyboardEvent as ReactKeyboardEvent } from "react"
import { useCallback, useEffect, useId, useLayoutEffect, useRef, useState } from "react"
import { animated, to, useSpring, useTransition } from "@react-spring/web"
import { useLocation } from "@tanstack/react-router"
import { ChevronLeft, ChevronRight } from "lucide-react"

import { MegaMenuPanel } from "@/components/molecules/mega-menu-panel"
import { NavMegaMenuTrigger } from "@/components/molecules/nav-mega-menu-trigger"
import { NAV_OVERFLOW_KEY, useNavOverflow } from "@/hooks/use-nav-overflow"
import { useSlidingIndicator } from "@/hooks/use-sliding-indicator"
import { TOP_NAV_ITEMS } from "@/config/navigation/top-nav-items"
import type { TopNavItem } from "@/config/navigation/types"
import { NAV_CONTENT_SPRING, NAV_MORPH_SPRING, NAV_PANEL_SPRING } from "@/lib/nav-spring"
import { useNavigationStore } from "@/store/navigation-store"

const MORE_LABEL = "More"
/**
 * Space between trigger pills, so an open pill and its hovered neighbour never
 * touch. Must equal the row's `gap-x-1.5` — the overflow math adds it to every
 * measured width, since the absolutely-positioned measuring copies cannot
 * carry the live row's gaps themselves.
 */
const NAV_ROW_GAP_PX = 6
/** Keeps the panel clear of both viewport edges. */
const VIEWPORT_GUTTER = 20
/** Distance from the panel's left edge to the caret when there is room for it. */
const CARET_INSET = 44
/** Caret can never reach a rounded corner. */
const CARET_EDGE_CLEARANCE = 18
/** How far content slides while cross-fading between menus. */
const CONTENT_SHIFT_PX = 10
/** Marks the layer that is arriving, so keyboard entry never targets the outgoing one. */
const ACTIVE_LAYER_ATTR = "data-nav-panel-active"
const ACTIVE_LAYER_SELECTOR = `[${ACTIVE_LAYER_ATTR}="true"]`

const getNavItemKey = (item: TopNavItem) => item.title

/**
 * The desktop top-nav row and the single mega-menu panel it drives.
 *
 * Two deliberate departures from the version this replaces:
 *
 * 1. **One panel, not one per item.** The panel's position and size are springs,
 *    so switching FRM → SCR glides and resizes a single surface instead of
 *    unmounting one panel and mounting another somewhere else.
 * 2. **Click, not hover.** No open-on-hover and therefore no close-delay timer;
 *    keyboard support (arrows + Escape) carries the weight hover used to.
 *
 * Items that don't fit collapse into a "More" trigger rather than shrinking the
 * type, so the row's left edge stays put at any width.
 */
function NavMegaMenu() {
	const panelId = useId()
	const { pathname } = useLocation()

	const openTitle = useNavigationStore((state) => state.openDesktopNavTitle)
	const drillTitle = useNavigationStore((state) => state.desktopMoreDrillTitle)
	const openDesktopNav = useNavigationStore((state) => state.openDesktopNav)
	const toggleDesktopNav = useNavigationStore((state) => state.toggleDesktopNav)
	const closeDesktopNav = useNavigationStore((state) => state.closeDesktopNav)
	const openDesktopMoreDrill = useNavigationStore((state) => state.openDesktopMoreDrill)
	const backToDesktopMoreRoot = useNavigationStore((state) => state.backToDesktopMoreRoot)

	const {
		containerRef: overflowContainerRef,
		registerMeasureRef,
		visibleItems,
		overflowItems,
		hasOverflow,
	} = useNavOverflow({
		items: TOP_NAV_ITEMS,
		getKey: getNavItemKey,
		gapPx: NAV_ROW_GAP_PX,
	})

	const orderedTitles = [
		...visibleItems.map(getNavItemKey),
		...(hasOverflow ? [NAV_OVERFLOW_KEY] : []),
	]

	const {
		containerRef: indicatorContainerRef,
		registerRef: registerIndicatorRef,
		indicatorStyle,
	} = useSlidingIndicator<HTMLDivElement>({
		axis: "x",
		// The highlight is a rounded pill, so `scale` would distort its corners.
		technique: "size",
		value: openTitle,
		itemsKey: orderedTitles.join("|"),
	})

	/*
	 * A plain Map rather than a ref: the panel needs to read a trigger's rect
	 * from event handlers and effects, and holding it in state-initialised
	 * storage keeps that out of the ref-during-render rules entirely.
	 */
	const [triggerNodes] = useState(() => new Map<string, HTMLButtonElement>())
	const registerTrigger = useCallback(
		(key: string, node: HTMLButtonElement | null) => {
			if (node) triggerNodes.set(key, node)
			else triggerNodes.delete(key)
			registerIndicatorRef(key, node)
		},
		[registerIndicatorRef, triggerNodes],
	)

	const navRowRef = useRef<HTMLDivElement | null>(null)
	const setNavRow = useCallback(
		(node: HTMLDivElement | null) => {
			navRowRef.current = node
			overflowContainerRef.current = node
			indicatorContainerRef.current = node
		},
		[indicatorContainerRef, overflowContainerRef],
	)

	/* ---------------------------------------------------------------- content */

	const isMoreOpen = openTitle === NAV_OVERFLOW_KEY
	const contentKey = !openTitle
		? null
		: isMoreOpen && drillTitle
			? `${NAV_OVERFLOW_KEY}:${drillTitle}`
			: openTitle

	/*
	 * Derived-during-render state, not a ref: `tracked.key` is retained through
	 * the close animation so the panel fades out still showing what it was
	 * showing, and `direction` records which way the last change travelled —
	 * drilling into a "More" entry slides forward, backing out reverses.
	 *
	 * Both are read in the same pass they are set, so the content transition
	 * never starts with a stale direction.
	 */
	const [tracked, setTracked] = useState(() => ({
		key: TOP_NAV_ITEMS[0]?.title ?? NAV_OVERFLOW_KEY,
		direction: 1,
	}))
	let renderKey = tracked.key
	let direction = tracked.direction
	if (contentKey && contentKey !== tracked.key) {
		direction = tracked.key.startsWith(`${contentKey}:`) ? -1 : 1
		renderKey = contentKey
		setTracked({ key: renderKey, direction })
	}
	const shift = CONTENT_SHIFT_PX * direction

	const renderContent = useCallback(
		(key: string) => {
			if (key === NAV_OVERFLOW_KEY) {
				return (
					<div className="w-max min-w-56 p-2">
						{overflowItems.map((item) => (
							<button
								key={item.title}
								type="button"
								className="flex w-full cursor-pointer items-center justify-between gap-10 rounded-xl px-3 py-2.5 text-left text-nav font-bold text-popover-foreground hover:bg-accent hover:text-accent-foreground"
								onClick={() => openDesktopMoreDrill(item.title)}
							>
								{item.title}
								<ChevronRight className="size-4 shrink-0" aria-hidden />
							</button>
						))}
					</div>
				)
			}

			if (key.startsWith(`${NAV_OVERFLOW_KEY}:`)) {
				const title = key.slice(NAV_OVERFLOW_KEY.length + 1)
				const item = TOP_NAV_ITEMS.find((entry) => entry.title === title)
				if (!item) return null
				return (
					<div className="w-max">
						<button
							type="button"
							className="m-2 inline-flex cursor-pointer items-center gap-1 rounded-xl px-2 py-1.5 text-body font-bold text-primary hover:bg-accent hover:text-accent-foreground"
							onClick={backToDesktopMoreRoot}
						>
							<ChevronLeft className="size-4" aria-hidden />
							{MORE_LABEL}
						</button>
						<MegaMenuPanel item={item} variant="desktop" />
					</div>
				)
			}

			const item = TOP_NAV_ITEMS.find((entry) => entry.title === key)
			return item ? <MegaMenuPanel item={item} variant="desktop" /> : null
		},
		[backToDesktopMoreRoot, openDesktopMoreDrill, overflowItems],
	)

	/* --------------------------------------------------------------- geometry */

	/*
	 * The panel's target size is read from an always-mounted invisible copy of
	 * the same content at its natural width. Measuring the visible surface is
	 * impossible once its own width is being animated.
	 */
	const measureRef = useRef<HTMLDivElement | null>(null)
	const [size, setSize] = useState({ width: 0, height: 0 })

	useLayoutEffect(() => {
		const node = measureRef.current
		if (!node) return
		const read = () => setSize({ width: node.offsetWidth, height: node.offsetHeight })
		read()
		if (typeof ResizeObserver === "undefined") return
		const observer = new ResizeObserver(read)
		observer.observe(node)
		return () => observer.disconnect()
	}, [renderKey])

	const [geometry, geometryApi] = useSpring(() => ({
		x: 0,
		caretX: CARET_INSET,
		width: 0,
		height: 0,
		config: NAV_MORPH_SPRING,
	}))
	/** First placement jumps; every later one glides. */
	const placed = useRef(false)

	const place = useCallback(
		(immediate: boolean) => {
			if (!openTitle) return false
			const node = triggerNodes.get(openTitle)
			if (!node || size.width === 0) return false

			const rect = node.getBoundingClientRect()
			const center = rect.left + rect.width / 2
			const width = Math.min(size.width, window.innerWidth - VIEWPORT_GUTTER * 2)
			const x = Math.max(
				VIEWPORT_GUTTER,
				Math.min(center - CARET_INSET, window.innerWidth - width - VIEWPORT_GUTTER),
			)
			const caretX = Math.max(
				CARET_EDGE_CLEARANCE,
				Math.min(center - x, width - CARET_EDGE_CLEARANCE),
			)

			void geometryApi.start({ x, caretX, width, height: size.height, immediate })
			return true
		},
		[geometryApi, openTitle, size.height, size.width, triggerNodes],
	)

	useLayoutEffect(() => {
		if (!openTitle) {
			placed.current = false
			return
		}
		if (place(!placed.current)) placed.current = true
	}, [openTitle, place])

	useEffect(() => {
		if (!openTitle) return
		// A resize should track the trigger instantly — a spring chasing a drag
		// would lag behind the pointer.
		const onResize = () => void place(true)
		window.addEventListener("resize", onResize)
		return () => window.removeEventListener("resize", onResize)
	}, [openTitle, place])

	/* --------------------------------------------------------------- motion */

	const panelTransitions = useTransition(Boolean(openTitle), {
		from: { opacity: 0, y: -8, scale: 0.97 },
		enter: { opacity: 1, y: 0, scale: 1 },
		leave: { opacity: 0, y: -6, scale: 0.98 },
		config: NAV_PANEL_SPRING,
	})

	const contentTransitions = useTransition(renderKey, {
		from: { opacity: 0, transform: `translateX(${shift}px)` },
		enter: { opacity: 1, transform: "translateX(0px)" },
		leave: { opacity: 0, transform: `translateX(${-shift}px)` },
		config: NAV_CONTENT_SPRING,
	})

	const scrim = useSpring({
		opacity: openTitle ? 1 : 0,
		config: NAV_PANEL_SPRING,
	})

	/* ------------------------------------------------------ close + keyboard */

	const panelRef = useRef<HTMLDivElement | null>(null)

	useEffect(() => {
		closeDesktopNav()
	}, [pathname, closeDesktopNav])

	useEffect(() => {
		if (!openTitle) return

		function onKeyDown(event: KeyboardEvent) {
			if (event.key !== "Escape") return
			const trigger = openTitle ? triggerNodes.get(openTitle) : null
			closeDesktopNav()
			trigger?.focus()
		}

		/*
		 * Capture phase so a click anywhere outside the row and panel closes
		 * first — including the toolbar's own logo and right-hand controls, which
		 * the scrim deliberately does not cover.
		 */
		function onPointerDown(event: PointerEvent) {
			const target = event.target as Node | null
			if (!target) return
			if (navRowRef.current?.contains(target)) return
			if (panelRef.current?.contains(target)) return
			closeDesktopNav()
		}

		window.addEventListener("keydown", onKeyDown)
		document.addEventListener("pointerdown", onPointerDown, true)
		return () => {
			window.removeEventListener("keydown", onKeyDown)
			document.removeEventListener("pointerdown", onPointerDown, true)
		}
	}, [openTitle, closeDesktopNav, triggerNodes])

	function onTriggerKeyDown(event: ReactKeyboardEvent<HTMLButtonElement>, title: string) {
		if (event.key === "ArrowRight" || event.key === "ArrowLeft") {
			event.preventDefault()
			const index = orderedTitles.indexOf(title)
			if (index === -1) return
			const delta = event.key === "ArrowRight" ? 1 : -1
			const next = orderedTitles[(index + delta + orderedTitles.length) % orderedTitles.length]
			triggerNodes.get(next)?.focus()
			// Only follow the focus if a menu is already open — arrowing along a
			// closed row should not start popping panels open.
			if (openTitle) openDesktopNav(next)
			return
		}

		if (event.key === "ArrowDown") {
			event.preventDefault()
			if (openTitle !== title) openDesktopNav(title)
			/*
			 * After the panel has committed, so there is something to focus — and
			 * scoped to the *entering* layer. During a cross-fade the outgoing
			 * layer is still first in DOM order, and focusing a node that is about
			 * to unmount drops focus to <body>.
			 */
			requestAnimationFrame(() => {
				panelRef.current
					?.querySelector<HTMLElement>(
						`${ACTIVE_LAYER_SELECTOR} a[href], ${ACTIVE_LAYER_SELECTOR} button:not([disabled])`,
					)
					?.focus()
			})
		}
	}

	/* --------------------------------------------------------------- render */

	const trigger = (title: string) => (
		<NavMegaMenuTrigger
			key={title}
			title={title === NAV_OVERFLOW_KEY ? MORE_LABEL : title}
			isOpen={openTitle === title}
			panelId={panelId}
			registerRef={(node) => registerTrigger(title, node)}
			onToggle={() => toggleDesktopNav(title)}
			onKeyDown={(event) => onTriggerKeyDown(event, title)}
		/>
	)

	return (
		<>
			{/* Breathing room off the logo slot; the row's left edge is set by
			    `--spacing-toolbar-logo`, not by the content grid. */}
			<div className="flex min-w-0 flex-1 items-center pl-shell-gutter">
				{/* `-ml-3` cancels the first trigger's own padding: its *text* lands on
				    the grid line, not its hit area. */}
				<div ref={setNavRow} className="relative -ml-3 flex min-w-0 flex-1 items-center">
					{/*
					 * The only thing that travels between triggers. `inset-y-0` is
					 * load-bearing: this row is exactly as tall as a trigger, so any
					 * vertical inset makes the highlight shorter than the label it is
					 * meant to sit behind.
					 */}
					<animated.span
						className="pointer-events-none absolute inset-y-0 left-0 rounded-xl bg-toolbar-foreground/10"
						style={indicatorStyle}
						aria-hidden
					/>

					<nav className="flex min-w-0 items-center gap-x-1.5" aria-label="Primary">
						{visibleItems.map((item) => trigger(item.title))}
						{hasOverflow ? trigger(NAV_OVERFLOW_KEY) : null}
					</nav>

					{/*
					 * Widths are measured here, never from the live row — otherwise
					 * hiding an item frees space, which un-hides it, forever.
					 */}
					<div
						className="pointer-events-none invisible absolute top-0 left-0 flex"
						aria-hidden="true"
					>
						{TOP_NAV_ITEMS.map((item) => (
							<NavMegaMenuTrigger
								key={item.title}
								inert
								title={item.title}
								isOpen={false}
								panelId={panelId}
								registerRef={(node) => registerMeasureRef(item.title, node)}
							/>
						))}
						<NavMegaMenuTrigger
							inert
							title={MORE_LABEL}
							isOpen={false}
							panelId={panelId}
							registerRef={(node) => registerMeasureRef(NAV_OVERFLOW_KEY, node)}
						/>
					</div>
				</div>
			</div>

			{/* Natural-size copy of the active content — drives the width/height springs. */}
			<div
				ref={measureRef}
				aria-hidden="true"
				className="pointer-events-none invisible fixed top-20 left-0 w-max"
			>
				{renderContent(renderKey)}
			</div>

			<animated.div
				className="fixed top-20 right-0 bottom-0 left-0 bg-nav-scrim"
				style={{
					...scrim,
					visibility: scrim.opacity.to((opacity) => (opacity > 0.01 ? "visible" : "hidden")),
					pointerEvents: openTitle ? "auto" : "none",
				}}
				onClick={closeDesktopNav}
				aria-hidden="true"
			/>

			{panelTransitions((style, show) =>
				show ? (
					/*
					 * The wrapper's own box stays at the viewport's left edge — only the
					 * child is translated into place — so it must be click-transparent:
					 * it sits above the scrim, and catching clicks here leaves a dead
					 * zone below the navbar where the menu refuses to close. Pointer
					 * events are re-enabled on the panel surface itself.
					 */
					<div ref={panelRef} id={panelId} className="pointer-events-none fixed top-20 left-0 z-10">
						<animated.div
							className="relative pt-3"
							style={{ transform: geometry.x.to((x) => `translateX(${x}px)`) }}
						>
							{/* Caret — fill tracks the popover surface in both themes. */}
							<animated.span
								aria-hidden="true"
								className="pointer-events-none absolute top-3 block size-0 -translate-x-1/2 -translate-y-full border-x-[10px] border-b-[10px] border-x-transparent border-b-popover"
								style={{ left: geometry.caretX, opacity: style.opacity }}
							/>
							<animated.div
								className="origin-top overflow-hidden rounded-xl border border-border bg-popover text-popover-foreground shadow-lg"
								style={{
									// Inline, not a class: an explicit `auto` would defeat the
									// wrapper's pointer-events-none while the panel fades out.
									pointerEvents: openTitle ? "auto" : "none",
									width: geometry.width,
									height: geometry.height,
									opacity: style.opacity,
									transform: to(
										[style.y, style.scale],
										(y, scale) => `translateY(${y}px) scale(${scale})`,
									),
								}}
							>
								<div className="relative size-full">
									{contentTransitions((contentStyle, key) => (
										<animated.div
											className="absolute top-0 left-0 w-max"
											style={contentStyle}
											{...{ [ACTIVE_LAYER_ATTR]: String(key === renderKey) }}
										>
											{renderContent(key)}
										</animated.div>
									))}
								</div>
							</animated.div>
						</animated.div>
					</div>
				) : null,
			)}
		</>
	)
}

export { NavMegaMenu }
