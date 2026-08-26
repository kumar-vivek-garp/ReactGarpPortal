import { ShieldCheck } from "lucide-react"

import { Controller, type Control, type FieldErrors } from "react-hook-form"

import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { FieldError } from "@/components/molecules/form-field"
import type { ExamFormValues } from "@/components/forms/exam-registration/exam-form-values"
import {
	ACKNOWLEDGEMENT_COPY,
	CANDIDATE_RESPONSIBILITY_URL,
	POLICY_LINKS,
} from "@/config/registration"
import { cn } from "@/lib/utils"

function PolicyLink({ href, children }: { href: string; children: string }) {
	return (
		<a
			href={href}
			target="_blank"
			rel="noreferrer"
			className="font-semibold text-primary hover:underline"
		>
			{children}
		</a>
	)
}

type TickProps = {
	id: string
	name:
		| "candidateResponsibility"
		| "examPolicy"
		| "attestPrivacyNotice"
		| "attestLimitationOfLiability"
		| "attestReleaseAndWaiver"
	control: Control<ExamFormValues>
	invalid: boolean
	disabled?: boolean
	children: React.ReactNode
}

function Tick({ id, name, control, invalid, disabled, children }: TickProps) {
	return (
		<Controller
			control={control}
			name={name}
			rules={{ required: ACKNOWLEDGEMENT_COPY.policiesRequired }}
			render={({ field }) => (
				<div className="flex items-start gap-3">
					<Checkbox
						id={id}
						checked={field.value}
						onCheckedChange={(next) => field.onChange(next === true)}
						aria-invalid={invalid ? true : undefined}
						disabled={disabled}
						className="mt-0.5"
					/>
					<Label htmlFor={id} className="text-body leading-5 font-normal">
						{children}
					</Label>
				</div>
			)}
		/>
	)
}

type AcknowledgementsSectionProps = {
	control: Control<ExamFormValues>
	errors: FieldErrors<ExamFormValues>
	/** Exam policies for this programme, from the programme's display config. */
	examPolicyUrl: string
	/**
	 * The candidate responsibility / exam policy pair.
	 *
	 * Exam kinds only. A course has no exam policy, and `GARP_ExamReg_RegService`
	 * requires the attestation for `kind == 'exam'` and for nothing else.
	 */
	showCandidateAcknowledgements: boolean
	/** True when the billing country carries a GDPR or CASL tag. */
	isComplianceCountry: boolean
	submitLabel: string
	disabled?: boolean
}

/**
 * What the candidate is agreeing to.
 *
 * Two blocks with different audiences, which is why they are gated separately
 * rather than as one card:
 *
 * - The **candidate acknowledgements** are exam-only, and on an exam they are
 *   mandatory — Apex refuses the whole registration unless both are ticked,
 *   and records each as a timestamp on the exam attempt.
 * - The **compliance ticks** apply to every programme kind, because a GDPR or
 *   CASL registrant has to answer them whatever they are buying. Hiding them
 *   for a course would post `privacyPolicy: false` for every EU course
 *   registrant, which Apex accepts in silence.
 *
 * Outside a compliance country, submitting IS the agreement and the notice
 * says so — the legacy's behaviour, and the reason all three collapse into one
 * boolean server-side.
 *
 * The caller decides whether this card renders at all: with neither block it
 * would be a heading and nothing to do. See `showAcknowledgementsCard`.
 */
