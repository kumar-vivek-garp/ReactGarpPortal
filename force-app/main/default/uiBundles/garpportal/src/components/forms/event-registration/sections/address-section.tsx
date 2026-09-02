import { MapPin } from "lucide-react"
import { useMemo } from "react"
import {
	Controller,
	type Control,
	type FieldErrors,
	type UseFormRegister,
} from "react-hook-form"

import type { EventCountry } from "@/api/registration/event-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { FormField } from "@/components/molecules/form-field"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import {
	isPostalCodeRequired,
	isProvinceRequired,
	POSTAL_DIGITS_PATTERN,
} from "@/lib/event-registration-presentation"

type AddressSectionProps = {
	register: UseFormRegister<EventFormValues>
	control: Control<EventFormValues>
	errors: FieldErrors<EventFormValues>
	countries: EventCountry[]
	findCountry: (value: string) => EventCountry | null
}

/**
 * The webcast's "Your Location" card — the only variant whose registration
 * object stores an address.
 *
 * Province and postal code become required by the SELECTED country's flags —
 * enforced through `validate` closures reading the live form values, never a
 * toggled `rules` object (RHF registers rules once and never re-reads them).
 * The postal code is digits-only because the Salesforce field is a Number;
 * the deployed client only says so in the label.
 */
function AddressSection({
	register,
	control,
	errors,
	countries,
	findCountry,
}: AddressSectionProps) {
	const sortedCountries = useMemo(
		() => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
		[countries],
	)

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<MapPin className="size-5 text-muted-foreground" aria-hidden />
					Your location
				</CardTitle>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				<FormField
					id="event-reg-country"
					label="Country"
					required
					error={errors.country?.message}
					className="sm:col-span-2"
				>
					<Controller
						control={control}
						name="country"
						rules={{ required: "Please select your country." }}
						render={({ field }) => (
							<Select value={field.value ?? ""} onValueChange={field.onChange}>
								<SelectTrigger
									id="event-reg-country"
									aria-invalid={Boolean(errors.country)}
									className="w-full sm:w-96"
								>
									<SelectValue placeholder="Select country…" />
								</SelectTrigger>
								<SelectContent>
									{sortedCountries.map((country) => (
										<SelectItem
											key={country.id}
											value={country.countryCode || country.name}
										>
											{country.name}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						)}
					/>
				</FormField>

				<FormField id="event-reg-address1" label="Address">
					<Input
						id="event-reg-address1"
						autoComplete="address-line1"
						{...register("address1")}
					/>
				</FormField>

				<FormField id="event-reg-address2" label="Address 2 (optional)">
					<Input
						id="event-reg-address2"
						autoComplete="address-line2"
						{...register("address2")}
					/>
				</FormField>

				<FormField id="event-reg-city" label="City">
					<Input
						id="event-reg-city"
						autoComplete="address-level2"
						{...register("city")}
					/>
				</FormField>

				<FormField
					id="event-reg-province"
					label="State / Province"
					error={errors.province?.message}
				>
					<Input
						id="event-reg-province"
						autoComplete="address-level1"
						aria-invalid={Boolean(errors.province)}
						{...register("province", {
							validate: (value, formValues) =>
								!isProvinceRequired(findCountry(formValues.country)) ||
								Boolean(value.trim()) ||
								"A state or province is required for this country.",
						})}
					/>
				</FormField>

				<FormField
					id="event-reg-postal"
					label="Postal code"
					error={errors.postalCode?.message}
					hint="Digits only."
				>
					<Input
						id="event-reg-postal"
						autoComplete="postal-code"
						inputMode="numeric"
						aria-invalid={Boolean(errors.postalCode)}
						{...register("postalCode", {
							validate: (value, formValues) => {
								const trimmed = value.trim()
								if (
									isPostalCodeRequired(findCountry(formValues.country)) &&
									!trimmed
								) {
									return "A postal code is required for this country."
								}
								if (trimmed && !POSTAL_DIGITS_PATTERN.test(trimmed)) {
									return "Postal code must be digits only."
								}
								return true
							},
						})}
					/>
				</FormField>
			</CardContent>
		</Card>
	)
}

export { AddressSection }
