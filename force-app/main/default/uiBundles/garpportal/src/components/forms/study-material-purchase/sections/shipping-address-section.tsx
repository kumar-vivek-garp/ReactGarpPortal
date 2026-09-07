import { MapPin } from "lucide-react"
import {
	Controller,
	useWatch,
	type Control,
	type FieldErrors,
	type UseFormRegister,
} from "react-hook-form"

import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { FormField } from "@/components/molecules/form-field"
import type { PurchaseFormValues } from "@/components/forms/study-material-purchase/purchase-form-values"
import { STUDY_MATERIAL_PURCHASE } from "@/config/study-materials"
import { shippingCountryDiffers } from "@/lib/study-material-checkout"

type ShippingAddressSectionProps = {
	register: UseFormRegister<PurchaseFormValues>
	control: Control<PurchaseFormValues>
	errors: FieldErrors<PurchaseFormValues>
	/** Country NAMES GARP will post to. Empty means "no restriction known". */
	shippableCountries: string[]
	/** The country the quote was priced for. */
	recordCountry: string | null
	disabled?: boolean
}

/**
 * Where to post the book.
 *
 * Not the exam form's address block: that one is keyed to country CODES with
 * per-country province and postal rules, and this form has country NAMES, no
 * province data, one address and a shippable-countries restriction. Only
 * street, city and country are required — Apex `isPostable` checks exactly
 * those, and demanding a province a country lacks would block a legitimate
 * address.
 *
 * Plain `required` rules are safe here: the section only mounts when the
 * quote says the item ships, and that cannot change for a loaded quote — so
 * no rule is ever switched off after registration.
 */
function ShippingAddressSection({
	register,
	control,
	errors,
	shippableCountries,
	recordCountry,
	disabled,
}: ShippingAddressSectionProps) {
	const chosenCountry = useWatch({ control, name: "country" })
	const countryChanged = shippingCountryDiffers(recordCountry, chosenCountry)

	return (
		<Card className="shadow-none">
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<MapPin className="size-5 text-muted-foreground" aria-hidden />
					{STUDY_MATERIAL_PURCHASE.addressHeading}
				</CardTitle>
				<p className="text-body text-muted-foreground">
					{STUDY_MATERIAL_PURCHASE.addressIntro}
				</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				<FormField id="ship-company" label="Company" className="sm:col-span-2">
					<Input
						id="ship-company"
						autoComplete="organization"
						maxLength={255}
						disabled={disabled}
						{...register("company")}
					/>
				</FormField>

				<FormField
					id="ship-street"
					label="Street address"
					required
					error={errors.street?.message}
					className="sm:col-span-2"
				>
					<Input
						id="ship-street"
						autoComplete="address-line1"
						maxLength={255}
						disabled={disabled}
						aria-invalid={errors.street ? true : undefined}
						{...register("street", { required: "Street address is required." })}
					/>
				</FormField>

				<FormField id="ship-street2" label="Address line 2" className="sm:col-span-2">
					<Input
						id="ship-street2"
						autoComplete="address-line2"
						maxLength={255}
						disabled={disabled}
						{...register("street2")}
					/>
				</FormField>

				<FormField
					id="ship-city"
					label="City"
					required
					error={errors.city?.message}
				>
					<Input
						id="ship-city"
						autoComplete="address-level2"
						maxLength={255}
						disabled={disabled}
						aria-invalid={errors.city ? true : undefined}
						{...register("city", { required: "City is required." })}
					/>
				</FormField>

				<FormField id="ship-state" label="State / Province">
					<Input
						id="ship-state"
						autoComplete="address-level1"
						maxLength={255}
						disabled={disabled}
						{...register("state")}
					/>
				</FormField>

				<FormField id="ship-postalCode" label="Postal code">
					<Input
						id="ship-postalCode"
						autoComplete="postal-code"
						maxLength={255}
						disabled={disabled}
						{...register("postalCode")}
					/>
				</FormField>

				<FormField
					id="ship-country"
					label="Country"
					required
					error={errors.country?.message}
					hint={countryChanged ? STUDY_MATERIAL_PURCHASE.countryChangedHint : undefined}
				>
					{shippableCountries.length > 0 ? (
						<Controller
							control={control}
							name="country"
							rules={{ required: "Country is required." }}
							render={({ field }) => (
								<Select
									// Never `undefined` — that latches Radix into uncontrolled
									// mode and the placeholder sticks.
									value={field.value ?? ""}
									onValueChange={field.onChange}
									disabled={disabled}
								>
									<SelectTrigger
										id="ship-country"
										aria-invalid={errors.country ? true : undefined}
										className="w-full"
									>
										<SelectValue placeholder="Select country" />
									</SelectTrigger>
									<SelectContent>
										{shippableCountries.map((name) => (
											<SelectItem key={name} value={name}>
												{name}
											</SelectItem>
										))}
									</SelectContent>
								</Select>
							)}
						/>
					) : (
						/* No list to restrict by — free text so nobody is stranded. */
						<Input
							id="ship-country"
							autoComplete="country-name"
							maxLength={255}
							disabled={disabled}
							aria-invalid={errors.country ? true : undefined}
							{...register("country", { required: "Country is required." })}
						/>
					)}
				</FormField>

				<FormField id="ship-phone" label="Phone" className="sm:col-span-2">
					<Input
						id="ship-phone"
						type="tel"
						autoComplete="tel"
						maxLength={255}
						disabled={disabled}
						{...register("phone")}
					/>
				</FormField>
			</CardContent>
		</Card>
	)
}

export { ShippingAddressSection }
