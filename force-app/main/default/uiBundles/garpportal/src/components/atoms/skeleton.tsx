import { Children, type ComponentProps, type ReactNode } from "react"
import { animated, useSpring } from "@react-spring/web"

import { cn } from "@/lib/utils"

const BONE_SPRING = { mass: 1, tension: 90, friction: 24 }

type SkeletonProps = ComponentProps<"div"> & {
	/**
	 * Nested `Skeleton` bones (or any layout). When present, this instance is a
	 * static frame — no pulse — so you can mirror real UI structure.
	 */
	children?: ReactNode
}

function SkeletonBone({
	className,
	style,
	...props
}: Omit<SkeletonProps, "children">) {
	const pulse = useSpring({
		from: { opacity: 0.4 },
		to: { opacity: 1 },
		loop: { reverse: true },
		config: BONE_SPRING,
	})

	return (
		<animated.div
			data-slot="skeleton"
			className={cn("rounded-md bg-muted-foreground/20", className)}
			style={{ ...pulse, ...style }}
			{...props}
		/>
	)
}

/**
 * Loading placeholder.
 *
 * - **Bone** (no children): pulsing bar/block — size via `className`.
 * - **Frame** (with children): static shell that holds composed bones.
 *
 * @example
 * ```tsx
 * <Skeleton className="overflow-hidden rounded-xl border bg-muted/40">
 *   <Skeleton className="h-40 w-full rounded-none" />
 *   <div className="space-y-3 p-5">
 *     <Skeleton className="h-5 w-3/5" />
 *     <Skeleton className="h-3 w-full" />
 *   </div>
 * </Skeleton>
 * ```
 */
function Skeleton({ className, style, children, ...props }: SkeletonProps) {
	if (Children.count(children) > 0) {
		return (
			<div
				data-slot="skeleton-frame"
				aria-hidden
				className={cn(className)}
				style={style}
				{...props}
			>
				{children}
			</div>
		)
	}

	return <SkeletonBone className={className} style={style} {...props} />
}

export { Skeleton }
