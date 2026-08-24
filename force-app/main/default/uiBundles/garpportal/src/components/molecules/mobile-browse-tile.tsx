import { animated } from "@react-spring/web"

import { useSpringPress } from "@/hooks/use-spring-press"
import type { NavAccentToken, TopNavItem } from "@/config/navigation/types"
import { cn } from "@/lib/utils"

/**
 * Literal class pairs — Tailwind cannot see an interpolated `bg-${token}`, and
 * every brand swatch here is paired with its declared `-foreground` rather than
 * an assumed white or black (several of these fail AA with the obvious choice).
 */
const ACCENT_CLASSES: Record<NavAccentToken, string> = {
	"garp-cyan": "bg-garp-cyan text-garp-cyan-foreground",
	"garp-saffron": "bg-garp-saffron text-garp-saffron-foreground",
	"rai-orange": "bg-rai-orange text-rai-orange-foreground",
	"deep-purple": "bg-deep-purple text-deep-purple-foreground",
	"bright-purple": "bg-bright-purple text-bright-purple-foreground",
	"dark-blue-gray": "bg-dark-blue-gray text-dark-blue-gray-foreground",
}

type MobileBrowseTileProps = {
	item: TopNavItem
	onSelect: () => void
}

/** One card on the mobile Browse grid. Opens that mega-menu as a pushed sub-view. */
function MobileBrowseTile({ item, onSelect }: MobileBrowseTileProps) {
	const { bind, style } = useSpringPress<HTMLButtonElement>()
	const Icon = item.icon
	/*
	 * For Membership and About Us the first column is named after the menu
	 * itself, and "Membership / Membership" reads as a bug rather than a caption.
	 */
	const caption = item.column1.header === item.title ? null : item.column1.header

	return (
		<animated.button
			type="button"
			{...bind}
			style={style}
			onClick={onSelect}
			className="flex size-full cursor-pointer flex-col items-start gap-3 rounded-xl border border-border bg-card p-4 text-left"
		>
			{/* Same 44px puck as every nav row, so the whole panel keeps one rhythm. */}
			<span
				className={cn(
					"flex size-11 shrink-0 items-center justify-center rounded-full",
					ACCENT_CLASSES[item.accentToken],
				)}
			>
				<Icon className="size-[22px]" aria-hidden />
			</span>
			<span className="flex min-w-0 flex-col">
				<span className="text-base leading-tight font-bold text-card-foreground">
					{item.title}
				</span>
				{caption ? (
					<span className="truncate text-caption text-muted-foreground">{caption}</span>
				) : null}
			</span>
		</animated.button>
	)
}

export { MobileBrowseTile }