function AcknowledgementsSection({
	control,
	errors,
	examPolicyUrl,
	showCandidateAcknowledgements,
	isComplianceCountry,
	submitLabel,
	disabled,
}: AcknowledgementsSectionProps) {
	const policiesInvalid = Boolean(
		errors.attestPrivacyNotice ||
			errors.attestLimitationOfLiability ||
			errors.attestReleaseAndWaiver,
	)

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<ShieldCheck className="size-5 text-muted-foreground" aria-hidden />
					{ACKNOWLEDGEMENT_COPY.title}
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				{showCandidateAcknowledgements ? (
					<>
						<Tick
					id="candidateResponsibility"
					name="candidateResponsibility"
					control={control}
					invalid={Boolean(errors.candidateResponsibility)}
					disabled={disabled}
				>
					{ACKNOWLEDGEMENT_COPY.candidateResponsibility}{" "}
					<PolicyLink href={CANDIDATE_RESPONSIBILITY_URL}>
						{ACKNOWLEDGEMENT_COPY.candidateResponsibilityLink}
					</PolicyLink>
					.
				</Tick>

				<Tick
					id="examPolicy"
					name="examPolicy"
					control={control}
					invalid={Boolean(errors.examPolicy)}
					disabled={disabled}
				>
					{ACKNOWLEDGEMENT_COPY.examPolicy}{" "}
					<PolicyLink href={examPolicyUrl}>
						{ACKNOWLEDGEMENT_COPY.examPolicyLink}
					</PolicyLink>
					.
				</Tick>

						<FieldError
							message={
								errors.candidateResponsibility?.message ??
								errors.examPolicy?.message
							}
						/>
					</>
				) : null}

				{isComplianceCountry ? (
					<fieldset
						className={cn(
							"flex flex-col gap-3",
							// Nothing above it on a course — a rule under the heading
							// would divide the card from itself.
							showCandidateAcknowledgements && "border-t border-border pt-4",
						)}
					>
						<legend className="sr-only">Policy confirmations</legend>
						<p className="text-caption text-muted-foreground">
							{ACKNOWLEDGEMENT_COPY.complianceIntro}
						</p>

						<Tick
							id="attestPrivacyNotice"
							name="attestPrivacyNotice"
							control={control}
							invalid={policiesInvalid}
							disabled={disabled}
						>
							I have read GARP&rsquo;s{" "}
							<PolicyLink href={POLICY_LINKS.privacyNotice}>
								Privacy Notice
							</PolicyLink>{" "}
							and{" "}
							<PolicyLink href={POLICY_LINKS.codeOfConduct}>
								Code of Conduct
							</PolicyLink>
							.
						</Tick>

						<Tick
							id="attestLimitationOfLiability"
							name="attestLimitationOfLiability"
							control={control}
							invalid={policiesInvalid}
							disabled={disabled}
						>
							I have read GARP&rsquo;s{" "}
							<PolicyLink href={POLICY_LINKS.limitationOfLiability}>
								Limitation of Liability
							</PolicyLink>
							.
						</Tick>

						<Tick
							id="attestReleaseAndWaiver"
							name="attestReleaseAndWaiver"
							control={control}
							invalid={policiesInvalid}
							disabled={disabled}
						>
							I have read GARP&rsquo;s{" "}
							<PolicyLink href={POLICY_LINKS.releaseAndWaiver}>
								Waiver and Release
							</PolicyLink>
							.
						</Tick>

						{policiesInvalid ? (
							<FieldError message={ACKNOWLEDGEMENT_COPY.policiesRequired} />
						) : null}
					</fieldset>
				) : (
					<p
						className={cn(
							"text-caption text-muted-foreground",
							showCandidateAcknowledgements && "border-t border-border pt-4",
						)}
					>
						By selecting <strong>{submitLabel}</strong> you agree to the{" "}
						<PolicyLink href={POLICY_LINKS.privacyNotice}>
							Privacy Notice
						</PolicyLink>
						,{" "}
						<PolicyLink href={POLICY_LINKS.codeOfConduct}>
							Code of Conduct
						</PolicyLink>
						,{" "}
						<PolicyLink href={POLICY_LINKS.limitationOfLiability}>
							Limitation of Liability
						</PolicyLink>{" "}
						and{" "}
						<PolicyLink href={POLICY_LINKS.releaseAndWaiver}>
							Waiver and Release
						</PolicyLink>
						, and to receiving emails from GARP and selected third-party
						providers.
					</p>
				)}
			</CardContent>
		</Card>
	)
}

export { AcknowledgementsSection }
