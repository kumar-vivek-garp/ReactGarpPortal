import { Link } from "@tanstack/react-router"
import { Monitor } from "lucide-react"

import { CardCta } from "@/components/molecules/card-cta"
import { useExamResults } from "@/hooks/use-exam-results"
import { buildExamResultsPreviewRows } from "@/lib/exam-results-presentation"
import { programResultsPath } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

type ExamResultsSummaryCardProps = {
	className?: string
}

/**
 * Programs listing preview — recent unique program/part rows with deep links
 * into `/programs/$programType/results` (not a single dump page).
 */
function ExamResultsSummaryCard({ className }: ExamResultsSummaryCardProps) {
	const { data, isLoading, isError } = useExamResults(true)
	const rows = buildExamResultsPreviewRows(data ?? [], 2)

	if (isError) return null
	if (!isLoading && rows.length === 0) return null

	const uniqueSlugs = [
		...new Set(rows.map((row) => row.programSlug).filter(Boolean)),
	] as string[]
	const seeAllHref =
		uniqueSlugs.length === 1
			? programResultsPath(uniqueSlugs[0])
			: null

	return (
		<section
			className={cn(
				"rounded-xl border border-border bg-muted/30 p-5 shadow-sm",
				className,
			)}
		>
			<header className="mb-4 flex items-center gap-2">
				<Monitor className="size-5 text-foreground" aria-hidden />
				<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
					Exam Results
				</h2>
			</header>

			{isLoading ? (
				<ul
					className="space-y-3"
					aria-busy
					aria-label="Loading exam results"
				>
					<li className="h-12 animate-pulse rounded-lg bg-muted" />
					<li className="h-12 animate-pulse rounded-lg bg-muted" />
				</ul>
			) : (
				<ul className="divide-y divide-border/80">
					{rows.map((row) => (
						<li key={row.id} className="py-3 first:pt-0 last:pb-0">
							{row.programSlug ? (
								<Link
									to="/programs/$programType/results"
									params={{ programType: row.programSlug }}
									className="block space-y-0.5"
								>
									<p className="text-sm font-bold text-primary">
										{row.title}
									</p>
									{row.administration ? (
										<p className="text-sm text-foreground">
											{row.administration}
										</p>
									) : null}
								</Link>
							) : (
								<div className="space-y-0.5">
									<p className="text-sm font-bold text-foreground">
										{row.title}
									</p>
									{row.administration ? (
										<p className="text-sm text-muted-foreground">
											{row.administration}
										</p>
									) : null}
								</div>
							)}
						</li>
					))}
				</ul>
			)}

			{seeAllHref ? (
				<footer className="mt-3 flex justify-end border-t border-border/60 pt-3">
					<CardCta
						label="See All"
						url={seeAllHref}
						isExternal={false}
					/>
				</footer>
			) : null}
		</section>
	)
}

export { ExamResultsSummaryCard }
