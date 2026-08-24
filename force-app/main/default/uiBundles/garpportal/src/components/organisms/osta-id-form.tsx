import { useId, useState } from "react"
import { Controller, useForm } from "react-hook-form"
import { ShieldCheck } from "lucide-react"

import type { OstaIdInput } from "@/api/osta"
import { Button } from "@/components/atoms/button"
import { Checkbox } from "@/components/atoms/checkbox"
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
import { OSTA_ID_TYPES } from "@/config/osta"
import { useCountryOptions } from "@/hooks/use-country-options"
import { useOsta, useSaveOsta } from "@/hooks/use-osta"
import { toDateInputValue, toUsDateString } from "@/lib/osta-presentation"

type OstaIdFormValues = {
	idType: string
	idLocation: string
	idNumber: string
	/** `yyyy-MM-dd` from the date input; converted on submit. */
	idExpireDate: string
	ostaConsent: boolean
}

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
	error,
	hint,
	children,
}: {
	id: string
	label: string
	error?: string
	hint?: string
	children: React.ReactNode
}) {
	return (
		<div className="space-y-1.5">
			<Label htmlFor={id} className="text-sm">
				{label}
				<span className="text-destructive" aria-hidden>
					{" "}
					*
				</span>
			</Label>
			{children}
			{hint && !error ? (
				<p className="text-xs text-muted-foreground">{hint}</p>
			) : null}
			<FieldError message={error} />
		</div>
	)
}

function OstaIdFormSkeleton() {
	return (
		<div className="space-y-4 px-6 py-4" aria-busy>
			{Array.from({ length: 4 }).map((_, index) => (
				<div key={index} className="space-y-1.5">
					<Skeleton className="h-4 w-24" />
					<Skeleton className="h-9 w-full rounded-xl" />
				</div>
			))}
		</div>
	)
}

type OstaIdFormProps = {
	onSaved: () => void
	onCancel: () => void
}

/**
 * Government ID for a candidate sitting at an OSTA test centre.
 *
 * Two things that look like bugs and are not, both inherited deliberately from
 * the service:
 *
 * 1. **The ID number field starts empty**, with the stored value shown only as
 *    "currently ending {last five}". The read returns just those five
 *    characters — the full number never leaves the org — and Apex writes
 *    whatever it is sent as the full ID. Pre-filling the field with the masked
 *    value would let an unedited save truncate a real ID to five characters.
 * 2. **Consent starts unticked every visit.** `ostaConsent` always reads back
 *    false even once given, which is defensible for a consent tick.
 */
