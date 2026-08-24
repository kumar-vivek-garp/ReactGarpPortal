import {
	CalendarDays,
	MapPin,
	Monitor,
	SquarePen,
} from "lucide-react"

import { Link } from "@tanstack/react-router"

import type { ExamPartInfo, ProgramDetail } from "@/api/programs"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { CardCta } from "@/components/molecules/card-cta"
import { formatDateTime, formatLongDate } from "@/lib/account-format"
import {
	programExamSetupHref,
	programOrderHref,
	programRegistrationHref,
	resolveExperienceHref,
} from "@/lib/program-card-links"
import {
	examPartTitle,
	resultCopy,
} from "@/lib/program-detail-presentation"
import { cn } from "@/lib/utils"

type ProgramExamOverviewProps = {
	detail: ProgramDetail
	part: ExamPartInfo
	partIndex: 1 | 2
	className?: string
}

function Fact({
	icon: Icon,
	label,
	value,
	emptyLabel,
}: {
	icon: typeof Monitor
	label: string
	value: string | null | undefined
	emptyLabel: string
}) {
	const display = value?.trim()
	return (
		<div className="flex gap-3 rounded-xl border border-border/60 bg-background/60 p-3">
			<span className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-muted text-primary">
				<Icon className="size-4" aria-hidden />
			</span>
			<div className="min-w-0">
				<p className="text-xs font-medium text-muted-foreground">{label}</p>
				<p
					className={cn(
						"mt-0.5 text-sm",
						display ? "text-foreground" : "text-muted-foreground italic",
					)}
				>
					{display || emptyLabel}
				</p>
			</div>
		</div>
	)
}

function partMessage(part: ExamPartInfo): string | null {
	switch (part.examPartState) {
		case "Unpaid":
			return part.unpaidOrderPayByDate
				? `Payment due by ${formatLongDate(part.unpaidOrderPayByDate.slice(0, 10))}.`
				: "Your registration is not yet paid."
		case "Deferred":
			return [
				`Deferred${part.deferredAdminName ? ` to ${part.deferredAdminName}` : ""}.`,
				part.deferredExamSetupOpenDate
					? `Setup opens ${formatLongDate(part.deferredExamSetupOpenDate.slice(0, 10))}.`
					: null,
			]
				.filter(Boolean)
				.join(" ")
		case "AwaitingSchedulingToOpen":
			return `Exam setup opens ${formatLongDate(part.schedulingAwaitingToOpenOpenDate?.slice(0, 10)) ?? "soon"}.`
		case "SchedulingOpen":
			return part.schedulingIsComplete
				? "Your exam is scheduled."
				: part.schedulingDeadline
					? `Schedule before ${formatLongDate(part.schedulingDeadline.slice(0, 10))}.`
					: "Exam setup is open."
		case "SchedulingClosedNeverScheduled":
			return "Your registration expired before a sitting was scheduled."
		case "SchedulingClosedAwaitingToTakeExam":
			return "You are scheduled to sit this exam."
		case "SchedulingClosedAwaitingResults":
			return (
				part.resultsAvailableStatement?.trim() ||
				"Your exam results are being prepared."
			)
		case "SchedulingClosedResultsAvailable":
			return resultCopy(part.result)
		default:
			return null
	}
}

function ProgramExamOverview({
	detail,
	part,
	partIndex,
	className,
}: ProgramExamOverviewProps) {
	if (part.isResultStale === true) return null

	const title = examPartTitle(detail, partIndex)
	const setupHref = programExamSetupHref(detail.programType ?? "")
	const canEdit =
		part.isSchedulingOpen === true || part.isDeferralOpen === true
	const examWhen = formatDateTime(part.schedulingExamDateTimeSelected)
	const examWhenDisplay =
		examWhen && part.schedulingExamDateTimeZoneSelected?.trim()
			? `${examWhen} (${part.schedulingExamDateTimeZoneSelected.trim()})`
			: examWhen
	const message = partMessage(part)

	const secondary: Array<{
		label: string
		url: string
		newWindow?: boolean
		isExternal?: boolean
	}> = []
	const orderUrl = programOrderHref(part.unpaidOrderId)
	if (part.examPartState === "Unpaid" && orderUrl) {
		secondary.push({
			label: "View Order",
			url: orderUrl,
			isExternal: false,
		})
	}
	if (
		part.examPartState === "SchedulingClosedNeverScheduled" &&
		detail.currentRegistrationIsOpen === true
	) {
		const reg = programRegistrationHref(
			detail.programInformation?.registrationPath,
			detail.programType ?? "",
			false,
		)
		if (reg) secondary.push({ label: "Register Again", url: reg })
	}
	const badge = resolveExperienceHref(part.badgePageURL ?? part.badgeURL)
	if (badge) {
		secondary.push({ label: "Digital Badge", url: badge, newWindow: true })
	}
	const take =
		part.showTakeExam === true
			? resolveExperienceHref(part.schedulingExamAccessURL)
			: null
	if (take) {
		secondary.push({ label: "Take Exam", url: take, newWindow: true })
	}

	return (
		<AccountSectionCard
			title={title}
			subtitle={part.examAttemptAdminName?.trim() || undefined}
			className={className}
			action={
				canEdit && setupHref ? (
					// A route now, so `Link` — a raw anchor would full-page reload
					// the bundle to reach a page we already have mounted.
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
			{message ? (
				<p className="text-sm text-foreground">{message}</p>
			) : null}

			<div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
				<Fact
					icon={Monitor}
					label="Exam format"
					value={part.examFormat}
					emptyLabel="Not available"
				/>
				<Fact
					icon={Monitor}
					label="Exam provider"
					value={part.schedulingExamProviderName}
					emptyLabel="Not assigned"
				/>
				<Fact
					icon={CalendarDays}
					label="Exam date"
					value={examWhenDisplay}
					emptyLabel="Not scheduled"
				/>
				<Fact
					icon={MapPin}
					label="Exam site"
					value={part.schedulingExamLocationSelected}
					emptyLabel="Not selected"
				/>
			</div>

			{secondary.length > 0 ? (
				<div className="mt-auto flex flex-wrap gap-x-6 gap-y-2 border-t border-border/60 pt-4">
					{secondary.map((item) => (
						<CardCta
							key={item.label}
							label={item.label}
							url={item.url}
							isExternal={item.isExternal ?? true}
							newWindow={item.newWindow}
						/>
					))}
				</div>
			) : null}
		</AccountSectionCard>
	)
}

export { ProgramExamOverview }
