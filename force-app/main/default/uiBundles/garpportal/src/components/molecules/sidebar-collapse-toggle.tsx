import { animated, to, useSpring } from "@react-spring/web"
import { PanelLeftClose, PanelLeftOpen } from "lucide-react"

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
 * The rail's collapse control: a compact pill straddling the sidebar's right edge.
 *
 * It sits *outside* the `<aside>` rather than inside it, because the aside is
 * `overflow-x-hidden` — anything half-overhanging its edge would be sliced in
 * half. Its positioned ancestor is the rail wrapper, which animates width, so
 * the pill rides the edge for free instead of needing a spring of its own.
 *
 * 44px wide, with `-right-[22px]` putting exactly half of it past the rail edge.
 * The offset is deliberately half the width: any other value reads as a button
 * placed *near* the edge rather than one straddling it.
 *
 * Vertically it lands on the profile avatar's centre: container `p-3` (12) +
 * half the 44px avatar's `py-4` row (38) = 50px, with `-translate-y-1/2`
 * centring the pill on that line. The avatar is the only landmark at that height
 * that never moves, so it is what makes the pill read as deliberate on routes
 * whose headers all start at different places.
 *
 * The icon crossfades on a spring rather than swapping, so a fast double-toggle
 * reads as one control changing its mind, not a flicker.
 */
function SidebarCollapseToggle({
	collapsed,
	onToggle,
	controls,
}: SidebarCollapseToggleProps) {
	const closeSpring = useSpring({
		opacity: collapsed ? 0 : 1,
		scale: collapsed ? 0.4 : 1,
		config: ICON_SPRING,
	})
	const openSpring = useSpring({
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
					className="absolute top-[50px] -right-[22px] z-10 flex h-8 w-11 -translate-y-1/2 cursor-pointer items-center justify-center rounded-2xl border-2 border-primary/50 bg-background text-primary shadow-md transition-colors hover:border-primary hover:bg-primary hover:text-primary-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
				>
					<animated.span
						className="absolute inset-0 flex items-center justify-center"
						style={{
							opacity: closeSpring.opacity,
							transform: to(closeSpring.scale, (scale) => `scale(${scale})`),
						}}
						aria-hidden
					>
						<PanelLeftClose className="size-[18px]" strokeWidth={2.25} />
					</animated.span>
					<animated.span
						className="absolute inset-0 flex items-center justify-center"
						style={{
							opacity: openSpring.opacity,
							transform: to(openSpring.scale, (scale) => `scale(${scale})`),
						}}
						aria-hidden
					>
						<PanelLeftOpen className="size-[18px]" strokeWidth={2.25} />
					</animated.span>
				</button>
			</TooltipTrigger>
			<TooltipContent side="right">{hint}</TooltipContent>
		</Tooltip>
	)
}

export { SidebarCollapseToggle }
