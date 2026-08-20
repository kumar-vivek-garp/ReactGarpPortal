import { Link } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import { SpringNudge } from "@/components/atoms/spring-nudge"
import { useSpringNudge } from "@/hooks/use-spring-nudge"
import { cn } from "@/lib/utils"

type ProgramsSubpageBack =
	| { kind: "programs" }
	| {
			kind: "program"
			programType: string
			/** Visible back label — defaults to uppercased program type. */
			label?: string
	  }

type ProgramsSubpageHeaderProps = {
	/** Optional page title. When omitted, only the breadcrumb renders (hero owns the H1). */
	title?: string
	className?: string
	/**
	 * Back target. Defaults to the programs listing. Program-scoped subpages
	 * (exam results) pass `kind: "program"` so the member returns to detail.
	 */
	back?: ProgramsSubpageBack
}

/**
 * Programs detail chrome — back link + optional title so a branded hero can
 * own the page heading.
 *
 * Listing back has no `search`: the listing resolves the right tab itself.
 */
function ProgramsSubpageHeader({
	title,
	className,
	back = { kind: "programs" },
}: ProgramsSubpageHeaderProps) {
	const nudge = useSpringNudge({ direction: "backward" })

	const backLabel =
		back.kind === "program"
			? (back.label?.trim() ||
					back.programType.trim().toUpperCase() ||
					"Program")
			: "Programs"

	return (
		<header className={cn("shrink-0 space-y-3", className)}>
			{back.kind === "program" ? (
				<Link
					to="/programs/$programType"
					params={{ programType: back.programType }}
					className="inline-flex text-lg font-bold text-foreground hover:text-primary"
					{...nudge.bind}
				>
					<SpringNudge
						nudge={nudge}
						icon={<ArrowLeft className="size-6" strokeWidth={2.5} />}
						iconPosition="leading"
						className="gap-3"
					>
						{backLabel}
					</SpringNudge>
				</Link>
			) : (
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
			)}
			{title ? (
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{title}
				</h1>
			) : null}
		</header>
	)
}

export { ProgramsSubpageHeader }
