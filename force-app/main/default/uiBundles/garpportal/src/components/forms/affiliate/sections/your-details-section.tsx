import { useMemo } from "react"
import {
	Controller,
	type Control,
	type FieldErrors,
	type UseFormRegister,
} from "react-hook-form"
import { UserRound } from "lucide-react"

import type { RegistrationCountry } from "@/api/registration"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
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
import type { AffiliateFormValues } from "@/components/forms/affiliate/affiliate-form-values"
import {
	EMAIL_PATTERN,
	PHONE_PATTERN,
	REGISTRATION_LIMITS,
	SMS_COPY,
	isEnglishName,
} from "@/config/registration"

type YourDetailsSectionProps = {
	register: UseFormRegister<AffiliateFormValues>
	control: Control<AffiliateFormValues>
	errors: FieldErrors<AffiliateFormValues>
	countries: RegistrationCountry[]
	/**
	 * The identity check GarpAppv1 runs on blur, so somebody who already has an
	 * account is told before filling the rest of the form rather than at submit.
	 * Wired to all three of first name, last name and email because the check
	 * sends all three.
	 */
	onIdentityBlur: React.FocusEventHandler<HTMLInputElement>
	disabled?: boolean
}

/**
 * Who is signing up.
 *
 * Nothing is prefilled and nothing can be: the route is guest-only, so there
 * is no contact record behind these fields — creating one is what the form
 * does.
 *
 * The name rules are the legacy `englishNameValidation` directive, enforced
 * character-for-character via `isEnglishName`. They are not cosmetic: the
 * values land on a Contact that GARP's own systems read back.
 */
function YourDetailsSection({
	register,
	control,
	errors,
	countries,
	onIdentityBlur,
	disabled,
}: YourDetailsSectionProps) {
	const sortedCountries = useMemo(
		() => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
		[countries],
	)

	/**
	 * Only countries that actually carry a dial code. The value format is
	 * GarpAppv1's: `"<countryCode> (+<phoneCode>)"` — Apex reads the digits back
	 * out of it, so the country half has to travel with them.
	 */
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
					Your details
				</CardTitle>
				<p className="text-body text-muted-foreground">
					We will use these details to create your GARP account and to contact
					you about membership.
				</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				{/*
				 * Names lead so that by the time the email field blurs and fires the
				 * identity check, there is a first and last name to send with it.
				 */}
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
							required: "Please enter your first name / given name.",
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
							required: "Please enter your last name / surname.",
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
					label="Email address"
					required
					error={errors.email?.message}
					hint="This becomes your GARP sign-in."
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

				<FormField
					id="country"
					label="Location"
					required
					error={errors.country?.message}
				>
					<Controller
						control={control}
						name="country"
						rules={{ required: "Please select your location." }}
						render={({ field }) => (
							/*
							 * `value ?? ""` — never `undefined`. A Radix Select handed
							 * undefined latches into uncontrolled mode and shows its
							 * placeholder for ever, whatever the form then sets.
							 */
							<Select
								value={field.value ?? ""}
								onValueChange={field.onChange}
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

				{/*
				 * Spans the grid: the dial code and the number are one field split
				 * 1:2, so pairing it with anything else would put four controls on a
				 * row. Required on every GarpAppv1 registration kind, affiliate
				 * included.
				 */}
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
									value={field.value ?? ""}
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
									required:
										"Please select a country code and enter a mobile phone number.",
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
			</CardContent>
		</Card>
	)
}

export { YourDetailsSection }
