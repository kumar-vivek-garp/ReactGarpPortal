import { animated, useSpring } from "@react-spring/web"

import { cn } from "@/lib/utils"

type MainLoadingBarProps = {
	visible: boolean
	className?: string
}

/**
 * Indeterminate line under the navbar, scoped to the main column (not the sidebar).
 */
function MainLoadingBar({ visible, className }: MainLoadingBarProps) {
	const bar = useSpring({
		from: { x: "-40%" },
		to: { x: "100%" },
		loop: true,
		pause: !visible,
		config: { duration: 1100 },
		reset: visible,
	})

	if (!visible) return null

	return (
		<div
			className={cn("relative h-0.5 w-full shrink-0 overflow-hidden bg-border/60", className)}
			role="progressbar"
			aria-valuetext="Loading"
			aria-busy="true"
		>
			<animated.div
				className="absolute inset-y-0 w-2/5 bg-primary"
				style={{
					transform: bar.x.to((x) => `translateX(${x})`),
				}}
			/>
		</div>
	)
}

export { MainLoadingBar }
