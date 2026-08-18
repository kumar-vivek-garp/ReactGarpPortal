import { Link } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import { SpringNudge } from "@/components/atoms/spring-nudge"
import { useSpringNudge } from "@/hooks/use-spring-nudge"
import { cn } from "@/lib/utils"

type ProgramsSubpageHeaderProps = {
	/** Optional page title. When omitted, only the breadcrumb renders (hero owns the H1). */
	title?: string
	className?: string
}

/**
 * Programs detail chrome — back to listing. Title is optional so a branded
 * hero can own the page heading.
 *
 * No `search` on the back link: the listing resolves the right tab itself, so
 * returning from a program lands on the bucket that program belongs to.
 */
function ProgramsSubpageHeader({
	title,
	className,
}: ProgramsSubpageHeaderProps) {
	const nudge = useSpringNudge({ direction: "backward" })

	return (
		<header className={cn("shrink-0 space-y-3", className)}>
			<Link
				to="/programs"
				className="inline-flex text-lg font-bold text-foreground hover:text-primary"
				{...nudge.bind}
			>
				<SpringNudge
					nudge={nudge}
					icon={<ArrowLeft className="size-6" strokeWidth={2.5} />}
					iconPosition="leading"
					className="gap-3"
				>
					Programs
				</SpringNudge>
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
