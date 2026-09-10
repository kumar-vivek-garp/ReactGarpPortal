import { UserRound } from "lucide-react"

import type { FieldErrors, UseFormRegister } from "react-hook-form"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import { FormField } from "@/components/molecules/form-field"
import type { ExamFormValues } from "@/components/forms/exam-registration/exam-form-values"
import {
	EMAIL_PATTERN,
	REGISTRATION_LIMITS,
	isEnglishName,
} from "@/config/registration"

type YourDetailsSectionProps = {
	register: UseFormRegister<ExamFormValues>
	errors: FieldErrors<ExamFormValues>
	/**
	 * The identity check GarpAppv1 runs on blur — wired to first name, last
	 * name and email because the check sends all three. This card is guest-only,
	 * so a member never triggers it.
	 */
	onIdentityBlur?: () => void
	disabled?: boolean
}

/**
 * Who is registering — name and email, and nothing else.
 *
 * **Guest-only.** A member has all three on their account already, and the 2027
 * designs cut the rest of the card (location, mobile phone, promotional SMS),
 * so for a member there would be nothing left to render but a heading. The
 * caller decides that; this component assumes a guest.
 *
 * The values a guest types here create their GARP account and travel with the
 * order.
 */
function YourDetailsSection({
	register,
	errors,
	onIdentityBlur,
	disabled,
}: YourDetailsSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<UserRound className="size-5 text-muted-foreground" aria-hidden />
					Individual Details
				</CardTitle>
				<p className="text-body text-muted-foreground">
					We will use these details to create your GARP account and to contact
					you about the exam.
				</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
					<FormField
						id="firstName"
						label="First name"
						required
						error={errors.firstName?.message}
					>
						<Input
							id="firstName"
							autoComplete="given-name"
							maxLength={REGISTRATION_LIMITS.nameMaxLength}
							disabled={disabled}
							aria-invalid={errors.firstName ? true : undefined}
							{...register("firstName", {
								required: "Please enter your first name.",
								minLength: {
									value: REGISTRATION_LIMITS.nameMinLength,
									message: "Your first name must be more than 1 character.",
								},
								validate: (value) =>
									isEnglishName(value) || "Please enter only English characters.",
								onBlur: onIdentityBlur,
							})}
						/>
					</FormField>

					<FormField
						id="lastName"
						label="Last name"
						required
						error={errors.lastName?.message}
					>
						<Input
							id="lastName"
							autoComplete="family-name"
							maxLength={REGISTRATION_LIMITS.nameMaxLength}
							disabled={disabled}
							aria-invalid={errors.lastName ? true : undefined}
							{...register("lastName", {
								required: "Please enter your last name.",
								minLength: {
									value: REGISTRATION_LIMITS.nameMinLength,
									message: "Your last name must be more than 1 character.",
								},
								validate: (value) =>
									isEnglishName(value) || "Please enter only English characters.",
								onBlur: onIdentityBlur,
							})}
						/>
					</FormField>

					<FormField
						id="email"
						label="Email"
						required
						error={errors.email?.message}
					>
						<Input
							id="email"
							type="email"
							autoComplete="email"
							maxLength={REGISTRATION_LIMITS.emailMaxLength}
							disabled={disabled}
							aria-invalid={errors.email ? true : undefined}
							{...register("email", {
								required: "Email address is required.",
								pattern: {
									value: EMAIL_PATTERN,
									message: "Please enter a valid email address.",
								},
								onBlur: onIdentityBlur,
							})}
						/>
					</FormField>

			</CardContent>
		</Card>
	)
}

export { YourDetailsSection }
