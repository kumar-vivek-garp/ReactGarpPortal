import { useEffect, useId, useMemo } from "react"
import { Controller, useForm, useWatch } from "react-hook-form"
import type { Control, FieldErrors } from "react-hook-form"

import type { CvProgramType, WorkExperience } from "@/api/work-experience"
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
import { CvAttachmentManager } from "@/components/molecules/cv-attachment-manager"
import {
	CV_DESCRIPTION_MAX_LENGTH,
	CV_DESCRIPTION_MIN_LENGTH,
	CV_MONTHS,
	cvYearOptions,
} from "@/config/work-experience"
import { useCvExperienceForm, useSaveExperience } from "@/hooks/use-cv"
import { cn } from "@/lib/utils"
import {
	toExperienceFormValues,
	toExperienceInput,
	type CvExperienceFormValues,
} from "@/lib/work-experience-presentation"

/** Educational role only means anything for teaching posts. */
const EDUCATION_JOB_FUNCTION = "Education/Training"

/** A start date is asked for in every case. */
const ALWAYS_REQUIRED = () => true

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

type FieldProps = {
	id: string
	label: string
	required?: boolean
	children: React.ReactNode
	error?: string
	hint?: string
	className?: string
}

function Field({
	id,
	label,
	required,
	children,
	error,
	hint,
	className,
}: FieldProps) {
	return (
		<div className={cn("space-y-1.5", className)}>
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
			{hint && !error ? (
				<p className="text-xs text-muted-foreground">{hint}</p>
			) : null}
			<FieldError message={error} />
		</div>
	)
}

type PicklistProps = {
	id: string
	label: string
	required?: boolean
	options: string[]
	control: Control<CvExperienceFormValues>
	name: "jobFunction" | "riskSpecialty" | "jobType" | "educationalRole"
	error?: string
	disabled?: boolean
}

