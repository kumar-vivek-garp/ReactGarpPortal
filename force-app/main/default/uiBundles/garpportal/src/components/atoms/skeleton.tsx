import type { ComponentProps } from "react"
import { animated, useSpring } from "@react-spring/web"

import { cn } from "@/lib/utils"

function Skeleton({ className, style, ...props }: ComponentProps<"div">) {
	const pulse = useSpring({
		from: { opacity: 0.4 },
		to: { opacity: 1 },
		loop: { reverse: true },
		config: { mass: 1, tension: 90, friction: 24 },
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

export { Skeleton }
