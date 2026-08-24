import { useId } from "react"
import { Controller, useForm } from "react-hook-form"

import { emptyAddress } from "@/api/personal-info/address-utils"
import type { AddressFormFields } from "@/api/personal-info/types"
import type { CvView } from "@/api/work-experience"
import { Button } from "@/components/atoms/button"
import { DialogFooter } from "@/components/atoms/dialog"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { Skeleton } from "@/components/atoms/skeleton"
import { useCountryOptions } from "@/hooks/use-country-options"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useSaveCvAddress } from "@/hooks/use-cv"
import { usePersonalInfoEditData } from "@/hooks/use-personal-info-edit-data"
import {
	hasChineseCharacters,
	toCvAddressPayload,
	toCvOstaFormValues,
	type CvOstaFormValues,
} from "@/lib/work-experience-presentation"

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

function Field({
	id,
	label,
	required,
	error,
	children,
}: {
	id: string
	label: string
	required?: boolean
	error?: string
	children: React.ReactNode
}) {
	return (
		<div className="space-y-1.5">
			<Label htmlFor={id} className="text-sm">
				{label}
				{required ? (
					<span className="text-destructive" aria-hidden>
						{" "}
						*
					</span>
				) : null}
			</Label>
			{children}
			<FieldError message={error} />
		</div>
	)
}

/**
 * The Chinese-character block, shown only to a candidate with an active OSTA
 * contract.
 *
 * Every field requires Han characters because the address goes to the Chinese
 * postal service — but the check is "contains Chinese", not "contains only
 * Chinese", so a building or unit number does not fail it. The legacy rejected
 * any non-Chinese character at all, which a street number trips.
 *
 * There is no postal code here and no country field: `saveAddress` reads
 * neither for the OSTA block, and `GET cv` hard-codes the country to "China".
 */
function OstaAddressFields({
	formId,
	form,
}: {
	formId: string
	form: {
		register: ReturnType<typeof useForm<CvAddressFormValues>>["register"]
		errors: ReturnType<
			typeof useForm<CvAddressFormValues>
		>["formState"]["errors"]
	}
}) {
	const { register, errors } = form
	const ostaErrors = errors.osta
	const chinese = (label: string) => ({
		required: `${label} is required.`,
		validate: (value: string) =>
			hasChineseCharacters(value) || `Please enter ${label.toLowerCase()} in Chinese.`,
	})

	const fields = [
		{ name: "recipient", label: "Recipient name" },
		{ name: "province", label: "Province" },
		{ name: "city", label: "City" },
		{ name: "district", label: "District" },
		{ name: "town", label: "Building or village" },
		{ name: "street", label: "Street address" },
	] as const

	return (
		<section
			// Named because "City" and "Phone" also label fields in the mailing
			// address above; the group is what tells them apart in a screen reader.
			aria-labelledby={`${formId}-osta-heading`}
			className="space-y-4 rounded-lg border border-border bg-muted/20 p-4"
		>
			<div>
				<h3
					id={`${formId}-osta-heading`}
					className="font-heading text-sm font-semibold tracking-wide text-foreground"
				>
					Chinese delivery address
				</h3>
				<p className="mt-1 text-xs text-muted-foreground">
					This address is shared with OSTA and used to post your certificate
					within China. Please enter it in Chinese.
				</p>
			</div>

			<div className="grid gap-4 sm:grid-cols-2">
				{fields.map((field) => (
					<Field
						key={field.name}
						id={`${formId}-osta-${field.name}`}
						label={field.label}
						required
						error={ostaErrors?.[field.name]?.message}
					>
						<Input
							id={`${formId}-osta-${field.name}`}
							{...register(`osta.${field.name}`, chinese(field.label))}
						/>
					</Field>
				))}
			</div>

			<Field
				id={`${formId}-osta-phone`}
				label="Phone in China"
				required
				error={ostaErrors?.phone?.message}
			>
				<Input
					id={`${formId}-osta-phone`}
					{...register("osta.phone", {
						required: "A phone number in China is required.",
					})}
				/>
			</Field>
		</section>
	)
}

function CvAddressFormSkeleton() {
	return (
		<div className="space-y-4 px-6 py-4" aria-busy>
			{Array.from({ length: 5 }).map((_, index) => (
				<div key={index} className="space-y-1.5">
					<Skeleton className="h-4 w-24" />
					<Skeleton className="h-9 w-full rounded-xl" />
				</div>
			))}
		</div>
	)
}

type CvAddressFormProps = {
	/** Drives the OSTA block — `isOSTA` and the seeded Chinese address. */
	view: CvView | null
	onSaved: () => void
	onCancel: () => void
}

type CvAddressFormValues = AddressFormFields & { osta: CvOstaFormValues }

/**
 * Where GARP posts the certificate.
 *
 * Seeded from the **personal-info** payload rather than from `GET cv`, and
 * that is not incidental. `cvAddress` writes the member's own Contact mailing
 * fields and assigns all seven unconditionally, so anything the form does not
 * send is nulled — and `GET cv` returns neither `company` nor `phone`. Seeding
 * from the CV view would quietly wipe both the first time a member touched
 * this screen.
 *
 * State / province is free text and postal code is required for everyone. The
 * legacy decided both from a loop over every country in its list, so the last
 * row won rather than the selected one, and `setValidators` destroyed the
 * length and character rules on the way past. There is no per-country table
 * here; Apex is the authority and its refusal is surfaced.
 */
