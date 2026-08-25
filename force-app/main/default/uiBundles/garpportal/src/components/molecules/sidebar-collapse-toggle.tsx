import { animated, to, useSpring } from "@react-spring/web"
import { ChevronLeft, ChevronRight } from "lucide-react"

import {
	Tooltip,
	TooltipContent,
	TooltipTrigger,
} from "@/components/atoms/tooltip"

/** Matches ThemeToggle's icon crossfade so the two chrome toggles feel alike. */
const ICON_SPRING = { mass: 0.85, tension: 340, friction: 22 } as const

type SidebarCollapseToggleProps = {
	collapsed: boolean
	onToggle: () => void
	/** Id of the rail this controls, for `aria-controls`. */
	controls: string
}

/**
 * The rail's collapse control: a small disc straddling the sidebar's right edge.
 *
 * It sits *outside* the `<aside>` rather than inside it, because the aside is
 * `overflow-x-hidden` — anything half-overhanging its edge would be sliced in
 * half. Its positioned ancestor is the rail wrapper, which animates width, so
 * the disc rides the edge for free instead of needing a spring of its own.
 *
 * 32px across, with `-right-4` putting exactly half of it past the rail edge.
 * The offset is deliberately half the size: any other value reads as a button
 * placed *near* the edge rather than one straddling it.
 *
 * Bordered in `primary` rather than `border`, because `--border` is white at
 * 10% in dark mode — a hairline that vanishes against a near-black disc on a
 * near-black rail. `primary` is the one brand token declared mode-invariant, so
 * a single rule carries the control in both themes, and it matches the purple
 * the rail already uses for its active puck.
 *
 * Vertically it lands on the profile avatar's centre: container `p-3` (12) +
 * half the 44px avatar's `py-4` row (38) = 50px, with `-translate-y-1/2`
 * centring the disc on that line.
 *
 * That 50px is a measurement, not a nudge. The disc sits in the band where each
 * page draws its own header — a back-arrow on Programs, an `<h1>` on Events —
 * so any offset picked to look right beside one route's header looks arbitrary
 * beside the next one's. Aligning it to the avatar instead ties it to the only
 * landmark at that height that never moves, which is what makes it read as
 * deliberate on every route.
 *
 * The chevron crossfades on a spring rather than swapping, so a fast
 * double-toggle reads as one control changing its mind, not a flicker.
 */
function SidebarCollapseToggle({
	collapsed,
	onToggle,
	controls,
}: SidebarCollapseToggleProps) {
	const leftSpring = useSpring({
		opacity: collapsed ? 0 : 1,
		scale: collapsed ? 0.4 : 1,
		config: ICON_SPRING,
	})
	const rightSpring = useSpring({
		opacity: collapsed ? 1 : 0,
		scale: collapsed ? 1 : 0.4,
		config: ICON_SPRING,
	})

	const hint = `${collapsed ? "Expand" : "Collapse"} sidebar (⌘/Ctrl + B)`

	return (
		<Tooltip>
			<TooltipTrigger asChild>
				<button
					type="button"
					onClick={onToggle}
					aria-expanded={!collapsed}
					aria-controls={controls}
					aria-label={hint}
					className="absolute top-[50px] -right-4 z-10 flex size-8 -translate-y-1/2 cursor-pointer items-center justify-center rounded-full border-2 border-primary/50 bg-background text-primary shadow-md transition-colors hover:border-primary hover:bg-primary hover:text-primary-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
				>
					<animated.span
						className="absolute inset-0 flex items-center justify-center"
						style={{
							opacity: leftSpring.opacity,
							transform: to(leftSpring.scale, (scale) => `scale(${scale})`),
						}}
						aria-hidden
					>
						<ChevronLeft className="size-[18px]" strokeWidth={2.5} />
					</animated.span>
					<animated.span
						className="absolute inset-0 flex items-center justify-center"
						style={{
							opacity: rightSpring.opacity,
							transform: to(rightSpring.scale, (scale) => `scale(${scale})`),
						}}
						aria-hidden
					>
						<ChevronRight className="size-[18px]" strokeWidth={2.5} />
					</animated.span>
				</button>
			</TooltipTrigger>
			<TooltipContent side="right">{hint}</TooltipContent>
		</Tooltip>
	)
}

export { SidebarCollapseToggle }
