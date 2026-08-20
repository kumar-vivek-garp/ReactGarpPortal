import type { ExamResultCardPresentation } from "@/lib/exam-results-presentation"
import { StatusBadge } from "@/components/molecules/status-badge"
import { cn } from "@/lib/utils"

type ExamResultCardProps = {
	result: ExamResultCardPresentation
	className?: string
}

function QuartileBars({
	quartiles,
}: {
	quartiles: ExamResultCardPresentation["quartiles"]
}) {
	return (
		<div className="space-y-3 rounded-xl bg-muted/40 p-4">
			<div className="space-y-1">
				<p className="text-sm font-semibold text-foreground">
					Quartile rankings
				</p>
				<p className="text-xs text-muted-foreground">
					1 is the top quartile. Rankings compare your performance by
					topic against everyone who sat the same exam.
				</p>
			</div>
			<ul className="space-y-2.5">
				{quartiles.map((q) => (
					<li
						key={q.topic}
						className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm"
					>
						<span className="min-w-40 flex-1 text-foreground">
							{q.name}
						</span>
						<span
							className="flex gap-1"
							aria-label={`Quartile ${q.rank} of 4`}
						>
							{[1, 2, 3, 4].map((slot) => (
								<span
									key={slot}
									className={cn(
										"h-3 w-7 rounded-sm",
										slot === q.rank
											? "bg-primary"
											: "bg-muted-foreground/25",
									)}
								/>
							))}
						</span>
						<span className="shrink-0 text-muted-foreground">
							Q{q.rank}
						</span>
					</li>
				))}
			</ul>
		</div>
	)
}

/**
 * One attempt on the program exam-results page — outcome, message, quartiles,
 * and download links from Apex `examResults`.
 */
function ExamResultCard({ result, className }: ExamResultCardProps) {
	const badgeLabel = result.resultLabel ?? result.outcome.label

	return (
		<article
			id={`exam-result-${result.id}`}
			className={cn(
				"space-y-4 rounded-xl border border-border bg-card p-5 shadow-none",
				className,
			)}
		>
			<header className="space-y-2">
				<div className="flex flex-wrap items-center gap-2">
					<StatusBadge
						label={badgeLabel}
						tone={result.outcome.tone}
					/>
					{result.examDateLabel ? (
						<span className="text-sm text-muted-foreground">
							Exam date {result.examDateLabel}
						</span>
					) : null}
				</div>
				<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
					{result.title}
				</h2>
				{result.administration ? (
					<p className="text-sm font-medium text-primary">
						{result.administration}
					</p>
				) : null}
			</header>

			{result.message ? (
				<p className="text-sm text-foreground">{result.message}</p>
			) : null}

			{result.pendingReleaseLabel ? (
				<p className="text-sm text-muted-foreground">
					{result.pendingReleaseLabel}
				</p>
			) : null}

			{result.showQuartiles ? (
				<QuartileBars quartiles={result.quartiles} />
			) : null}

			{(result.resultsLetterHref ||
				result.performanceHref ||
				result.contactMemberServices) && (
				<footer className="flex flex-wrap items-center gap-x-4 gap-y-2 border-t border-border/60 pt-4">
					{result.resultsLetterHref ? (
						<a
							href={result.resultsLetterHref}
							target="_blank"
							rel="noreferrer noopener"
							className="text-sm font-semibold text-primary hover:text-primary/80"
						>
							Results letter
						</a>
					) : null}
					{result.performanceHref ? (
						<a
							href={result.performanceHref}
							target="_blank"
							rel="noreferrer noopener"
							className="text-sm font-semibold text-primary hover:text-primary/80"
						>
							Performance analysis
						</a>
					) : null}
					{result.contactMemberServices ? (
						<a
							href="mailto:memberservices@garp.com?Subject=Exam%20result%20query"
							className="text-sm font-semibold text-primary hover:text-primary/80"
						>
							Contact member services
						</a>
					) : null}
				</footer>
			)}
		</article>
	)
}

export { ExamResultCard }
