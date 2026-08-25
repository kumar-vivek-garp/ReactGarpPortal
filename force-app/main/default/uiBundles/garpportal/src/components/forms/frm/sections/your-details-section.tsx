import { UserRound } from "lucide-react"

import { useMemo } from "react"
import {
	Controller,
	type Control,
	type FieldErrors,
	type UseFormRegister,
} from "react-hook-form"

import type { RegistrationCountry } from "@/api/registration/exam-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { FieldError, FormField } from "@/components/molecules/form-field"
import type { FrmFormValues } from "@/components/forms/frm/frm-form-values"
import {
	EMAIL_PATTERN,
	PHONE_PATTERN,
	REGISTRATION_LIMITS,
	SMS_COPY,
	isEnglishName,
} from "@/config/registration"

type YourDetailsSectionProps = {
	register: UseFormRegister<FrmFormValues>
	control: Control<FrmFormValues>
	errors: FieldErrors<FrmFormValues>
	countries: RegistrationCountry[]
	/** False on the public form — nothing has been prefilled. */
	isAuthenticated?: boolean
	/**
	 * Whether to ask for the location here.
	 *
	 * False once the billing address card is on screen — that card carries its
	 * own country, and asking twice is two chances to disagree. Matches the
	 * legacy app, which renders this field under exactly the same condition.
	 */
	showLocation?: boolean
	/**
	 * Changing the country is not a plain field write: it clears the province
	 * and re-picks the payment method, because the new country may not permit
	 * what was already chosen.
	 */
	onCountryChange: (countryCode: string) => void
	disabled?: boolean
}

/**
 * Who is registering — prefilled from the member's own record.
 *
 * Editable rather than read-only: the details GARP holds may be stale, and a
 * registration is exactly the moment someone notices. What they change here
 * travels with the order.
 *
 * Mobile phone is required even though everything else is on file, because
 * GARP sends time-sensitive exam messages to it and a stale number is worse
 * than an absent one.
 */
function YourDetailsSection({
	register,
	control,
	errors,
	countries,
	isAuthenticated = true,
	showLocation = true,
	onCountryChange,
	disabled,
}: YourDetailsSectionProps) {
	const sortedCountries = useMemo(
		() => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
		[countries],
	)

	const phoneCodeOptions = useMemo(
		() =>
			sortedCountries
				.filter((country) => Boolean(country.phoneCode))
				.map((country) => ({
					value: `${country.countryCode} (+${country.phoneCode})`,
					label: `${country.name} (+${country.phoneCode})`,
				})),
		[sortedCountries],
	)

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<UserRound className="size-5 text-muted-foreground" aria-hidden />
					{isAuthenticated ? "Contact details" : "Your details"}
				</CardTitle>
				<p className="text-body text-muted-foreground">
					{isAuthenticated
						? "Your name and email come from your account. We only need a mobile number, for exam-day updates."
						: "We will use these details to create your GARP account and to contact you about the exam."}
				</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				{/*
				 * A member already has these on their record, and the registration
				 * does not change them — showing them invites edits that look saved
				 * to the account but are not. The values stay in the form and still
				 * travel with the order; only the controls are hidden.
				 */}
				{isAuthenticated ? null : (
					<>
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
							})}
						/>
					</FormField>
					</>
				)}

				{showLocation ? (
					<FormField
						id="country"
						label="Location"
						required
						error={errors.country?.message}
						hint="Sets your tax, shipping and payment options."
					>
						<Controller
							control={control}
							name="country"
							rules={{ required: "Please select your location." }}
							render={({ field }) => (
								<Select
									value={field.value}
									onValueChange={(next) => {
										field.onChange(next)
										onCountryChange(next)
									}}
									disabled={disabled}
								>
									<SelectTrigger
										id="country"
										aria-invalid={errors.country ? true : undefined}
										className="w-full"
									>
										<SelectValue placeholder="Select location" />
									</SelectTrigger>
									<SelectContent>
										{sortedCountries.map((country) => (
											<SelectItem key={country.id} value={country.countryCode}>
												{country.name}
											</SelectItem>
										))}
									</SelectContent>
								</Select>
							)}
						/>
					</FormField>
				) : null}

				<div className="flex flex-col gap-2 sm:col-span-2">
					<Label htmlFor="mobilePhone" className="font-bold">
						Mobile phone
						<span className="text-destructive" aria-hidden>
							{" "}
							*
						</span>
					</Label>
					<div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
						<Controller
							control={control}
							name="mobilePhoneCode"
							rules={{ required: "Please select a country code." }}
							render={({ field }) => (
								<Select
									value={field.value}
									onValueChange={field.onChange}
									disabled={disabled}
								>
									<SelectTrigger
										id="mobilePhoneCode"
										aria-label="Mobile phone country code"
										aria-invalid={errors.mobilePhoneCode ? true : undefined}
										className="w-full"
									>
										<SelectValue placeholder="Country code" />
									</SelectTrigger>
									<SelectContent>
										{phoneCodeOptions.map((option) => (
											<SelectItem key={option.value} value={option.value}>
												{option.label}
											</SelectItem>
										))}
									</SelectContent>
								</Select>
							)}
						/>
						<div className="sm:col-span-2">
							<Input
								id="mobilePhone"
								type="tel"
								inputMode="numeric"
								autoComplete="tel"
								disabled={disabled}
								aria-invalid={errors.mobilePhone ? true : undefined}
								{...register("mobilePhone", {
									required: "Please enter a mobile phone number.",
									pattern: {
										value: PHONE_PATTERN,
										message: "Please enter between 7 and 15 numbers.",
									},
								})}
							/>
						</div>
					</div>
					<FieldError
						message={
							errors.mobilePhoneCode?.message ?? errors.mobilePhone?.message
						}
					/>
					<p className="text-caption text-muted-foreground">
						{SMS_COPY.notice}
					</p>
				</div>

				{/*
				 * Separate from the notice above it, and separately consented to:
				 * that one explains the exam-critical messages a candidate cannot
				 * opt out of, this one is a marketing opt-in that starts unticked.
				 * The payload has always carried `smsPromotionalUpdates`; until now
				 * nothing set it, so every registration silently sent `false`.
				 */}
				<div className="flex flex-col gap-2 sm:col-span-2">
					<p className="text-body font-bold">{SMS_COPY.promotionalHeading}</p>
					<Controller
						control={control}
						name="smsPromotionalUpdates"
						render={({ field }) => (
							<div className="flex items-start gap-3">
								<Checkbox
									id="smsPromotionalUpdates"
									checked={field.value}
									onCheckedChange={(next) => field.onChange(next === true)}
									disabled={disabled}
									className="mt-0.5"
								/>
								<Label
									htmlFor="smsPromotionalUpdates"
									className="text-body leading-5 font-normal"
								>
									{SMS_COPY.promotionalOptIn}
								</Label>
							</div>
						)}
					/>
				</div>
			</CardContent>
		</Card>
	)
}

export { YourDetailsSection }
