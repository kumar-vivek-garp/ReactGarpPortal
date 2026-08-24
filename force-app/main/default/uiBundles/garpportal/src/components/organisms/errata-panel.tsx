import { useState } from "react"
import { animated } from "@react-spring/web"
import {
	CheckCircle2,
	ExternalLink,
	TriangleAlert,
} from "lucide-react"

import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { ErrataForm } from "@/components/organisms/errata-form"
import {
	ERRATA_CHECKLIST,
	ERRATA_INTRO,
	ERRATA_NO_ACCESS,
	ERRATA_NO_OPTIONS,
	ERRATA_TITLE,
} from "@/config/errata"
import { useErrataForm, type ErrataSubmitOutcome } from "@/hooks/use-errata"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import {
	errataMaterialOptions,
	errataSheetUrl,
} from "@/lib/errata-presentation"
import { cn } from "@/lib/utils"

/** The shell every programme subpage shares — fixed height, scrolling body. */
const SUBPAGE_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
const SUBPAGE_SCROLL =
	"mt-4 min-h-0 flex-1 space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

function EmptyState({
	state,
}: {
	state: typeof ERRATA_NO_ACCESS | typeof ERRATA_NO_OPTIONS
}) {
	const Icon = state.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{state.title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{state.message}
			</p>
		</div>
	)
}

/** The published sheet, or an honest line when GARP publishes none. */
function ErrataSheet({ programType }: { programType: string }) {
	const url = errataSheetUrl(programType)
	const label = programType.toUpperCase()

	return (
		<Card className="gap-3 px-5 py-4 shadow-none">
			<div className="flex flex-wrap items-start justify-between gap-4">
				<div className="min-w-0 space-y-1">
					<h2 className="font-heading text-base font-semibold tracking-wide text-foreground">
						Check the published sheet first
					</h2>
					<p className="text-sm text-muted-foreground">
						{url
							? "Most known issues are already listed. Reporting one again slows down review."
							: `GARP does not publish a ${label} errata sheet. Report what you found below.`}
					</p>
				</div>
				{url ? (
					<Button asChild variant="outline" size="sm">
						<a href={url} target="_blank" rel="noopener noreferrer">
							<ExternalLink className="size-4" aria-hidden />
							Download {label} errata
						</a>
					</Button>
				) : null}
			</div>
		</Card>
	)
}

/** What was sent, and what to do next. Replaces the form on success. */
function ErrataReceipt({
	outcome,
	programType,
	onReset,
}: {
	outcome: ErrataSubmitOutcome
	programType: string
	onReset: () => void
}) {
	return (
		<div className="space-y-4">
			<div className="flex items-start gap-3 rounded-lg border border-border bg-muted/20 px-4 py-3">
				<CheckCircle2
					className="mt-0.5 size-5 shrink-0 text-success-green"
					aria-hidden
				/>
				<div className="space-y-1">
					<p className="text-sm font-semibold text-foreground">
						Thanks — your report has been sent
					</p>
					<p className="text-sm text-muted-foreground">
						We review every submission and publish confirmed errata, with their
						corrections, on the sheet above.
					</p>
				</div>
			</div>

			{/*
			 * The report is filed either way. An attachment failure is a warning,
			 * never an error — telling the member the submission failed would
			 * invite a retry and file a duplicate.
			 */}
			{outcome.attachmentError ? (
				<p className="flex items-start gap-2 rounded-lg border border-border bg-muted/20 px-4 py-3 text-sm text-garp-saffron">
					<TriangleAlert className="mt-0.5 size-4 shrink-0" aria-hidden />
					<span>
						Your report was filed, but the file didn&apos;t upload —{" "}
						{outcome.attachmentError} You can email it to Member Services
						quoting your report.
					</span>
				</p>
			) : null}

			<div className="flex flex-wrap gap-2">
				<Button type="button" variant="outline" onClick={onReset}>
					Report another error
				</Button>
				<Button asChild>
					<a href={`/programs/${programType.toLowerCase()}`}>
						Back to {programType.toUpperCase()}
					</a>
				</Button>
			</div>
		</div>
	)
}

type ErrataPanelProps = {
	programType: string
	className?: string
}

/**
 * Curriculum errata for one programme.
 *
 * Three legacy defects are deliberately not reproduced: its failure message
 * was set but never rendered, so a failed submission looked like nothing
 * happened; Submit then stayed on "Submitting…" forever; and its Back button
 * had no href and no handler.
 */
function ErrataPanel({ programType, className }: ErrataPanelProps) {
	const { style, exit } = useSubpageTransition()
	const [outcome, setOutcome] = useState<ErrataSubmitOutcome | null>(null)

	const { data, isLoading, isError } = useErrataForm(programType)
	const hasOptions = errataMaterialOptions(data).length > 0

	const header = (
		<ProgramsSubpageHeader
			back={{ kind: "program", programType, label: programType.toUpperCase() }}
			title={ERRATA_TITLE}
			onNavigateBack={exit}
		/>
	)

	return (
		<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
			{header}

			<div className={SUBPAGE_SCROLL}>
				{isLoading ? (
					<div className="space-y-4" aria-busy>
						<Skeleton className="h-20 w-full rounded-xl" />
						{Array.from({ length: 4 }).map((_, index) => (
							<div key={index} className="space-y-1.5">
								<Skeleton className="h-4 w-56" />
								<Skeleton className="h-9 w-full rounded-xl" />
							</div>
						))}
					</div>
				) : null}

				{!isLoading && isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load the errata form. Please try again later.
					</p>
				) : null}

				{/* Apex answers 403 for a member with no entitling programme; that is
				    a business answer, which `fetchErrataForm` turns into null. */}
				{!isLoading && !isError && data === null ? (
					<EmptyState state={ERRATA_NO_ACCESS} />
				) : null}

				{!isLoading && !isError && data ? (
					<>
						<ErrataSheet programType={programType} />

						{outcome ? (
							<ErrataReceipt
								outcome={outcome}
								programType={programType}
								onReset={() => setOutcome(null)}
							/>
						) : hasOptions ? (
							<div className="space-y-5">
								<section className="space-y-2">
									<h2 className="font-heading text-lg font-semibold tracking-wide text-foreground">
										Report an error
									</h2>
									<p className="text-sm text-muted-foreground">
										{ERRATA_INTRO}
									</p>
									<ul className="list-disc space-y-1 ps-5 text-sm text-muted-foreground">
										{ERRATA_CHECKLIST.map((item) => (
											<li key={item}>{item}</li>
										))}
									</ul>
								</section>

								{/* Remount after a reset so the form clears rather than
								    keeping the previous report's values. */}
								<ErrataForm
									key={outcome ? "sent" : "new"}
									programType={programType}
									view={data}
									onSubmitted={setOutcome}
								/>
							</div>
						) : (
							<EmptyState state={ERRATA_NO_OPTIONS} />
						)}
					</>
				) : null}
			</div>
		</animated.div>
	)
}

export { ErrataPanel }
