import type { MouseEvent } from "react"
import { Link, useNavigate } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import { SpringNudge } from "@/components/atoms/spring-nudge"
import { DEFAULT_STUDY_MATERIALS_TAB } from "@/config/study-materials"
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
	/** Any other in-app parent — study materials, CPD, and so on. */
	| { kind: "studyMaterials"; label?: string }

type ProgramsSubpageHeaderProps = {
	/** Optional page title. When omitted, only the breadcrumb renders (hero owns the H1). */
	title?: string
	className?: string
	/**
	 * Back target. Defaults to the programs listing. Program-scoped subpages
	 * (exam results) pass `kind: "program"` so the member returns to detail.
	 */
	back?: ProgramsSubpageBack
	/**
	 * Intercepts the back link so the page can play its exit before the route
	 * changes. Receives the navigation to run once the animation settles.
	 */
	onNavigateBack?: (run: () => void) => void
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
	onNavigateBack,
}: ProgramsSubpageHeaderProps) {
	const nudge = useSpringNudge({ direction: "backward" })
	const navigate = useNavigate()

	/*
	 * Kept as a real `Link` so the href, middle-click and open-in-new-tab all
	 * behave — only a plain left click is intercepted, and only when the page
	 * has an exit animation to play.
	 */
	const interceptBack = (
		event: MouseEvent<HTMLAnchorElement>,
		to: () => void,
	) => {
		if (!onNavigateBack) return
		if (event.defaultPrevented) return
		if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return
		if (event.button !== 0) return
		event.preventDefault()
		onNavigateBack(to)
	}

	const backLabel =
		back.kind === "program"
			? (back.label?.trim() ||
					back.programType.trim().toUpperCase() ||
					"Program")
			: back.kind === "studyMaterials"
				? back.label?.trim() || "Study Materials"
				: "Programs"

	return (
		<header className={cn("shrink-0 space-y-3", className)}>
			{back.kind === "program" ? (
				<Link
					to="/programs/$programType"
					params={{ programType: back.programType }}
					className="inline-flex text-lg font-bold text-foreground hover:text-primary"
					onClick={(event) =>
						interceptBack(event, () => {
							void navigate({
								to: "/programs/$programType",
								params: {
									programType:
										back.kind === "program" ? back.programType : "",
								},
							})
						})
					}
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
			) : back.kind === "studyMaterials" ? (
				<Link
					to="/study-materials"
					// The listing requires a tab; going back lands on its default
					// rather than on whatever the member last filtered to.
					search={{ tab: DEFAULT_STUDY_MATERIALS_TAB }}
					className="inline-flex text-lg font-bold text-foreground hover:text-primary"
					onClick={(event) =>
						interceptBack(event, () => {
							void navigate({
								to: "/study-materials",
								search: { tab: DEFAULT_STUDY_MATERIALS_TAB },
							})
						})
					}
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
					onClick={(event) =>
						interceptBack(event, () => {
							void navigate({ to: "/programs" })
						})
					}
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
