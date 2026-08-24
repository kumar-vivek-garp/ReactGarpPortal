import { CalendarCheck, CircleCheck, Clock } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { CardCta } from "@/components/molecules/card-cta"
import { EXAM_SETUP_OUTCOMES } from "@/config/exam-setup"
import type { ExamSetupAuthorizeState } from "@/hooks/use-exam-setup"
import { cn } from "@/lib/utils"

type ExamSetupOutcomeProps = {
	/** `complete` needs no provider; `scheduling` does. */
	kind: "complete" | "scheduling"
	authorize: ExamSetupAuthorizeState
	myGarpHref: string | null
	onStartOver: () => void
	className?: string
}

function OutcomeShell({
	icon: Icon,
	title,
	message,
	children,
	className,
}: {
	icon: typeof CircleCheck
	title: string
	message: string
	children?: React.ReactNode
	className?: string
}) {
	return (
		<div
			className={cn(
				"flex flex-col items-center rounded-xl border border-border bg-muted/20 px-6 py-12 text-center",
				className,
			)}
		>
			<Icon className="size-10 text-primary" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">{message}</p>
			{children ? (
				<div className="mt-5 flex flex-wrap items-center justify-center gap-3">
					{children}
				</div>
			) : null}
		</div>
	)
}

/**
 * What the member sees once the save lands.
 *
 * `complete` is the whole story for a change that needed neither payment nor a
 * provider. `scheduling` is the one that matters — it is the alert bar's
 * "Scheduling Incomplete" case, and the seat is not booked until the member
 * follows the provider link.
 *
 * Four states hang off that second case, because the provider is a third party
 * and can be slow or unreachable:
 *
 *   disabled    `EXAM_SETUP_AUTHORIZE_ENABLED` is off. Nothing is called and
 *               the member finishes in MyGarp. This is today's default.
 *   authorized  the provider answered with scheduling links.
 *   pending     it answered "unprocessed" — offer another attempt.
 *   exhausted   it kept saying that. Stop asking and hand off, rather than
 *               polling a vendor integration indefinitely.
 */
function ExamSetupOutcome({
	kind,
	authorize,
	myGarpHref,
	onStartOver,
	className,
}: ExamSetupOutcomeProps) {
	if (kind === "complete") {
		return (
			<OutcomeShell
				icon={CircleCheck}
				title={EXAM_SETUP_OUTCOMES.complete.title}
				message={EXAM_SETUP_OUTCOMES.complete.message}
				className={className}
			>
				<Button type="button" variant="outline" onClick={onStartOver}>
					Make another change
				</Button>
			</OutcomeShell>
		)
	}

	if (!authorize.isEnabled) {
		return (
			<OutcomeShell
				icon={CalendarCheck}
				title={EXAM_SETUP_OUTCOMES.schedulingDisabled.title}
				message={EXAM_SETUP_OUTCOMES.schedulingDisabled.message}
				className={className}
			>
				<CardCta
					label={EXAM_SETUP_OUTCOMES.schedulingDisabled.ctaLabel}
					url={myGarpHref}
					isExternal
					className="text-sm"
				/>
			</OutcomeShell>
		)
	}

	const result = authorize.result
	if (result?.isAuthorized === true) {
		return (
			<OutcomeShell
				icon={CalendarCheck}
				title={EXAM_SETUP_OUTCOMES.scheduling.title}
				message={EXAM_SETUP_OUTCOMES.scheduling.message}
				className={className}
			>
				{result.examScheduleExamURLPart1 ? (
					<CardCta
						label={
							result.examScheduleExamURLPart2
								? "Schedule Part I"
								: EXAM_SETUP_OUTCOMES.scheduling.ctaLabel
						}
						url={result.examScheduleExamURLPart1}
						isExternal
						newWindow
						className="text-sm"
					/>
				) : null}
				{result.examScheduleExamURLPart2 ? (
					<CardCta
						label="Schedule Part II"
						url={result.examScheduleExamURLPart2}
						isExternal
						newWindow
						className="text-sm"
					/>
				) : null}
			</OutcomeShell>
		)
	}

	if (authorize.isExhausted) {
		return (
			<OutcomeShell
				icon={CalendarCheck}
				title={EXAM_SETUP_OUTCOMES.schedulingDisabled.title}
				message={EXAM_SETUP_OUTCOMES.schedulingDisabled.message}
				className={className}
			>
				<CardCta
					label={EXAM_SETUP_OUTCOMES.schedulingDisabled.ctaLabel}
					url={myGarpHref}
					isExternal
					className="text-sm"
				/>
			</OutcomeShell>
		)
	}

	return (
		<OutcomeShell
			icon={Clock}
			title={EXAM_SETUP_OUTCOMES.schedulingPending.title}
			message={EXAM_SETUP_OUTCOMES.schedulingPending.message}
			className={className}
		>
			<Button
				type="button"
				onClick={authorize.attempts === 0 ? authorize.authorize : authorize.retry}
				disabled={authorize.isPending}
			>
				{authorize.isPending
					? "Checking…"
					: EXAM_SETUP_OUTCOMES.schedulingPending.ctaLabel}
			</Button>
		</OutcomeShell>
	)
}

export { ExamSetupOutcome }
