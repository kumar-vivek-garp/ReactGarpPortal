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
		| "attestPolicies"
		| "marketingEmails"
	control: Control<ExamFormValues>
	/** Optional ticks carry no `*` and no rule — see `marketingEmails` below. */
	required?: boolean
	invalid?: boolean
	disabled?: boolean
	children: React.ReactNode
}

function Tick({
	id,
	name,
	control,
	required = false,
	invalid = false,
	disabled,
	children,
}: TickProps) {
	return (
		<Controller
			control={control}
			name={name}
			rules={
				required ? { required: ACKNOWLEDGEMENT_COPY.policiesRequired } : undefined
			}
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
					{/*
					 * `block`, not the Label atom's default `flex`. These labels are
					 * PROSE with links in it, and a flex container turns every link and
					 * text node into a separate column — which is exactly how this
					 * rendered the first time: four stacked link columns with the commas
					 * stranded between them.
					 */}
					<Label
						htmlFor={id}
						className="block text-body leading-6 font-normal"
					>
						{required ? (
							<span className="text-destructive" aria-hidden>
								*{" "}
							</span>
						) : null}
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
	disabled?: boolean
}

/**
 * What the candidate is agreeing to — three required confirmations and one
 * optional opt-in.
 *
 * The 2027 designs replaced a split that is worth remembering, because this is
 * the second time it has changed: a GDPR/CASL country used to get three
 * separate attestations while everyone else got a single "by selecting Register
 * you agree…" line and had `privacyPolicy: true` posted on their behalf. That
 * meant consent was recorded for people who had never been shown the
 * statements, and it depended on a Location field that no longer exists.
 *
 * Now every candidate ticks the same boxes, so there is no country to resolve
 * and no implicit branch. Strictly better consent, and materially simpler.
 *
 * The first two are exam-only: a course has no exam policy, and Apex requires
 * the attestation for `kind == 'exam'` and nothing else. The caller decides
 * whether the card renders at all — see `showAcknowledgementsCard`.
 */
function AcknowledgementsSection({
	control,
	errors,
	examPolicyUrl,
	showCandidateAcknowledgements,
	disabled,
}: AcknowledgementsSectionProps) {
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
							required
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
							required
							invalid={Boolean(errors.examPolicy)}
							disabled={disabled}
						>
							{ACKNOWLEDGEMENT_COPY.examPolicy}{" "}
							<PolicyLink href={examPolicyUrl}>
								{ACKNOWLEDGEMENT_COPY.examPolicyLink}
							</PolicyLink>
							.
						</Tick>
					</>
				) : null}

				{/*
				 * One tick over all five policies, as the designs draw it. Apex
				 * collapses them into a single `privacyPolicy` boolean anyway, so
				 * splitting them would record a distinction the server cannot keep.
				 */}
				<Tick
					id="attestPolicies"
					name="attestPolicies"
					control={control}
					required
					invalid={Boolean(errors.attestPolicies)}
					disabled={disabled}
				>
					Yes, I have read GARP&rsquo;s{" "}
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
					</PolicyLink>
					,{" "}
					<PolicyLink href={POLICY_LINKS.releaseAndWaiver}>
						Waiver and Release
					</PolicyLink>{" "}
					{/*
					 * Plain text, not a link: GARP publishes no Refund Policy page —
					 * every candidate path 404s. Wrap it in a `PolicyLink` as soon as
					 * there is a URL to point at.
					 */}
					and Refund Policy.
				</Tick>

				{/*
				 * OPT-IN, and deliberately not required. Bundling marketing consent
				 * into a registration nobody can complete without it is not consent —
				 * it is the pattern GDPR Art. 7(4) exists to forbid. Unticked is a
				 * complete answer; do not add a `required` rule here.
				 */}
				<Tick
					id="marketingEmails"
					name="marketingEmails"
					control={control}
					disabled={disabled}
				>
					{ACKNOWLEDGEMENT_COPY.marketingEmails}
				</Tick>

				<FieldError
					message={
						errors.candidateResponsibility?.message ??
						errors.examPolicy?.message ??
						errors.attestPolicies?.message
					}
				/>
			</CardContent>
		</Card>
	)
}

export { AcknowledgementsSection }
