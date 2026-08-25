import { Controller, type Control, type FieldErrors } from "react-hook-form"
import { ShieldCheck } from "lucide-react"

import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { FieldError } from "@/components/molecules/form-field"
import type { AffiliateFormValues } from "@/components/forms/affiliate/affiliate-form-values"
import { POLICY_LINKS, SMS_COPY } from "@/config/registration"

const POLICIES_REQUIRED = "You must confirm you have read our policies."

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

/** The checkbox-backed fields only — a `Tick` cannot drive a text field. */
type BooleanFieldName =
	| "smsPromotionalUpdates"
	| "attestPrivacyNotice"
	| "attestLimitationOfLiability"
	| "attestReleaseAndWaiver"

type TickProps = {
	id: string
	name: BooleanFieldName
	control: Control<AffiliateFormValues>
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
			rules={required ? { required: POLICIES_REQUIRED } : undefined}
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

type ConsentSectionProps = {
	control: Control<AffiliateFormValues>
	errors: FieldErrors<AffiliateFormValues>
	/** True when the selected location carries a GDPR or CASL tag. */
	isComplianceCountry: boolean
	submitLabel: string
	disabled?: boolean
}

/**
 * What the new member is agreeing to.
 *
 * The three policy ticks appear only for a country tagged GDPR or CASL —
 * `Country_Code__c.Compliance__c` is a *tag*, not a flag, and Apex reduces any
 * non-blank value to a boolean. Everywhere else, submitting IS the agreement
 * and the notice says so, which is why all three collapse into the single
 * `consent.privacyPolicy` the register call sends.
 *
 * They are conditionally *rendered* rather than conditionally *required*: a
 * field react-hook-form has unmounted stops counting towards `isValid`, so
 * changing location to a non-compliance country cannot strand the submit
 * button behind a rule with no visible control to satisfy it. Toggling a
 * `rules` object instead would do exactly that — RHF reads `rules` once at
 * mount and never again.
 */
function ConsentSection({
	control,
	errors,
	isComplianceCountry,
	submitLabel,
	disabled,
}: ConsentSectionProps) {
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
					Consent and policies
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				<div className="flex flex-col gap-2">
					<p className="text-body font-bold">{SMS_COPY.promotionalHeading}</p>
					{/* Optional — never required, and it starts unticked. */}
					<Tick
						id="smsPromotionalUpdates"
						name="smsPromotionalUpdates"
						control={control}
						disabled={disabled}
					>
						{SMS_COPY.promotionalOptIn}
					</Tick>
				</div>

				{isComplianceCountry ? (
					<fieldset className="flex flex-col gap-3 border-t border-border pt-4">
						<legend className="sr-only">Policy confirmations</legend>

						<Tick
							id="attestPrivacyNotice"
							name="attestPrivacyNotice"
							control={control}
							required
							invalid={policiesInvalid}
							disabled={disabled}
						>
							Yes, I have read GARP&rsquo;s{" "}
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
							required
							invalid={policiesInvalid}
							disabled={disabled}
						>
							Yes, I have read GARP&rsquo;s{" "}
							<PolicyLink href={POLICY_LINKS.limitationOfLiability}>
								Limitation of Liability
							</PolicyLink>
							.
						</Tick>

						<Tick
							id="attestReleaseAndWaiver"
							name="attestReleaseAndWaiver"
							control={control}
							required
							invalid={policiesInvalid}
							disabled={disabled}
						>
							Yes, I have read GARP&rsquo;s{" "}
							<PolicyLink href={POLICY_LINKS.releaseAndWaiver}>
								Waiver and Release
							</PolicyLink>
							.
						</Tick>

						{policiesInvalid ? (
							<FieldError message={POLICIES_REQUIRED} />
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
						providers with news, special offers, promotions and future messages
						that may be of interest to you.
					</p>
				)}
			</CardContent>
		</Card>
	)
}

export { ConsentSection }
