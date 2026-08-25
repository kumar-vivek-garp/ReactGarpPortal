import { useMemo } from "react"
import {
	Controller,
	type Control,
	type FieldErrors,
	type UseFormRegister,
} from "react-hook-form"

import type { RegistrationCountry } from "@/api/registration/exam-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
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
				<CardTitle className="text-lg">Your details</CardTitle>
				<p className="text-body text-muted-foreground">
					{isAuthenticated
						? "Prefilled from your account. Anything you change here is saved with your registration."
						: "We will use these details to create your GARP account and to contact you about the exam."}
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
			</CardContent>
		</Card>
	)
}

export { YourDetailsSection }
