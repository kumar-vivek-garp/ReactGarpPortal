import {
	Award,
	Building2,
	CalendarDays,
	CreditCard,
	ExternalLink,
	MapPin,
	Monitor,
	OctagonAlert,
	SquarePen,
} from "lucide-react"

import { Link } from "@tanstack/react-router"

import type { ExamPartInfo, ProgramDetail } from "@/api/programs"
import {
	Alert,
	AlertDescription,
	AlertTitle,
} from "@/components/atoms/alert"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { CardCta } from "@/components/molecules/card-cta"
import { programExamSetupHref } from "@/lib/program-card-links"
import {
	examPartTitle,
	partActions,
} from "@/lib/program-detail-presentation"
import {
	canEditPart,
	isPartBlocked,
	partAdministration,
	partFacts,
	partMessages,
	TAKE_EXAM_NOTE,
	unpaidChangeMessage,
	type PartFact,
	type PartFactIcon,
} from "@/lib/program-part-presentation"
import { cn } from "@/lib/utils"

type ProgramExamOverviewProps = {
	detail: ProgramDetail
	part: ExamPartInfo
	partIndex: 1 | 2
	className?: string
}

const FACT_ICON: Record<PartFactIcon, typeof Monitor> = {
	format: Monitor,
	provider: Building2,
	date: CalendarDays,
	site: MapPin,
	payment: CreditCard,
	results: Award,
}

function Fact({ fact }: { fact: PartFact }) {
	const Icon = FACT_ICON[fact.icon]
	const display = fact.value?.trim()
	return (
		<div className="flex gap-3 rounded-xl border border-border/60 bg-background/60 p-3">
			<span className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-muted text-primary">
				<Icon className="size-4" aria-hidden />
			</span>
			<div className="min-w-0">
				<p className="text-xs font-medium text-muted-foreground">{fact.label}</p>
				{display && fact.href ? (
					<a
						href={fact.href}
						target="_blank"
						rel="noreferrer noopener"
						className="mt-0.5 inline-flex items-center gap-1 text-sm font-semibold text-primary hover:text-primary/80"
					>
						{display}
						<ExternalLink className="size-3.5" aria-hidden />
					</a>
				) : (
					<p
						className={cn(
							"mt-0.5 text-sm",
							display ? "text-foreground" : "text-muted-foreground italic",
						)}
					>
						{display || fact.emptyLabel}
					</p>
				)}
			</div>
		</div>
	)
}

/**
 * One exam part. Everything it shows is decided in
 * `program-part-presentation` / `program-detail-presentation`; this only
 * lays it out.
 */
function ProgramExamOverview({
	detail,
	part,
	partIndex,
	className,
}: ProgramExamOverviewProps) {
	if (part.isResultStale === true) return null

	const title = examPartTitle(detail, partIndex)
	const setupHref = programExamSetupHref(detail.programType ?? "")
	const blocked = isPartBlocked(part)
	const messages = partMessages(part, detail)
	const facts = partFacts(part, detail).filter(
		(fact) => fact.value?.trim() || fact.emptyLabel,
	)
	const actions = partActions(part, detail)
	const offersTakeExam = actions.some((action) => action.kind === "takeExam")

	return (
		<AccountSectionCard
			title={title}
			subtitle={partAdministration(part) ?? undefined}
			className={className}
			action={
				canEditPart(part) && setupHref ? (
					// A route, so `Link` — a raw anchor would full-page reload the
					// bundle to reach a page we already have mounted.
					<Link
						to={setupHref}
						className="inline-flex items-center gap-1.5 text-sm font-semibold leading-none text-primary hover:text-primary/80"
					>
						Edit
						<SquarePen className="size-3.5 shrink-0" aria-hidden />
					</Link>
				) : undefined
			}
		>
			{blocked ? (
				<Alert variant="destructive">
					<OctagonAlert aria-hidden />
					<AlertTitle>You have an unpaid exam change</AlertTitle>
					<AlertDescription>{unpaidChangeMessage(part)}</AlertDescription>
				</Alert>
			) : null}

			{messages.length > 0 ? (
				<div className="space-y-1">
					{messages.map((message) => (
						<p key={message} className="text-sm text-foreground">
							{message}
						</p>
					))}
				</div>
			) : null}

			{facts.length > 0 ? (
				<div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
					{facts.map((fact) => (
						<Fact key={fact.label} fact={fact} />
					))}
				</div>
			) : null}

			{actions.length > 0 ? (
				<div className="mt-auto space-y-2 border-t border-border/60 pt-4">
					<div className="flex flex-wrap gap-x-6 gap-y-2">
						{actions.map((action) => (
							<CardCta
								key={`${action.kind}-${action.label}`}
								label={action.label}
								url={action.url}
								isExternal={action.isExternal}
								newWindow={action.newWindow}
							/>
						))}
					</div>
					{offersTakeExam ? (
						<p className="text-xs text-muted-foreground">{TAKE_EXAM_NOTE}</p>
					) : null}
				</div>
			) : null}
		</AccountSectionCard>
	)
}

export { ProgramExamOverview }