function CvAddressForm({ view, onSaved, onCancel }: CvAddressFormProps) {
	const formId = useId()
	const { data: user } = useCurrentUser()
	const contactId = user?.contactId ?? ""

	const editData = usePersonalInfoEditData(contactId, Boolean(contactId))
	const countries = useCountryOptions(Boolean(contactId))
	const mutation = useSaveCvAddress()

	const isOsta = view?.isOSTA === true
	const seeded = editData.data?.mailing
	const {
		control,
		register,
		handleSubmit,
		formState: { errors, isSubmitting },
	} = useForm<CvAddressFormValues>({
		defaultValues: { ...emptyAddress(), osta: toCvOstaFormValues(null) },
		values: {
			...(seeded ?? emptyAddress()),
			osta: toCvOstaFormValues(view),
		},
		mode: "onSubmit",
	})

	const countryOptions = countries.data ?? []
	const isBusy = isSubmitting || mutation.isPending

	const onSubmit = async (values: CvAddressFormValues) => {
		try {
			await mutation.mutateAsync(
				toCvAddressPayload(values, isOsta ? values.osta : null),
			)
			onSaved()
		} catch {
			// Toast comes from the shared MutationCache.
		}
	}

	if (editData.isLoading) return <CvAddressFormSkeleton />

	return (
		<form
			onSubmit={(event) => void handleSubmit(onSubmit)(event)}
			className="flex min-h-0 flex-1 flex-col"
		>
			<div className="min-h-0 flex-1 space-y-4 overflow-y-auto px-6 py-4">
				<Field id={`${formId}-company`} label="Company">
					<Input id={`${formId}-company`} {...register("company")} />
				</Field>

				<Field
					id={`${formId}-address1`}
					label="Address line 1"
					required
					error={errors.address1?.message}
				>
					<Input
						id={`${formId}-address1`}
						{...register("address1", { required: "An address is required." })}
					/>
				</Field>

				<div className="grid gap-4 sm:grid-cols-2">
					<Field id={`${formId}-address2`} label="Address line 2">
						<Input id={`${formId}-address2`} {...register("address2")} />
					</Field>
					<Field id={`${formId}-address3`} label="Address line 3">
						<Input id={`${formId}-address3`} {...register("address3")} />
					</Field>
				</div>

				<div className="grid gap-4 sm:grid-cols-2">
					<Controller
						control={control}
						name="country"
						rules={{ required: "A country is required." }}
						render={({ field }) => (
							<Field
								id={`${formId}-country`}
								label="Country"
								required
								error={errors.country?.message}
							>
								<Select
									// Remount once options arrive so a pre-set value is applied
									// after Radix has matching items to match it against.
									key={`country-${countryOptions.length}-${field.value || "empty"}`}
									value={field.value || undefined}
									onValueChange={field.onChange}
									disabled={countryOptions.length === 0}
								>
									<SelectTrigger id={`${formId}-country`} className="w-full">
										<SelectValue placeholder="Select country" />
									</SelectTrigger>
									<SelectContent>
										{countryOptions.map((option) => (
											<SelectItem key={option.value} value={option.value}>
												{option.label}
											</SelectItem>
										))}
									</SelectContent>
								</Select>
							</Field>
						)}
					/>
					<Field
						id={`${formId}-city`}
						label="City"
						required
						error={errors.city?.message}
					>
						<Input
							id={`${formId}-city`}
							{...register("city", { required: "A city is required." })}
						/>
					</Field>
				</div>

				<div className="grid gap-4 sm:grid-cols-2">
					<Field id={`${formId}-state`} label="State / Province">
						<Input id={`${formId}-state`} {...register("state")} />
					</Field>
					<Field
						id={`${formId}-postal`}
						label="Postal code"
						required
						error={errors.postalCode?.message}
					>
						<Input
							id={`${formId}-postal`}
							{...register("postalCode", {
								required: "A postal code is required.",
							})}
						/>
					</Field>
				</div>

				<Field id={`${formId}-phone`} label="Phone">
					<Input id={`${formId}-phone`} {...register("phone")} />
				</Field>

				<p className="text-xs text-muted-foreground">
					This is your mailing address on file with GARP — saving it here
					updates it in My Account too.
				</p>

				{isOsta ? <OstaAddressFields formId={formId} form={{ register, errors }} /> : null}
			</div>

			<DialogFooter className="shrink-0 border-t border-border px-6 py-4 sm:justify-end">
				<Button
					type="button"
					variant="outline"
					onClick={onCancel}
					disabled={isBusy}
				>
					Cancel
				</Button>
				<Button type="submit" disabled={isBusy}>
					{isBusy ? "Saving…" : "Save address"}
				</Button>
			</DialogFooter>
		</form>
	)
}

export { CvAddressForm }
