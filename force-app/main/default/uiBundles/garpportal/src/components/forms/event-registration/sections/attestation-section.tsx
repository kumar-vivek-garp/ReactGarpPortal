import { ShieldCheck } from "lucide-react"
import { Controller, type Control, type FieldErrors } from "react-hook-form"

import { Card, CardContent } from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { FieldError } from "@/components/molecules/form-field"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import { POLICY_LINKS } from "@/config/registration"

type AttestationSectionProps = {
	control: Control<EventFormValues>
	errors: FieldErrors<EventFormValues>
}

/** The one mandatory tick — the GARP Privacy Notice. Starts unticked, always. */
function AttestationSection({ control, errors }: AttestationSectionProps) {
	return (
		<Card className="py-4">
			<CardContent className="flex flex-col gap-2 px-5">
				<div className="flex items-start gap-3">
					<ShieldCheck
						className="mt-0.5 size-5 shrink-0 text-muted-foreground"
						aria-hidden
					/>
					<Controller
						control={control}
						name="privacyPolicyAttestation"
						rules={{
							validate: (value) =>
								value || "Please accept the GARP Privacy Notice.",
						}}
						render={({ field }) => (
							<Checkbox
								id="event-reg-attestation"
								className="mt-0.5"
								checked={field.value}
								onCheckedChange={field.onChange}
								aria-invalid={Boolean(errors.privacyPolicyAttestation)}
							/>
						)}
					/>
					<Label
						htmlFor="event-reg-attestation"
						className="font-normal leading-snug"
					>
						I have read and accept the{" "}
						<a
							href={POLICY_LINKS.privacyNotice}
							target="_blank"
							rel="noreferrer noopener"
							className="font-semibold text-primary hover:underline"
						>
							GARP Privacy Notice
						</a>
						.
					</Label>
				</div>
				<FieldError
					message={errors.privacyPolicyAttestation?.message}
					className="pl-8"
				/>
			</CardContent>
		</Card>
	)
}

export { AttestationSection }