function OstaIdForm({ onSaved, onCancel }: OstaIdFormProps) {
	const formId = useId()
	const [showNumber, setShowNumber] = useState(false)
	const existing = useOsta()
	const countries = useCountryOptions()
	const mutation = useSaveOsta()

	const onFile = existing.data?.ostaIdInfo ?? null
	const {
		control,
		register,
		handleSubmit,
		formState: { errors, isSubmitting },
	} = useForm<OstaIdFormValues>({
		defaultValues: {
			idType: "",
			idLocation: "",
			idNumber: "",
			idExpireDate: "",
			ostaConsent: false,
		},
		values: {
			idType: onFile?.idType ?? "",
			idLocation: onFile?.idLocation ?? "",
			// Deliberately never seeded — see the note above.
			idNumber: "",
			// The expiry IS seeded: unlike the number it comes back in full, so
			// re-confirming an ID does not mean retyping a date that is correct.
			idExpireDate: toDateInputValue(onFile?.idExpireDate),
			ostaConsent: false,
		},
		mode: "onSubmit",
	})

	const countryOptions = countries.data ?? []
	const isBusy = isSubmitting || mutation.isPending

	const onSubmit = async (values: OstaIdFormValues) => {
		const input: OstaIdInput = {
			idType: values.idType,
			idLocation: values.idLocation,
			idNumber: values.idNumber.trim(),
			// Apex parses MM/dd/yyyy; the date input speaks yyyy-MM-dd.
			idExpireDate: toUsDateString(values.idExpireDate),
			ostaConsent: values.ostaConsent === true,
		}
		try {
			await mutation.mutateAsync(input)
			onSaved()
		} catch {
			// Toast comes from the shared MutationCache.
		}
	}

	if (existing.isLoading) return <OstaIdFormSkeleton />

	return (
		<form
			onSubmit={(event) => void handleSubmit(onSubmit)(event)}
			className="flex min-h-0 flex-1 flex-col"
		>
			<div className="min-h-0 flex-1 space-y-4 overflow-y-auto px-6 py-4">
				<Controller
					control={control}
					name="idType"
					rules={{ required: "An ID type is required." }}
					render={({ field }) => (
						<Field
							id={`${formId}-type`}
							label="ID type"
							error={errors.idType?.message}
						>
							<Select
								/*
								 * Remount when the stored value arrives. The query is
								 * deliberately uncached, so the form mounts with an empty
								 * value and fills in a moment later — and Radix keeps
								 * showing the placeholder unless the trigger is rebuilt.
								 * Same workaround as the country selects.
								 */
								key={`osta-type-${field.value || "empty"}`}
								value={field.value || undefined}
								onValueChange={field.onChange}
							>
								<SelectTrigger id={`${formId}-type`} className="w-full">
									<SelectValue placeholder="Select an ID type" />
								</SelectTrigger>
								<SelectContent>
									{OSTA_ID_TYPES.map((type) => (
										<SelectItem key={type} value={type}>
											{type}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</Field>
					)}
				/>

				<Controller
					control={control}
					name="idLocation"
					rules={{ required: "An issuing country is required." }}
					render={({ field }) => (
						<Field
							id={`${formId}-location`}
							label="Issued in"
							error={errors.idLocation?.message}
						>
							<Select
								key={`osta-country-${countryOptions.length}-${field.value || "empty"}`}
								value={field.value || undefined}
								onValueChange={field.onChange}
								disabled={countryOptions.length === 0}
							>
								<SelectTrigger id={`${formId}-location`} className="w-full">
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
					id={`${formId}-number`}
					label="ID number"
					error={errors.idNumber?.message}
					hint={
						onFile?.idNumber
							? `Currently ending ${onFile.idNumber}. Enter the full number to change it.`
							: "Enter the number exactly as it appears on your ID."
					}
				>
					<div className="flex gap-2">
						<Input
							id={`${formId}-number`}
							type={showNumber ? "text" : "password"}
							autoComplete="off"
							{...register("idNumber", {
								required: "Your ID number is required.",
							})}
						/>
						<Button
							type="button"
							variant="outline"
							size="sm"
							onClick={() => setShowNumber((current) => !current)}
						>
							{showNumber ? "Hide" : "Show"}
						</Button>
					</div>
				</Field>

				<Field
					id={`${formId}-expiry`}
					label="Expiry date"
					error={errors.idExpireDate?.message}
				>
					<Input
						id={`${formId}-expiry`}
						type="date"
						{...register("idExpireDate", {
							required: "An expiry date is required.",
						})}
					/>
				</Field>

				<Controller
					control={control}
					name="ostaConsent"
					rules={{
						validate: (value) =>
							value === true ||
							"You must consent before these details can be saved.",
					}}
					render={({ field }) => (
						<div className="space-y-1.5">
							<div className="flex items-start gap-2">
								<Checkbox
									id={`${formId}-consent`}
									checked={field.value === true}
									onCheckedChange={(next) => field.onChange(next === true)}
								/>
								<Label
									htmlFor={`${formId}-consent`}
									className="text-sm font-normal leading-snug"
								>
									I consent to GARP sharing these identity details with the OSTA
									test centre so my exam can be scheduled.
								</Label>
							</div>
							<FieldError message={errors.ostaConsent?.message} />
						</div>
					)}
				/>

				<p className="flex items-start gap-2 text-xs text-muted-foreground">
					<ShieldCheck className="mt-0.5 size-4 shrink-0" aria-hidden />
					Your full ID number is stored for the test centre and is never shown
					back to you — only its last five characters.
				</p>
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
					{isBusy ? "Saving…" : "Save identity details"}
				</Button>
			</DialogFooter>
		</form>
	)
}

export { OstaIdForm }
