import { useEffect } from "react"
import { animated } from "@react-spring/web"
import { Link } from "@tanstack/react-router"

import { ExamResultCard } from "@/components/molecules/exam-result-card"
import { ExamResultsPendingSkeleton } from "@/components/molecules/page-pending"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { StatusBadge } from "@/components/molecules/status-badge"
import { programBrandSurface } from "@/config/program-brand"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { useExamResults } from "@/hooks/use-exam-results"
import { useMarkExamResultViewed } from "@/hooks/use-mark-exam-result-viewed"
import {
	buildExamResultsPagePresentation,
	examResultsRouteSlug,
} from "@/lib/exam-results-presentation"
import { cn } from "@/lib/utils"

type ExamResultsPanelProps = {
	programType: string
}

function SummaryStrip({
	summary,
}: {
	summary: ReturnType<typeof buildExamResultsPagePresentation>["summary"]
}) {
	const chips: Array<{ label: string; value: number }> = [
		{ label: "Total", value: summary.total },
		{ label: "Passed", value: summary.passed },
		{ label: "Did not pass", value: summary.failed },
		{ label: "Awaiting", value: summary.pending },
	].filter((chip) => chip.value > 0 || chip.label === "Total")

	return (
		<ul className="flex flex-wrap gap-2">
			{chips.map((chip) => (
				<li
					key={chip.label}
					className="rounded-lg bg-muted/60 px-3 py-1.5 text-sm text-foreground"
				>
					<span className="font-semibold">{chip.value}</span>{" "}
					<span className="text-muted-foreground">{chip.label}</span>
				</li>
			))}
		</ul>
	)
}

function ExamResultsPanelView({ programType }: ExamResultsPanelProps) {
	const routeSlug = examResultsRouteSlug(programType)
	const codeLabel = routeSlug.toUpperCase()
	const brand = programBrandSurface(routeSlug)
	const { data, isLoading, isError, error } = useExamResults()
	const markViewed = useMarkExamResultViewed()

	const presentation = buildExamResultsPagePresentation(
		data ?? [],
		routeSlug,
	)

	useEffect(() => {
		const released = (data ?? []).filter(
			(exam) =>
				exam.result != null &&
				presentation.results.some((row) => row.id === exam.id),
		)
		if (released.length === 0) return

		void Promise.allSettled(
			released.map((exam) => markViewed.mutateAsync(exam.id)),
		)
		// Stamp once per successful payload; mutateAsync identity is unstable.
		// eslint-disable-next-line react-hooks/exhaustive-deps -- intentional
	}, [data])

	const { style, exit } = useSubpageTransition()

	return (
		<animated.div
			style={style}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<ProgramsSubpageHeader
				onNavigateBack={exit}
				back={{
					kind: "program",
					programType: routeSlug,
					label: codeLabel,
				}}
			/>

			<div className="mt-4 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <ExamResultsPendingSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						{error instanceof Error && error.message
							? error.message
							: "We couldn't load your exam results. Please try again later."}
					</p>
				) : null}

				{!isLoading && !isError ? (
					<div className="space-y-6 pb-2">
						<section className="overflow-hidden rounded-xl border border-border">
							<div className="flex flex-col gap-5 p-5 sm:flex-row sm:items-start">
								<div
									className={cn(
										"flex h-24 w-full shrink-0 items-center justify-center rounded-xl p-3 sm:h-28 sm:w-36",
										brand.surface,
									)}
								>
									<span
										className={cn(
											"rounded-md px-2.5 py-1 text-sm font-bold tracking-wider",
											brand.chip,
										)}
									>
										{codeLabel}
									</span>
								</div>
								<div className="min-w-0 flex-1 space-y-3">
									<div className="flex flex-wrap items-center gap-2">
										<StatusBadge
											label="Exam results"
											tone="info"
										/>
									</div>
									<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
										{codeLabel} Exam Results
									</h1>
									<p className="max-w-2xl text-sm text-muted-foreground">
										Official outcomes for your{" "}
										{codeLabel} sittings — including
										quartile rankings and downloadable
										letters when they have been released.
									</p>
									<SummaryStrip
										summary={presentation.summary}
									/>
								</div>
							</div>
						</section>

						{presentation.results.length === 0 ? (
							<div className="rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
								<p className="font-heading text-lg font-semibold tracking-wide text-foreground">
									No exam results for {codeLabel} yet
								</p>
								<p className="mt-2 text-sm text-muted-foreground">
									Once you register and sit an exam for this
									program, your result will appear here after
									it is released.
								</p>
								<Link
									to="/programs/$programType"
									params={{ programType: routeSlug }}
									className="mt-4 inline-flex text-sm font-semibold text-primary hover:text-primary/80"
								>
									Back to {codeLabel} program
								</Link>
							</div>
						) : (
							<div className="space-y-4">
								{presentation.results.map((result) => (
									<ExamResultCard
										key={result.id}
										result={result}
									/>
								))}
							</div>
						)}
					</div>
				) : null}
			</div>
		</animated.div>
	)
}

function ExamResultsPanel({ programType }: ExamResultsPanelProps) {
	return (
		<ExamResultsPanelView
			key={examResultsRouteSlug(programType)}
			programType={programType}
		/>
	)
}

export { ExamResultsPanel }
