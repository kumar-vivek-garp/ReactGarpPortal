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
import type { FrmFormValues } from "@/components/forms/frm/frm-form-values"
import {
	ACKNOWLEDGEMENT_COPY,
	CANDIDATE_RESPONSIBILITY_URL,
	POLICY_LINKS,
} from "@/config/registration"

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
	control: Control<FrmFormValues>
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
	control: Control<FrmFormValues>
	errors: FieldErrors<FrmFormValues>
	/** Exam policies for this programme, from the programme's display config. */
	examPolicyUrl: string
	/** True when the billing country carries a GDPR or CASL tag. */
	isComplianceCountry: boolean
	submitLabel: string
	disabled?: boolean
}

/**
 * What the candidate is agreeing to.
 *
 * The two acknowledgements are always required — Apex refuses the whole
 * registration unless both are ticked, and it records each as a timestamp on
 * the exam attempt.
 *
 * The three policy ticks below them only appear for a country tagged GDPR or
 * CASL. Everywhere else, submitting IS the agreement and the notice says so —
 * which is the legacy's behaviour, and the reason all three collapse into one
 * boolean server-side.
 */
function AcknowledgementsSection({
	control,
	errors,
	examPolicyUrl,
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
				<CardTitle className="text-lg">{ACKNOWLEDGEMENT_COPY.title}</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
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
						errors.candidateResponsibility?.message ?? errors.examPolicy?.message
					}
				/>

				{isComplianceCountry ? (
					<fieldset className="flex flex-col gap-3 border-t border-border pt-4">
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
					<p className="border-t border-border pt-4 text-caption text-muted-foreground">
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
