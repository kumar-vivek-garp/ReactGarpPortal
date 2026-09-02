import { UserRound } from "lucide-react"
import type { FieldErrors, UseFormRegister } from "react-hook-form"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import { FormField } from "@/components/molecules/form-field"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import { EMAIL_PATTERN, PHONE_PATTERN } from "@/config/registration"

type IndividualDetailsSectionProps = {
	register: UseFormRegister<EventFormValues>
	errors: FieldErrors<EventFormValues>
	/**
	 * True when the server prefilled the identity from the member's record.
	 * The email/name controls are then HIDDEN — registering does not change
	 * the record, so showing them invites edits that look saved to the account
	 * but are not. The seeded values stay in form state and still travel with
	 * the registration; unregistered fields also stop carrying validation, so
	 * a hidden field can never strand the submit button disabled.
	 */
	hideIdentityFields: boolean
	/**
	 * Job title and company fold into this card rather than owning one — a
	 * "Professional details" card holding two optional inputs is a card for a
	 * heading's sake. Off for chapter meetings that do not ask.
	 */
	showProfessionalFields: boolean
}

/** Who is registering. */
function IndividualDetailsSection({
	register,
	errors,
	hideIdentityFields,
	showProfessionalFields,
}: IndividualDetailsSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<UserRound className="size-5 text-muted-foreground" aria-hidden />
					{hideIdentityFields ? "Contact details" : "Your details"}
				</CardTitle>
				<p className="text-body text-muted-foreground">
					{hideIdentityFields
						? "Your name and email come from your account and travel with this registration."
						: "We will use these details to confirm your place and contact you about the event."}
				</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				{hideIdentityFields ? null : (
					<>
						<FormField
							id="event-reg-email"
							label="Email"
							required
							error={errors.email?.message}
							className="sm:col-span-2"
						>
							<Input
								id="event-reg-email"
								type="email"
								autoComplete="email"
								placeholder="name@example.com"
								aria-invalid={Boolean(errors.email)}
								{...register("email", {
									required: "Email address is required.",
									pattern: {
										value: EMAIL_PATTERN,
										message: "Please enter a valid email address.",
									},
								})}
							/>
						</FormField>

						<FormField
							id="event-reg-first-name"
							label="First name"
							required
							error={errors.firstName?.message}
						>
							<Input
								id="event-reg-first-name"
								autoComplete="given-name"
								aria-invalid={Boolean(errors.firstName)}
								{...register("firstName", {
									required: "First name is required.",
								})}
							/>
						</FormField>

						<FormField
							id="event-reg-last-name"
							label="Last name"
							required
							error={errors.lastName?.message}
						>
							<Input
								id="event-reg-last-name"
								autoComplete="family-name"
								aria-invalid={Boolean(errors.lastName)}
								{...register("lastName", {
									required: "Last name is required.",
								})}
							/>
						</FormField>
					</>
				)}

				<FormField
					id="event-reg-phone"
					label="Work phone"
					error={errors.workPhone?.message}
					hint="Digits only, 7–15."
					className={showProfessionalFields ? undefined : "sm:col-span-2"}
				>
					<Input
						id="event-reg-phone"
						type="tel"
						autoComplete="tel"
						inputMode="numeric"
						aria-invalid={Boolean(errors.workPhone)}
						{...register("workPhone", {
							validate: (value) =>
								!value.trim() ||
								PHONE_PATTERN.test(value.trim()) ||
								"Please enter digits only (7–15).",
						})}
					/>
				</FormField>

				{showProfessionalFields ? (
					<>
						<FormField id="event-reg-job-title" label="Job title">
							<Input
								id="event-reg-job-title"
								autoComplete="organization-title"
								{...register("jobTitle")}
							/>
						</FormField>
						<FormField id="event-reg-company" label="Company">
							<Input
								id="event-reg-company"
								autoComplete="organization"
								{...register("company")}
							/>
						</FormField>
					</>
				) : null}
			</CardContent>
		</Card>
	)
}

export { IndividualDetailsSection }
