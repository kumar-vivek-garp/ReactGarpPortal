import { Link } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import { DEFAULT_PROGRAMS_TAB } from "@/config/programs"
import { cn } from "@/lib/utils"

type ProgramsSubpageHeaderProps = {
	title: string
	className?: string
}

/**
 * Programs detail chrome — back to listing + program title so the page
 * still reads as part of Programs.
 */
function ProgramsSubpageHeader({
	title,
	className,
}: ProgramsSubpageHeaderProps) {
	return (
		<header className={cn("shrink-0 space-y-3", className)}>
			<Link
				to="/programs"
				search={{ tab: DEFAULT_PROGRAMS_TAB }}
				className="inline-flex items-center gap-2 text-sm font-semibold text-foreground hover:text-primary"
			>
				<ArrowLeft className="size-4 shrink-0" aria-hidden />
				Programs
			</Link>
			<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
				{title}
			</h1>
		</header>
	)
}

export { ProgramsSubpageHeader }
