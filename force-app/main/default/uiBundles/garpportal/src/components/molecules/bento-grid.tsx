import { useMemo, type ReactNode } from "react"
import { animated, to } from "@react-spring/web"

import { BentoDragHandle } from "@/components/molecules/bento-drag-handle"
import type { BentoScope } from "@/config/bento"
import {
	BENTO_INSTRUCTIONS_ID,
	useBentoLayout,
	type BentoCardSpring,
	type BentoRenderItem,
} from "@/hooks/use-bento-layout"
import { cn } from "@/lib/utils"

type BentoGridProps = {
	/** Which page's arrangement to remember. */
	scope: BentoScope
	/**
	 * Cards in their code-defined default order — both the base for
	 * reconciliation and the identity axis the springs are allocated along.
	 */
	items: readonly BentoRenderItem[]
	/** Extra classes for the column container. */
	className?: string
	/** Stagger the first paint. Defaults to true. */
	reveal?: boolean
}

/**
 * Never interpolated: a fractional z-index paints unpredictably, and a rising
 * card would flicker through each neighbour on the way up.
 */
const DEPTH_CLASS = {
	lifted: "z-20 will-change-transform",
	settling: "z-10",
	resting: "z-0",
} as const

type BentoDepth = keyof typeof DEPTH_CLASS

const shadowCss = (value: number) =>
	`0 ${value * 18}px ${value * 38}px -${value * 12}px rgb(0 0 0 / ${value * 0.28})`

type BentoCardProps = {
	spring: BentoCardSpring
	depth: BentoDepth
	register: (node: HTMLElement | null) => void
	children: ReactNode
}

function BentoCard({ spring, depth, register, children }: BentoCardProps) {
	// `spring.shadow` is a stable `SpringValue` across renders — only the wrapper
	// object `useSprings` returns is fresh — so this interpolation is allocated
	// once per card per mount rather than once per render, and a drag produces a
	// great many renders.
	const boxShadow = useMemo(() => to(spring.shadow, shadowCss), [spring.shadow])

	return (
		<animated.div
			ref={register}
			// Kills the browser's native text/image drag, which would otherwise start
			// its own ghost image mid-gesture.
			onDragStart={(event) => event.preventDefault()}
			style={{
				x: spring.x,
				y: spring.y,
				scale: spring.scale,
				opacity: spring.opacity,
				boxShadow,
			}}
			className={cn("relative min-w-0", DEPTH_CLASS[depth])}
		>
			{children}
		</animated.div>
	)
}

/**
 * A drag-arrangeable card grid that remembers its layout.
 *
 * Masonry, not a row grid: each column is an independent stack, so cards keep
 * their natural height and a short card simply lets the next one start higher.
 * There are no rows, so there is no ragged whitespace to tune away — and the
 * drag becomes two one-dimensional questions rather than a two-dimensional
 * hit-test against a layout that reflows while you are aiming at it.
 *
 * Deliberately generic: it knows about ids and labels, and nothing about what
 * any card contains.
 */
function BentoGrid({ scope, items, className, reveal = true }: BentoGridProps) {
	const {
		containerRef,
		columns,
		springFor,
		registerItem,
		registerColumn,
		getHandleProps,
		ghostStyle,
		liftedId,
		settlingId,
		announcement,
	} = useBentoLayout({ scope, items, reveal })

	const itemById = new Map(items.map((item) => [item.id, item]))

	return (
		<>
			<p id={BENTO_INSTRUCTIONS_ID} className="sr-only">
				Press Space or Enter on a card&apos;s reorder button to pick it up, then
				use the arrow keys to move it between columns and positions, Space to
				drop it, or Escape to cancel.
			</p>
			<span className="sr-only" role="status" aria-live="polite" aria-atomic>
				{announcement}
			</span>

			{/* `relative` is load-bearing: every card's offsets are measured against
          this element, and the landing-slot ghost is positioned inside it. */}
			<div
				ref={containerRef}
				className={cn("relative flex items-start gap-6", className)}
			>
				<animated.span
					aria-hidden
					className="pointer-events-none absolute top-0 left-0 rounded-xl border-2 border-dashed border-primary/40 bg-primary/5"
					style={ghostStyle}
				/>

				{columns.map((column, columnIndex) => (
					<div
						key={columnIndex}
						ref={(node) => registerColumn(columnIndex, node)}
						className="flex min-w-0 flex-1 flex-col gap-6"
					>
						{column.map((id) => {
							const item = itemById.get(id)
							const spring = springFor(id)
							if (!item || !spring) return null
							return (
								<BentoCard
									key={id}
									spring={spring}
									depth={
										id === liftedId
											? "lifted"
											: id === settlingId
												? "settling"
												: "resting"
									}
									register={(node) => registerItem(id, node)}
								>
									{item.render({ handleProps: getHandleProps(id) })}
								</BentoCard>
							)
						})}
					</div>
				))}
			</div>
		</>
	)
}

export { BentoGrid, BentoDragHandle }
export type { BentoGridProps }
