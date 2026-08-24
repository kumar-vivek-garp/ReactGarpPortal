import type { ReactNode } from "react"
import { animated, useSpring } from "@react-spring/web"
import { Check, ChevronDown } from "lucide-react"

import { cn } from "@/lib/utils"

const REVEAL_SPRING = { mass: 0.9, tension: 300, friction: 30 }

export type CvStepStatus = "complete" | "current" | "upcoming"

const BADGE_CLASS: Record<CvStepStatus, string> = {
	// Same status vocabulary as `program-journey`, so a step reads the same
	// way here as it does on the programme timeline.
	complete: "bg-success-green/15 text-success-green",
	current: "bg-primary/15 text-primary",
	upcoming: "bg-muted text-muted-foreground",
}

type CvStepSectionProps = {
	step: number
	title: string
	description?: string
	status: CvStepStatus
	/** One-line summary shown in place of the body once satisfied. */
	summary?: string | null
	/** False collapses the body to its summary. */
	open: boolean
	/**
	 * Makes the header a disclosure control. Omit for a section that is always
	 * shown — step 1 has nowhere useful to collapse to.
	 */
	onOpenChange?: (open: boolean) => void
	/** Last step draws no connector below its badge. */
	isLast?: boolean
	children: ReactNode
	className?: string
}

/**
 * One numbered section of the submission page.
 *
 * A step rail rather than a wizard: every section stays on the page, so
 * nothing is hidden behind navigation and there is never anything to go Back
 * to. Completed sections collapse to a summary line to keep the page short.
 */
function CvStepSection({
	step,
	title,
	description,
	status,
	summary,
	open,
	onOpenChange,
	isLast = false,
	children,
	className,
}: CvStepSectionProps) {
	const body = useSpring({
		opacity: open ? 1 : 0,
		maxHeight: open ? 4000 : 0,
		config: REVEAL_SPRING,
	})
	const chevron = useSpring({
		transform: open ? "rotate(180deg)" : "rotate(0deg)",
		config: REVEAL_SPRING,
	})

	const heading = (
		<>
			<h2 className="font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</h2>
			{summary ? (
				<p className="text-sm text-muted-foreground">{summary}</p>
			) : null}
		</>
	)

	return (
		<section className={cn("relative flex gap-4", className)}>
			<div className="flex flex-col items-center">
				<span
					className={cn(
						"flex size-9 shrink-0 items-center justify-center rounded-full text-sm font-bold",
						BADGE_CLASS[status],
					)}
					aria-hidden
				>
					{status === "complete" ? <Check className="size-4" /> : step}
				</span>
				{!isLast ? (
					<span className="mt-1 w-px flex-1 bg-border" aria-hidden />
				) : null}
			</div>

			<div className={cn("min-w-0 flex-1", isLast ? "pb-0" : "pb-8")}>
				{onOpenChange ? (
					<button
						type="button"
						onClick={() => onOpenChange(!open)}
						aria-expanded={open}
						className="flex w-full flex-wrap items-baseline justify-between gap-x-4 gap-y-1 text-left"
					>
						{heading}
						<animated.span style={chevron} className="ml-auto" aria-hidden>
							<ChevronDown className="size-4 text-muted-foreground" />
						</animated.span>
					</button>
				) : (
					<header className="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
						{heading}
					</header>
				)}

				{description && open ? (
					<p className="mt-1 text-sm text-muted-foreground">{description}</p>
				) : null}

				<animated.div className="overflow-hidden" style={body}>
					<div className="pt-4">{children}</div>
				</animated.div>
			</div>
		</section>
	)
}

export { CvStepSection }
