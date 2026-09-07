import {
	CalendarCheck,
	CircleAlert,
	CircleCheck,
	ExternalLink,
	LoaderCircle,
	ReceiptText,
} from "lucide-react"

import type { ExamSetupFeesView, ExamSetupIdSaveResult } from "@/api/exam-setup"
import { Button } from "@/components/atoms/button"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
import { CardCta } from "@/components/molecules/card-cta"
import { EXAM_SETUP_OUTCOMES } from "@/config/exam-setup"
import type { ExamSetupAuthorizeState } from "@/hooks/use-exam-setup"
import { formatMoney } from "@/lib/account-format"
import { examSetupFeesTotal, outcomeFrom } from "@/lib/exam-setup-presentation"
import { examSetupFeesCheckoutHref } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

/** The priced lines, in the confirm dialog's panel idiom. */
function FeeLines({ fees }: { fees: ExamSetupFeesView }) {
	const lines = fees.fees ?? []
	if (lines.length === 0) return null
	const total = examSetupFeesTotal(lines)

	return (
		<dl className="flex w-full max-w-md flex-col gap-2 rounded-xl border border-border bg-background/60 p-4 text-left">
			{lines.map((fee, index) => (
				<div
					key={`${fee.name ?? "fee"}-${index}`}
					className="flex items-baseline justify-between gap-4 text-body"
				>
					<dt className="min-w-0">
						<span className="block">{fee.name}</span>
						{fee.description ? (
							<span className="block text-caption text-muted-foreground">
								{fee.description}
							</span>
						) : null}
					</dt>
					<dd className="shrink-0 tabular-nums">
						{/* A refund reads as a credit, not as a second charge. */}
						{fee.type === "refund" ? "−" : ""}
						{formatMoney(Math.abs(fee.amount ?? 0), "USD")}
					</dd>
				</div>
			))}
			<div className="mt-1 flex items-baseline justify-between gap-4 border-t border-border pt-2 text-base font-semibold">
				<dt>{EXAM_SETUP_OUTCOMES.payFees.totalLabel}</dt>
				<dd className="shrink-0 tabular-nums text-primary">{formatMoney(total, "USD")}</dd>
			</div>
		</dl>
	)
}

type ExamSetupOutcomeProps = {
	result: ExamSetupIdSaveResult
	fees: ExamSetupFeesView | null
	authorize: ExamSetupAuthorizeState
	myGarpHref: string | null
	className?: string
}

/**
 * What the member sees once the save has landed, in place of the form.
 *
 * The order of these branches follows the server's own: a change that needs
 * paying is reported as such even if it would also need scheduling, because
 * until the fee is settled nothing else about it is true yet.
 *
 * The scheduling half has four legs, because the provider is a third party and
 * can be slow or unreachable: disabled (flag off — finish in MyGarp),
 * authorising (the push and its one retry are in flight), authorized (links),
 * not completed (it did not, or it failed — say so, point at the email).
 */
function ExamSetupOutcome({
	result,
	fees,
	authorize,
	myGarpHref,
	className,
}: ExamSetupOutcomeProps) {
	const outcome = outcomeFrom(result)

	if (outcome === "pay-fees") {
		const checkoutHref = examSetupFeesCheckoutHref(result.examModificationId)
		return (
			<RegistrationStatusPanel
				icon={ReceiptText}
				tone="notice"
				title={EXAM_SETUP_OUTCOMES.payFees.title}
				message={EXAM_SETUP_OUTCOMES.payFees.message}
				detail={fees ? <FeeLines fees={fees} /> : null}
				action={
					checkoutHref ? (
						<Button asChild size="lg">
							<a href={checkoutHref}>
								{EXAM_SETUP_OUTCOMES.payFees.ctaLabel}
								<ExternalLink aria-hidden />
							</a>
						</Button>
					) : null
				}
				className={className}
			/>
		)
	}

	if (outcome === "complete") {
		return (
			<RegistrationStatusPanel
				icon={CircleCheck}
				tone="success"
				title={EXAM_SETUP_OUTCOMES.complete.title}
				message={EXAM_SETUP_OUTCOMES.complete.message}
				className={className}
			/>
		)
	}

	if (!authorize.isEnabled) {
		return (
			<RegistrationStatusPanel
				icon={CalendarCheck}
				tone="notice"
				title={EXAM_SETUP_OUTCOMES.schedulingDisabled.title}
				message={EXAM_SETUP_OUTCOMES.schedulingDisabled.message}
				action={
					myGarpHref ? (
						<Button asChild size="lg">
							<a href={myGarpHref}>
								{EXAM_SETUP_OUTCOMES.schedulingDisabled.ctaLabel}
								<ExternalLink aria-hidden />
							</a>
						</Button>
					) : null
				}
				className={className}
			/>
		)
	}

	if (authorize.isAuthorising) {
		return (
			<RegistrationStatusPanel
				icon={LoaderCircle}
				title={EXAM_SETUP_OUTCOMES.authorising.title}
				message={EXAM_SETUP_OUTCOMES.authorising.message}
				className={cn("[&>svg]:animate-spin", className)}
			/>
		)
	}

	const authorized = authorize.result
	if (authorized?.isAuthorized) {
		const hasPart2 = Boolean(authorized.examScheduleExamURLPart2)
		return (
			<RegistrationStatusPanel
				icon={CalendarCheck}
				tone="success"
				title={EXAM_SETUP_OUTCOMES.authorized.title}
				message={EXAM_SETUP_OUTCOMES.authorized.message}
				action={
					<div className="flex flex-wrap items-center justify-center gap-3">
						{authorized.examScheduleExamURLPart1 ? (
							<Button asChild size="lg">
								<a
									href={authorized.examScheduleExamURLPart1}
									target="_blank"
									rel="noreferrer noopener"
								>
									{hasPart2
										? EXAM_SETUP_OUTCOMES.authorized.ctaLabelPart1
										: EXAM_SETUP_OUTCOMES.authorized.ctaLabel}
									<ExternalLink aria-hidden />
								</a>
							</Button>
						) : null}
						{authorized.examScheduleExamURLPart2 ? (
							<Button asChild size="lg" variant="outline">
								<a
									href={authorized.examScheduleExamURLPart2}
									target="_blank"
									rel="noreferrer noopener"
								>
									{EXAM_SETUP_OUTCOMES.authorized.ctaLabelPart2}
									<ExternalLink aria-hidden />
								</a>
							</Button>
						) : null}
					</div>
				}
				className={className}
			/>
		)
	}

	return (
		<RegistrationStatusPanel
			icon={CircleAlert}
			tone="error"
			title={EXAM_SETUP_OUTCOMES.notCompleted.title}
			message={EXAM_SETUP_OUTCOMES.notCompleted.message}
			action={
				<CardCta
					label={EXAM_SETUP_OUTCOMES.notCompleted.ctaLabel}
					url="/help-center"
					isExternal={false}
					className="text-sm"
				/>
			}
			className={className}
		/>
	)
}

export { ExamSetupOutcome }
