import { useEffect, useId, useMemo } from "react"
import { Controller, useForm, useWatch } from "react-hook-form"
import type { Control, FieldErrors, UseFormRegister } from "react-hook-form"

import type { CpdActivityFieldInfo, CpdClaim, CpdClaimInput } from "@/api/cpd"
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
import { Textarea } from "@/components/atoms/textarea"
import { CPD_CONTACT_EMAIL } from "@/config/cpd"
import { useAccountOptions } from "@/hooks/use-account-options"
import { useCpdActivityTypes } from "@/hooks/use-cpd-activity-types"
import { useSaveCpdClaim } from "@/hooks/use-save-cpd-claim"
import {
	dynamicFieldsFor,
	findActivityType,
	splitAreaOfStudy,
	toDateInputValue,
	todayInputValue,
	type CpdDynamicFieldName,
} from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

/** Same bounds the legacy form enforced. */
const MIN_CREDITS = 0.5
const MAX_CREDITS = 50
const URL_PATTERN = /.+\..+/
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const AREA_OF_STUDY_FIELD = "Area_of_Study__c"

type CpdClaimFormValues = {
	activityType: string
	dateOfCompletion: string
	credits: string
	areaOfStudy: string[]
	comments: string
	URL: string
} & Record<CpdDynamicFieldName, string>

const EMPTY_FORM_VALUES: CpdClaimFormValues = {
	activityType: "",
	dateOfCompletion: "",
	credits: "",
	areaOfStudy: [],
	comments: "",
	URL: "",
	organizationName: "",
	provider: "",
	publication: "",
	title: "",
	contactEmail: "",
}

function toFormValues(claim: CpdClaim | null): CpdClaimFormValues {
	if (!claim) return EMPTY_FORM_VALUES
	return {
		activityType: claim.activityType ?? "",
		dateOfCompletion: toDateInputValue(claim.dateOfCompletion),
		credits: claim.credits == null ? "" : String(claim.credits),
		areaOfStudy: splitAreaOfStudy(claim.areaOfStudy),
		comments: claim.comments ?? "",
		URL: claim.URL ?? "",
		organizationName: claim.organizationName ?? "",
		// Apex writes the free-text provider and reads it back on either field.
		provider: claim.providerOther ?? claim.provider ?? "",
		publication: claim.publication ?? "",
		title: claim.title ?? "",
		contactEmail: claim.contactEmail ?? "",
	}
}

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

function FormField({
	label,
	htmlFor,
	error,
	children,
	className,
}: {
	label: string
	htmlFor: string
	error?: string
	children: React.ReactNode
	className?: string
}) {
	return (
		<div className={cn("flex flex-col gap-1.5", className)}>
			<Label htmlFor={htmlFor}>{label}</Label>
			{children}
			<FieldError message={error} />
		</div>
	)
}

/** The five admin-configured extras, rebuilt whenever the type changes. */
function DynamicFields({
	activityType,
	formId,
	register,
	errors,
}: {
	activityType: CpdActivityFieldInfo | null
	formId: string
	register: UseFormRegister<CpdClaimFormValues>
	errors: FieldErrors<CpdClaimFormValues>
}) {
	const fields = dynamicFieldsFor(activityType)
	if (fields.length === 0) return null

	return (
		<>
			{fields.map((field) => (
				<FormField
					key={field.name}
					label={field.required ? `${field.label}*` : field.label}
					htmlFor={`${formId}-${field.name}`}
					error={errors[field.name]?.message}
				>
					<Input
						id={`${formId}-${field.name}`}
						type={field.kind === "email" ? "email" : "text"}
						maxLength={field.kind === "email" ? undefined : 255}
						aria-invalid={Boolean(errors[field.name])}
						{...register(field.name, {
							required: field.required
								? `${field.label} is required`
								: false,
							...(field.kind === "email"
								? {
										pattern: {
											value: EMAIL_PATTERN,
											message: `${field.label} must be a valid email address`,
										},
									}
								: {
										minLength: {
											value: 2,
											message: `${field.label} must be at least 2 characters long`,
										},
									}),
						})}
					/>
				</FormField>
			))}
		</>
	)
}

