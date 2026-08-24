import type { KeyboardEvent } from "react"
import { animated, useSpring } from "@react-spring/web"
import { ChevronDown } from "lucide-react"

import { NAV_PANEL_SPRING } from "@/lib/nav-spring"
import { cn } from "@/lib/utils"

type NavMegaMenuTriggerProps = {
	title: string
	isOpen: boolean
	/** Id of the single shared panel, for `aria-controls`. */
	panelId: string
	onToggle?: () => void
	onKeyDown?: (event: KeyboardEvent<HTMLButtonElement>) => void
	registerRef?: (node: HTMLButtonElement | null) => void
	className?: string
	/** Measuring copies must not be reachable by Tab or screen readers. */
	inert?: boolean
}

/**
 * A top-nav label + chevron. Purely a trigger: the panel it opens is a single
 * shared surface owned by `NavMegaMenu`, so switching menus can glide one panel
 * across instead of unmounting and remounting per item.
 *
 * The chevron runs on `NAV_PANEL_SPRING` — the same config the panel opens with
 * — so the two read as one gesture rather than two animations that happen to
 * start together.
 */
function NavMegaMenuTrigger({
	title,
	isOpen,
	panelId,
	onToggle,
	onKeyDown,
	registerRef,
	className,
	inert = false,
}: NavMegaMenuTriggerProps) {
	const chevron = useSpring({ rotate: isOpen ? 180 : 0, config: NAV_PANEL_SPRING })

	return (
		<button
			ref={registerRef}
			type="button"
			tabIndex={inert ? -1 : undefined}
			aria-hidden={inert || undefined}
			aria-expanded={inert ? undefined : isOpen}
			aria-haspopup={inert ? undefined : "menu"}
			aria-controls={inert ? undefined : panelId}
			className={cn(
				// No per-width step-downs: `useNavOverflow` moves items into "More"
				// rather than shrinking type until six labels fit at any cost.
				"relative z-10 inline-flex shrink-0 cursor-pointer items-center gap-1 rounded-xl border-none bg-transparent px-3 py-2.5 text-nav leading-none font-bold whitespace-nowrap text-toolbar-foreground transition-colors outline-none hover:bg-toolbar-foreground/10 focus-visible:ring-2 focus-visible:ring-ring",
				className,
			)}
			onClick={onToggle}
			onKeyDown={onKeyDown}
		>
			<span className="leading-none">{title}</span>
			<animated.span
				className={cn("inline-flex shrink-0", isOpen && "text-primary")}
				style={{ transform: chevron.rotate.to((rotate) => `rotate(${rotate}deg)`) }}
			>
				<ChevronDown className="size-5" strokeWidth={2.5} aria-hidden="true" />
			</animated.span>
		</button>
	)
}

export { NavMegaMenuTrigger }
