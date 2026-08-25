import { MapPin } from "lucide-react"

import { useMemo } from "react"
import {
	Controller,
	type Control,
	type FieldErrors,
	type UseFormRegister,
} from "react-hook-form"

import type { RegistrationCountry } from "@/api/registration/exam-types"
import { Checkbox } from "@/components/atoms/checkbox"
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
import { FormField } from "@/components/molecules/form-field"
import type { FrmFormValues } from "@/components/forms/frm/frm-form-values"

type AddressBlockProps = {
	prefix: "billing" | "shipping"
	title: string
	register: UseFormRegister<FrmFormValues>
	control: Control<FrmFormValues>
	errors: FieldErrors<FrmFormValues>
	countries: RegistrationCountry[]
	/**
	 * Billing only. The billing country decides which payment methods are
	 * permitted, so changing it here has the same consequences as changing it
	 * in the Location field — the shipping country decides nothing.
	 */
	onCountryChange?: (countryCode: string) => void
	/** A mirrored shipping address is shown read-only rather than hidden. */
	disabled?: boolean
}

/**
 * One address, parameterised by which one.
 *
 * Required-ness is expressed as `disabled ? false : "…"` so a mirrored
 * shipping address goes inert rather than being unregistered — the values
 * still submit (they are a copy of billing), they just stop being demanded.
 *
 * Only street, city, country and postal code are required. Apex checks the
 * COUNTRY alone, so everything else here is our rule, and asking for a
 * province the country does not use would block a legitimate address.
 */
function AddressBlock({
	prefix,
	title,
	register,
	control,
	errors,
	countries,
	onCountryChange,
	disabled,
}: AddressBlockProps) {
	const sectionErrors = errors[prefix]
	const sorted = useMemo(
		() => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
		[countries],
	)
	const required = (message: string) => (disabled ? false : message)

	return (
		<div className="flex flex-col gap-4">
			<p className="text-body font-bold">{title}</p>

			<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				<FormField
					id={`${prefix}-company`}
					label="Company"
					className="sm:col-span-2"
				>
					<Input
						id={`${prefix}-company`}
						autoComplete="organization"
						disabled={disabled}
						{...register(`${prefix}.company`)}
					/>
				</FormField>

				<FormField
					id={`${prefix}-street1`}
					label="Street address"
					required={!disabled}
					error={sectionErrors?.street1?.message}
					className="sm:col-span-2"
				>
					<Input
						id={`${prefix}-street1`}
						autoComplete="address-line1"
						disabled={disabled}
						aria-invalid={sectionErrors?.street1 ? true : undefined}
						{...register(`${prefix}.street1`, {
							required: required("Street address is required."),
						})}
					/>
				</FormField>

				<FormField
					id={`${prefix}-street2`}
					label="Street address 2"
					className="sm:col-span-2"
				>
					<Input
						id={`${prefix}-street2`}
						autoComplete="address-line2"
						disabled={disabled}
						{...register(`${prefix}.street2`)}
					/>
				</FormField>

				<FormField
					id={`${prefix}-city`}
					label="City"
					required={!disabled}
					error={sectionErrors?.city?.message}
				>
					<Input
						id={`${prefix}-city`}
						autoComplete="address-level2"
						disabled={disabled}
						aria-invalid={sectionErrors?.city ? true : undefined}
						{...register(`${prefix}.city`, {
							required: required("City is required."),
						})}
					/>
				</FormField>

				{/*
				 * Free text and never required. There is no per-country table of
				 * which places use a province — Apex is the authority and refuses
				 * what it will not accept, so demanding one here would block
				 * addresses that are perfectly valid.
				 */}
				<FormField id={`${prefix}-province`} label="State / Province">
					<Input
						id={`${prefix}-province`}
						autoComplete="address-level1"
						disabled={disabled}
						{...register(`${prefix}.province`)}
					/>
				</FormField>

				<FormField
					id={`${prefix}-postalCode`}
					label="Postal code"
					required={!disabled}
					error={sectionErrors?.postalCode?.message}
				>
					<Input
						id={`${prefix}-postalCode`}
						autoComplete="postal-code"
						disabled={disabled}
						aria-invalid={sectionErrors?.postalCode ? true : undefined}
						{...register(`${prefix}.postalCode`, {
							required: required("Postal code is required."),
						})}
					/>
				</FormField>

				<FormField
					id={`${prefix}-country`}
					label="Country"
					required={!disabled}
					error={sectionErrors?.country?.message}
				>
					<Controller
						control={control}
						name={`${prefix}.country`}
						rules={{ required: required("Country is required.") }}
						render={({ field }) => (
							<Select
								// `value` is always a string, never undefined: handing Radix
								// `undefined` latches the Select into uncontrolled mode and
								// every later value is ignored.
								value={field.value ?? ""}
								onValueChange={(next) => {
									field.onChange(next)
									onCountryChange?.(next)
								}}
								disabled={disabled}
							>
								<SelectTrigger
									id={`${prefix}-country`}
									aria-invalid={sectionErrors?.country ? true : undefined}
									className="w-full"
								>
									<SelectValue placeholder="Select country" />
								</SelectTrigger>
								<SelectContent>
									{sorted.map((country) => (
										<SelectItem key={country.id} value={country.countryCode}>
											{country.name}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						)}
					/>
				</FormField>
			</div>
		</div>
	)
}

type AddressesSectionProps = {
	register: UseFormRegister<FrmFormValues>
	control: Control<FrmFormValues>
	errors: FieldErrors<FrmFormValues>
	countries: RegistrationCountry[]
	sameAsBilling: boolean
	onSameAsBillingChange: (next: boolean) => void
	/** Applied to the billing block only — see `AddressBlockProps`. */
	onCountryChange: (countryCode: string) => void
	disabled?: boolean
}

/**
 * Where to bill, and where to ship.
 *
 * Only shown for wire and ACH. A card order collects its address on Stripe's
 * own checkout page, so asking here as well would be two chances to disagree
 * about the same fact.
 */
function AddressesSection({
	register,
	control,
	errors,
	countries,
	sameAsBilling,
	onSameAsBillingChange,
	onCountryChange,
	disabled,
}: AddressesSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<MapPin className="size-5 text-muted-foreground" aria-hidden />
					Billing &amp; shipping
				</CardTitle>
				<p className="text-body text-muted-foreground">
					Needed for wire and ACH orders so finance can raise your invoice.
				</p>
			</CardHeader>
			<CardContent className="flex flex-col gap-6">
				<AddressBlock
					prefix="billing"
					title="Billing address"
					register={register}
					control={control}
					errors={errors}
					countries={countries}
					onCountryChange={onCountryChange}
					disabled={disabled}
				/>

				<div className="flex items-start gap-3 border-t border-border pt-4">
					<Checkbox
						id="billingAndShippingSame"
						checked={sameAsBilling}
						onCheckedChange={(next) => onSameAsBillingChange(next === true)}
						disabled={disabled}
						className="mt-0.5"
					/>
					<Label
						htmlFor="billingAndShippingSame"
						className="text-body leading-5 font-normal"
					>
						My shipping address is the same as my billing address
					</Label>
				</div>

				{!sameAsBilling ? (
					<AddressBlock
						prefix="shipping"
						title="Shipping address"
						register={register}
						control={control}
						errors={errors}
						countries={countries}
						disabled={disabled}
					/>
				) : null}
			</CardContent>
		</Card>
	)
}

export { AddressesSection }
