import { useState } from "react"
import { animated, useSpring } from "@react-spring/web"
import { Link } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import { DEFAULT_PROGRAMS_TAB } from "@/config/programs"
import { cn } from "@/lib/utils"

type ProgramsSubpageHeaderProps = {
	/** Optional page title. When omitted, only the breadcrumb renders (hero owns the H1). */
	title?: string
	className?: string
}

const HOVER_SPRING = { mass: 0.85, tension: 340, friction: 22 }

/**
 * Programs detail chrome — back to listing. Title is optional so a branded
 * hero can own the page heading.
 */
function ProgramsSubpageHeader({
	title,
	className,
}: ProgramsSubpageHeaderProps) {
	const [hovered, setHovered] = useState(false)

	const backSpring = useSpring({
		x: hovered ? -5 : 0,
		scale: hovered ? 1.04 : 1,
		config: HOVER_SPRING,
	})

	const arrowSpring = useSpring({
		x: hovered ? -3 : 0,
		config: HOVER_SPRING,
	})

	return (
		<header className={cn("shrink-0 space-y-3", className)}>
			<Link
				to="/programs"
				search={{ tab: DEFAULT_PROGRAMS_TAB }}
				className="inline-flex text-lg font-bold text-foreground hover:text-primary"
				onMouseEnter={() => setHovered(true)}
				onMouseLeave={() => setHovered(false)}
				onFocus={() => setHovered(true)}
				onBlur={() => setHovered(false)}
			>
				<animated.span
					className="inline-flex origin-left items-center gap-3 will-change-transform"
					style={{
						x: backSpring.x,
						scale: backSpring.scale,
					}}
				>
					<animated.span
						className="inline-flex will-change-transform"
						style={{ x: arrowSpring.x }}
						aria-hidden
					>
						<ArrowLeft className="size-6 shrink-0" strokeWidth={2.5} />
					</animated.span>
					Programs
				</animated.span>
			</Link>
			{title ? (
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{title}
				</h1>
			) : null}
		</header>
	)
}

export { ProgramsSubpageHeader }
