import { animated } from "@react-spring/web"
import { GripVertical } from "lucide-react"

import { useSpringPress } from "@/hooks/use-spring-press"
import type { BentoHandleProps } from "@/hooks/use-bento-layout"
import { chainHandlers } from "@/lib/chain-handlers"
import { cn } from "@/lib/utils"

type BentoDragHandleProps = {
	handleProps: BentoHandleProps
	className?: string
}

/**
 * The only place a bento card can be dragged from.
 *
 * A dedicated grip rather than the whole card, because these cards are full of
 * live controls — selects, checkboxes, dialogs, links — and a card-wide gesture
 * would fight every one of them.
 *
 * `touch-none` is scoped to this button alone: the card body must keep scrolling
 * normally on a phone, and only this 24px target opts out of that.
 */
function BentoDragHandle({ handleProps, className }: BentoDragHandleProps) {
	const { bind, style } = useSpringPress<HTMLButtonElement>()
	const lifted = handleProps["data-lifted"]

	// Chained, never spread: `useSpringPress` and `@use-gesture` both bind the
	// same pointer events, and a spread would silently drop one of them — in a
	// browser that is `onPointerDown`, i.e. the drag itself.
	const bound = chainHandlers(handleProps, bind)

	return (
		<animated.button
			{...bound}
			style={style}
			className={cn(
				"flex size-7 shrink-0 cursor-grab touch-none items-center justify-center rounded-md text-muted-foreground",
				"hover:bg-accent hover:text-accent-foreground",
				"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
				lifted && "cursor-grabbing bg-accent text-accent-foreground",
				className,
			)}
		>
			<GripVertical className="size-4" aria-hidden />
		</animated.button>
	)
}

export { BentoDragHandle }
