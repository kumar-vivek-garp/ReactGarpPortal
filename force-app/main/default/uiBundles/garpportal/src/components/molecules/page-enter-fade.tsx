import type { ReactNode } from "react"
import { animated, useSpring } from "@react-spring/web"

import { cn } from "@/lib/utils"

type PageEnterFadeProps = {
	children: ReactNode
	className?: string
}

/**
 * Fade real route UI in after the eager pending/boot shell.
 * CSS fade is the reliable baseline; react-spring layers on when the layout chunk is present.
 */
function PageEnterFade({ children, className }: PageEnterFadeProps) {
	const styles = useSpring({
		from: { opacity: 0 },
		to: { opacity: 1 },
		// Slightly slower so the enter is perceptible after a splash swap.
		config: { mass: 1, tension: 140, friction: 26 },
	})

	return (
		<animated.div
			className={cn("page-enter-fade", className)}
			style={styles}
		>
			{children}
		</animated.div>
	)
}

export { PageEnterFade }