function AreaOfStudyField({
	control,
	options,
	formId,
}: {
	control: Control<CpdClaimFormValues>
	options: { label: string; value: string }[]
	formId: string
}) {
	return (
		<Controller
			control={control}
			name="areaOfStudy"
			render={({ field }) => (
				<div className="flex flex-col gap-1.5">
					<Label htmlFor={`${formId}-areaOfStudy`}>Area of Study</Label>
					<div
						id={`${formId}-areaOfStudy`}
						className="max-h-36 space-y-2 overflow-y-auto rounded-xl border border-input p-3"
					>
						{options.length === 0 ? (
							<p className="text-xs text-muted-foreground">
								No areas of study are configured.
							</p>
						) : (
							options.map((option) => {
								const checked = field.value.includes(option.value)
								return (
									<div key={option.value} className="flex items-center gap-2">
										<Checkbox
											id={`${formId}-aos-${option.value}`}
											checked={checked}
											onCheckedChange={(next) => {
												field.onChange(
													next === true
														? [...field.value, option.value]
														: field.value.filter((v) => v !== option.value),
												)
											}}
										/>
										<Label
											htmlFor={`${formId}-aos-${option.value}`}
											className="text-sm font-normal"
										>
											{option.label}
										</Label>
									</div>
								)
							})
						)}
					</div>
				</div>
			)}
		/>
	)
}

function CpdClaimFormSkeleton() {
	return (
		<div className="space-y-4 px-6 py-4" aria-busy>
			{Array.from({ length: 5 }).map((_, index) => (
				<div key={index} className="space-y-1.5">
					<Skeleton className="h-4 w-28" />
					<Skeleton className="h-9 w-full rounded-xl" />
				</div>
			))}
		</div>
	)
}

type CpdClaimFormProps = {
	/** Null for Add; a claim for Edit. */
	claim: CpdClaim | null
	onSaved: () => void
	onCancel: () => void
}

/**
 * Add / edit one CPD activity.
 *
 * The five extra fields below the fixed ones are driven by the chosen activity
 * type's admin-configured labels — see `dynamicFieldsFor`. Changing the type
 * re-derives them, and any value typed into a field the new type does not ask
 * for is dropped rather than silently submitted.
 */