function Picklist({
	id,
	label,
	required,
	options,
	control,
	name,
	error,
	disabled,
}: PicklistProps) {
	return (
		<Controller
			control={control}
			name={name}
			rules={required ? { required: `${label} is required.` } : undefined}
			render={({ field }) => (
				<Field id={id} label={label} required={required} error={error}>
					<Select
						value={field.value || undefined}
						onValueChange={field.onChange}
						disabled={disabled}
					>
						<SelectTrigger id={id} className="w-full">
							<SelectValue placeholder="Select…" />
						</SelectTrigger>
						<SelectContent>
							{options.map((option) => (
								<SelectItem key={option} value={option}>
									{option}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</Field>
			)}
		/>
	)
}

type MonthYearProps = {
	idPrefix: string
	label: string
	control: Control<CvExperienceFormValues>
	monthName: "startDateMonth" | "endDateMonth"
	yearName: "startDateYear" | "endDateYear"
	years: string[]
	errors: FieldErrors<CvExperienceFormValues>
	disabled?: boolean
	/**
	 * Read at validation time, not at render time.
	 *
	 * react-hook-form registers a Controller's `rules` once, on mount, and does
	 * not re-read them when the prop changes — so a `rules` object toggled by
	 * `isCurrentPosition` keeps enforcing the end date after the member ticks
	 * "I still work here", and the form cannot be submitted at all. Asking for
	 * the answer inside `validate` is the only form of this that actually
	 * tracks the checkbox.
	 */
	isRequired: () => boolean
}

/**
 * A month and a year, never a date input.
 *
 * Apex accepts either `MM/dd/yyyy` strings or month/year integers, and the two
 * are not interchangeable: the string path goes through locale-dependent
 * `Date.parse`, and it picks its end-date branch by testing whether
 * `startDate` was sent, so a form mixing the modes throws a 501. Month/year
 * also credits the whole final month worked, which is what the member means.
 */
function MonthYearField({
	idPrefix,
	label,
	control,
	monthName,
	yearName,
	years,
	errors,
	disabled,
	isRequired,
}: MonthYearProps) {
	const error = errors[monthName]?.message ?? errors[yearName]?.message
	const rulesFor = (part: string) => ({
		validate: (value: string) =>
			!isRequired() || value ? true : `${label} ${part} is required.`,
	})
	return (
		<div className="space-y-1.5">
			<Label className="text-sm">
				{label}
				{isRequired() ? (
					<span className="text-destructive" aria-hidden>
						{" "}
						*
					</span>
				) : null}
			</Label>
			<div className="flex gap-2">
				<Controller
					control={control}
					name={monthName}
					rules={rulesFor("month")}
					render={({ field }) => (
						<Select
							value={field.value || undefined}
							onValueChange={field.onChange}
							disabled={disabled}
						>
							<SelectTrigger id={`${idPrefix}-month`} className="flex-1">
								<SelectValue placeholder="Month" />
							</SelectTrigger>
							<SelectContent>
								{CV_MONTHS.map((month) => (
									<SelectItem key={month.value} value={month.value}>
										{month.label}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					)}
				/>
				<Controller
					control={control}
					name={yearName}
					rules={rulesFor("year")}
					render={({ field }) => (
						<Select
							value={field.value || undefined}
							onValueChange={field.onChange}
							disabled={disabled}
						>
							<SelectTrigger id={`${idPrefix}-year`} className="w-32">
								<SelectValue placeholder="Year" />
							</SelectTrigger>
							<SelectContent>
								{years.map((year) => (
									<SelectItem key={year} value={year}>
										{year}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					)}
				/>
			</div>
			<FieldError message={error} />
		</div>
	)
}

function CvExperienceFormSkeleton() {
	return (
		<div className="space-y-4 px-6 py-4" aria-busy>
			{Array.from({ length: 6 }).map((_, index) => (
				<div key={index} className="space-y-1.5">
					<Skeleton className="h-4 w-28" />
					<Skeleton className="h-9 w-full rounded-xl" />
				</div>
			))}
		</div>
	)
}

type CvExperienceFormProps = {
	programType: CvProgramType
	/** Null for Add; a saved row for Edit. */
	experience: WorkExperience | null
	onSaved: () => void
	onCancel: () => void
}

/**
 * Add or edit one logged role.
 *
 * The picklists come from the server rather than a local list — the deployed
 * service answers a blank `experienceId` with the four option sets, so Add and
 * Edit load identically and the options cannot drift from the org's.
 *
 * Every legacy defect in this form is deliberately not reproduced: its
 * validators were registered as un-invoked factories so End Date was silently
 * optional despite its asterisk; its current-position toggle operated on a
 * control that no longer existed, persisting stale end dates alongside
 * `isCurrentPosition: true`; and `cvForm.enable()` wiped the intentional
 * disabled state on jobType and educationalRole.
 */
function CvExperienceForm({
	programType,
	experience,
	onSaved,
	onCancel,
}: CvExperienceFormProps) {
	const formId = useId()
	const experienceId = experience?.id ?? null
	const isEdit = Boolean(experienceId)

	const form = useCvExperienceForm(programType, experienceId)
	const mutation = useSaveExperience(programType, isEdit)

	// Prefer the freshly-fetched row: the list's copy carries attachmentCount 0
	// and can be a render behind an edit made elsewhere.
	const seed = form.data?.workExperience ?? experience ?? null

	const {
		control,
		register,
		handleSubmit,
		setValue,
		getValues,
		clearErrors,
		formState: { errors, isSubmitting },
	} = useForm<CvExperienceFormValues>({
		defaultValues: toExperienceFormValues(null),
		values: toExperienceFormValues(seed),
		mode: "onSubmit",
	})

	const years = useMemo(() => cvYearOptions(new Date().getFullYear()), [])

	const isCurrent = useWatch({ control, name: "isCurrentPosition" })
	const descriptionLength = (
		useWatch({ control, name: "description" }) ?? ""
	).length
	const jobFunction = useWatch({ control, name: "jobFunction" })
	const teaches = jobFunction === EDUCATION_JOB_FUNCTION

	/*
	 * A current role ends today, decided by Apex. Clearing the controls rather
	 * than merely disabling them is what stops the legacy's bug, where a stale
	 * end date was submitted next to `isCurrentPosition: true`.
	 */
	useEffect(() => {
		if (isCurrent) {
			setValue("endDateMonth", "")
			setValue("endDateYear", "")
			// The end date is no longer asked for; a message still demanding it
			// would sit under a control the member can no longer reach.
			clearErrors(["endDateMonth", "endDateYear"])
		}
	}, [isCurrent, setValue, clearErrors])

	/* Educational role means nothing outside teaching; never submit a stale one. */
	useEffect(() => {
		if (!teaches) setValue("educationalRole", "")
	}, [teaches, setValue])

	const endDateIsRequired = () => getValues("isCurrentPosition") !== true

	const isBusy = isSubmitting || mutation.isPending

	const onSubmit = async (values: CvExperienceFormValues) => {
		try {
			// Whitelist — see `toExperienceInput`. Nothing is spread in.
			await mutation.mutateAsync(toExperienceInput(values, experienceId))
			onSaved()
		} catch {
			// Toast comes from the shared MutationCache.
		}
	}

	if (form.isLoading) return <CvExperienceFormSkeleton />

	return (
		<form
			onSubmit={(event) => void handleSubmit(onSubmit)(event)}
			className="flex min-h-0 flex-1 flex-col"
		>
			<div className="min-h-0 flex-1 space-y-4 overflow-y-auto px-6 py-4">
				<Field
					id={`${formId}-company`}
					label="Organisation"
					required
					error={errors.company?.message}
				>
					<Input
						id={`${formId}-company`}
						{...register("company", {
							required: "An organisation name is required.",
						})}
					/>
				</Field>

				<div className="grid gap-4 sm:grid-cols-2">
					<Field
						id={`${formId}-title`}
						label="Job title"
						required
						error={errors.title?.message}
					>
						<Input
							id={`${formId}-title`}
							{...register("title", { required: "A job title is required." })}
						/>
					</Field>

					<Field
						id={`${formId}-manager`}
						label="Manager"
						error={errors.manager?.message}
						hint="Who GARP should contact to verify this role."
					>
						<Input id={`${formId}-manager`} {...register("manager")} />
					</Field>
				</div>

				<div className="grid gap-4 sm:grid-cols-2">
					<MonthYearField
						idPrefix={`${formId}-start`}
						label="Start date"
						control={control}
						monthName="startDateMonth"
						yearName="startDateYear"
						years={years}
						errors={errors}
						isRequired={ALWAYS_REQUIRED}
					/>
					<MonthYearField
						idPrefix={`${formId}-end`}
						label="End date"
						control={control}
						monthName="endDateMonth"
						yearName="endDateYear"
						years={years}
						errors={errors}
						disabled={isCurrent === true}
						isRequired={endDateIsRequired}
					/>
				</div>

				<Controller
					control={control}
					name="isCurrentPosition"
					render={({ field }) => (
						<div className="flex items-center gap-2">
							<Checkbox
								id={`${formId}-current`}
								checked={field.value === true}
								onCheckedChange={(next) => field.onChange(next === true)}
							/>
							<Label
								htmlFor={`${formId}-current`}
								className="text-sm font-normal"
							>
								I still work here
							</Label>
						</div>
					)}
				/>

				<div className="grid gap-4 sm:grid-cols-2">
					<Picklist
						id={`${formId}-jobType`}
						label="Employment type"
						required
						options={form.data?.jobTypes ?? []}
						control={control}
						name="jobType"
						error={errors.jobType?.message}
					/>
					<Picklist
						id={`${formId}-jobFunction`}
						label="Job function"
						required
						options={form.data?.jobFunctions ?? []}
						control={control}
						name="jobFunction"
						error={errors.jobFunction?.message}
					/>
				</div>

				<div className="grid gap-4 sm:grid-cols-2">
					<Picklist
						id={`${formId}-riskSpecialty`}
						label="Risk specialty"
						required
						options={form.data?.riskSpecialties ?? []}
						control={control}
						name="riskSpecialty"
						error={errors.riskSpecialty?.message}
					/>
					{teaches ? (
						<Picklist
							id={`${formId}-educationalRole`}
							label="Academic role"
							required
							options={form.data?.educationalRoles ?? []}
							control={control}
							name="educationalRole"
							error={errors.educationalRole?.message}
						/>
					) : null}
				</div>

				<Field
					id={`${formId}-description`}
					label="What you did"
					required
					error={errors.description?.message}
					hint="Describe your risk management responsibilities in this role."
				>
					<Textarea
						id={`${formId}-description`}
						rows={6}
						{...register("description", {
							required: "A description is required.",
							/*
							 * GARP's minimum, enforced client-side only — Apex checks
							 * nothing, so a short description would be accepted by the
							 * server. Paired with the live counter below: a hard floor
							 * with no feedback leaves the member guessing how much more
							 * to write, which is how the legacy shipped it.
							 */
							minLength: {
								value: CV_DESCRIPTION_MIN_LENGTH,
								message: `Please write at least ${CV_DESCRIPTION_MIN_LENGTH} characters so GARP can assess this role.`,
							},
							maxLength: {
								value: CV_DESCRIPTION_MAX_LENGTH,
								message: "This description is too long.",
							},
						})}
					/>
					<p
						className={cn(
							"text-xs tabular-nums",
							descriptionLength >= CV_DESCRIPTION_MIN_LENGTH
								? "text-success-green"
								: "text-muted-foreground",
						)}
						aria-live="polite"
					>
						{descriptionLength} / {CV_DESCRIPTION_MIN_LENGTH} characters
						{descriptionLength >= CV_DESCRIPTION_MIN_LENGTH ? " — that's enough" : null}
					</p>
				</Field>

				<CvAttachmentManager
					experienceId={experienceId}
					required={seed?.isExperienceAttachmentRequired === true}
					documentMessage={seed?.documentMessage}
					requiredDocuments={seed?.requiredDocuments}
				/>
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
					{isBusy ? "Saving…" : isEdit ? "Save changes" : "Add experience"}
				</Button>
			</DialogFooter>
		</form>
	)
}

export { CvExperienceForm }
