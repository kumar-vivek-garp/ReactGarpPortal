import { Children, type ReactNode } from "react"
import { animated, useTrail } from "@react-spring/web"

import { cn } from "@/lib/utils"

/** Snappy trail — cards cascade left→right / top→bottom in DOM/grid order. */
const TRAIL_SPRING = { mass: 0.8, tension: 340, friction: 26 }

type StaggerRevealProps = {
	children: ReactNode
	className?: string
	/** Applied to each trailed wrapper (e.g. `h-full` so grid cards stretch). */
	itemClassName?: string
	/** Per-index override / extra classes for a grid item (e.g. `sm:row-span-2`). */
	getItemClassName?: (index: number) => string | undefined
}

/**
 * Reveals direct children one-by-one with `@react-spring/web` `useTrail`.
 * In a CSS grid, DOM order is top-left → right → next row.
 */
function StaggerReveal({
	children,
	className,
	itemClassName,
	getItemClassName,
}: StaggerRevealProps) {
	const items = Children.toArray(children).filter(Boolean)
	const trails = useTrail(items.length, {
		from: { opacity: 0, transform: "translateY(14px)" },
		to: { opacity: 1, transform: "translateY(0px)" },
		config: TRAIL_SPRING,
	})

	return (
		<div className={className}>
			{trails.map((style, index) => (
				<animated.div
					key={index}
					style={style}
					className={cn("min-w-0", itemClassName, getItemClassName?.(index))}
				>
					{items[index]}
				</animated.div>
			))}
		</div>
	)
}

export { StaggerReveal }