function CpdClaimForm({ claim, onSaved, onCancel }: CpdClaimFormProps) {
	const formId = useId()
	const isEdit = Boolean(claim?.claimId)
	const activityTypes = useCpdActivityTypes()
	const options = useAccountOptions()
	const mutation = useSaveCpdClaim(isEdit)

	const {
		control,
		register,
		handleSubmit,
		unregister,
		formState: { errors, isSubmitting },
	} = useForm<CpdClaimFormValues>({
		defaultValues: EMPTY_FORM_VALUES,
		values: toFormValues(claim),
		mode: "onSubmit",
	})

	const selectedTypeId = useWatch({ control, name: "activityType" })
	const selectedType = findActivityType(activityTypes.data, selectedTypeId)

	const shownFields = useMemo(
		() => dynamicFieldsFor(selectedType).map((field) => field.name),
		[selectedType],
	)

	/*
	 * Drop any extra the new activity type does not ask for. Without this the
	 * value stays registered and would be submitted for a type it means nothing
	 * for — the legacy discarded them too, just by destroying the controls.
	 */
	useEffect(() => {
		const stale = (
			[
				"organizationName",
				"provider",
				"publication",
				"title",
				"contactEmail",
			] as CpdDynamicFieldName[]
		).filter((name) => !shownFields.includes(name))
		if (stale.length > 0) unregister(stale)
	}, [shownFields, unregister])

	const areaOptions = options.data?.picklists?.[AREA_OF_STUDY_FIELD] ?? []
	const isLoading = activityTypes.isLoading || options.isLoading
	const hasActivityTypes = (activityTypes.data ?? []).length > 0
	const isBusy = isSubmitting || mutation.isPending

	const onSubmit = async (values: CpdClaimFormValues) => {
		const input: CpdClaimInput = {
			...(claim?.claimId ? { claimId: claim.claimId } : {}),
			activityType: values.activityType,
			credits: Number(values.credits),
			dateOfCompletionString: values.dateOfCompletion,
			areaOfStudy: values.areaOfStudy.join(";"),
			comments: values.comments || null,
			URL: values.URL || null,
			...Object.fromEntries(
				shownFields.map((name) => [name, values[name] || null]),
			),
		}
		try {
			await mutation.mutateAsync(input)
			onSaved()
		} catch {
			// Toast comes from the shared MutationCache.
		}
	}

	if (isLoading) return <CpdClaimFormSkeleton />

	/*
	 * Activity type is required and every extra field hangs off it, so with no
	 * active CPE_Activity_Type__c the form cannot be completed. Saying so beats
	 * rendering an empty dropdown the member cannot act on — the same failure
	 * GARP_Portal_OptionsService calls out for inaccessible picklists.
	 */
	if (!hasActivityTypes) {
		return (
			<div className="flex min-h-0 flex-1 flex-col">
				<div className="min-h-0 flex-1 px-6 py-8 text-center">
					<p className="font-heading text-base font-semibold tracking-wide text-foreground">
						Activity types are unavailable
					</p>
					<p className="mx-auto mt-2 max-w-sm text-sm text-muted-foreground">
						CPD activities cannot be logged right now because no activity types
						are configured. Please try again later or contact{" "}
						<a
							href={`mailto:${CPD_CONTACT_EMAIL}`}
							className="text-primary hover:underline"
						>
							{CPD_CONTACT_EMAIL}
						</a>
						.
					</p>
				</div>
				<DialogFooter className="shrink-0 border-t border-border px-6 py-4 sm:justify-end">
					<Button type="button" variant="outline" onClick={onCancel}>
						Close
					</Button>
				</DialogFooter>
			</div>
		)
	}

	return (
		<form
			onSubmit={(event) => {
				void handleSubmit(onSubmit)(event)
			}}
			noValidate
			className="flex min-h-0 flex-1 flex-col"
		>
			<div className="min-h-0 flex-1 space-y-4 overflow-y-auto px-6 py-4">
				<Controller
					control={control}
					name="activityType"
					rules={{ required: "Activity Type is required" }}
					render={({ field }) => (
						<FormField
							label="Activity Type*"
							htmlFor={`${formId}-activityType`}
							error={errors.activityType?.message}
						>
							<Select value={field.value || undefined} onValueChange={field.onChange}>
								<SelectTrigger
									id={`${formId}-activityType`}
									className="w-full"
									aria-invalid={Boolean(errors.activityType)}
								>
									<SelectValue placeholder="Select an activity type" />
								</SelectTrigger>
								<SelectContent>
									{(activityTypes.data ?? []).map((type) => (
										<SelectItem key={type.id} value={type.id ?? ""}>
											{type.name}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</FormField>
					)}
				/>

				<AreaOfStudyField control={control} options={areaOptions} formId={formId} />

				<div className="grid gap-4 sm:grid-cols-2">
					<FormField
						label="Date of Completion*"
						htmlFor={`${formId}-dateOfCompletion`}
						error={errors.dateOfCompletion?.message}
					>
						<Input
							id={`${formId}-dateOfCompletion`}
							type="date"
							max={todayInputValue()}
							aria-invalid={Boolean(errors.dateOfCompletion)}
							{...register("dateOfCompletion", {
								required: "Date of Completion is required",
								validate: (value) =>
									value <= todayInputValue() ||
									"Date must be on or before today",
							})}
						/>
					</FormField>

					<FormField
						label="Number of Credits*"
						htmlFor={`${formId}-credits`}
						error={errors.credits?.message}
					>
						<Input
							id={`${formId}-credits`}
							type="number"
							step="0.5"
							min={MIN_CREDITS}
							max={MAX_CREDITS}
							aria-invalid={Boolean(errors.credits)}
							{...register("credits", {
								required: "Credits is required",
								min: {
									value: MIN_CREDITS,
									message: `Credits must be at least ${MIN_CREDITS}`,
								},
								max: {
									value: MAX_CREDITS,
									message: `Credits cannot exceed ${MAX_CREDITS}`,
								},
							})}
						/>
					</FormField>
				</div>

				<DynamicFields
					activityType={selectedType}
					formId={formId}
					register={register}
					errors={errors}
				/>

				<FormField
					label="Comment"
					htmlFor={`${formId}-comments`}
					error={errors.comments?.message}
				>
					<Textarea
						id={`${formId}-comments`}
						maxLength={255}
						aria-invalid={Boolean(errors.comments)}
						{...register("comments", {
							minLength: {
								value: 2,
								message: "Comment must be at least 2 characters long",
							},
						})}
					/>
				</FormField>

				<FormField label="URL" htmlFor={`${formId}-URL`} error={errors.URL?.message}>
					<Input
						id={`${formId}-URL`}
						maxLength={255}
						aria-invalid={Boolean(errors.URL)}
						{...register("URL", {
							pattern: { value: URL_PATTERN, message: "URL must be a valid URL" },
						})}
					/>
				</FormField>
			</div>

			<DialogFooter className="shrink-0 border-t border-border px-6 py-4 sm:justify-end">
				<Button type="button" variant="outline" onClick={onCancel} disabled={isBusy}>
					Cancel
				</Button>
				<Button type="submit" disabled={isBusy}>
					{isBusy ? "Saving…" : isEdit ? "Update" : "Submit"}
				</Button>
			</DialogFooter>
		</form>
	)
}

export { CpdClaimForm }
