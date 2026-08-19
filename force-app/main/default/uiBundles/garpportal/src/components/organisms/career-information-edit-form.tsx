import { useId, type ReactNode } from "react"
import {
	Controller,
	useForm,
	useWatch,
	type SubmitHandler,
} from "react-hook-form"

import type { AccountProfileValues } from "@/api/account/save-profile"
import type { AccountView, PicklistOption } from "@/api/account/types"
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
import { useAccountOptions } from "@/hooks/use-account-options"
import { useSaveAccountProfile } from "@/hooks/use-save-account-profile"
import { cn } from "@/lib/utils"

const WESTERN_CHARACTERS = /^[a-zA-Z0-9().,&\-\s]*$/
const YEAR_PATTERN = /^\d{4}$/
const RISK_JOB_FUNCTION = "Risk Management"

export const DESIGNATION_CODES = [
	"ACCA",
	"CA",
	"CAIA",
	"CFA",
	"CFP",
	"CIA",
	"CMA",
	"CMT",
	"CPA",
	"CQF",
	"PMP",
] as const

type DesignationCode = (typeof DESIGNATION_CODES)[number]

type CareerInformationFormValues = {
	workStatus: string
	industry: string
	industryStartYear: string
	company: string
	professionalLevel: string
	jobFunction: string
	riskStartYear: string
	riskSpecialty: string
	designations: Record<DesignationCode, boolean>
	otherDesignation: boolean
	otherQualifications: string
	school: string
	degreeProgram: string
	graduationYear: string
	graduationMonth: string
}

type CareerInformationEditFormProps = {
	account: AccountView
	onSaved?: () => void
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
	children: ReactNode
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

function SkeletonField({ className }: { className?: string }) {
	return (
		<div className={cn("flex flex-col gap-1.5", className)}>
			<Skeleton className="h-3.5 w-20" />
			<Skeleton className="h-9 w-full rounded-md" />
		</div>
	)
}

function CareerInformationEditFormSkeleton() {
	return (
		<div className="flex flex-col gap-6" aria-busy aria-label="Loading career form">
			<div className="grid gap-3 sm:grid-cols-2">
				{Array.from({ length: 8 }).map((_, index) => (
					<SkeletonField key={index} />
				))}
			</div>
			<Skeleton className="h-4 w-48" />
			<div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
				{Array.from({ length: 12 }).map((_, index) => (
					<Skeleton key={index} className="h-5 w-full" />
				))}
			</div>
		</div>
	)
}

function asText(value: string | null | undefined): string {
	return value?.trim() ?? ""
}

function emptyToNull(value: string): string | null {
	const trimmed = value.trim()
	return trimmed === "" ? null : trimmed
}

function optionalTextRules(label: string) {
	return {
		maxLength: {
			value: 255,
			message: `${label} must be 255 characters or fewer`,
		},
		validate: (value: string) => {
			const trimmed = value.trim()
			if (!trimmed) return true
			if (trimmed.length < 2) {
				return `${label} must be at least 2 characters`
			}
			if (!WESTERN_CHARACTERS.test(trimmed)) {
				return `${label} can only include letters, numbers, and basic punctuation`
			}
			return true
		},
	}
}

function optionalYearRules(label: string) {
	return {
		validate: (value: string) => {
			const trimmed = value.trim()
			if (!trimmed) return true
			if (!YEAR_PATTERN.test(trimmed)) {
				return `Enter a 4-digit ${label.toLowerCase()}`
			}
			return true
		},
	}
}

function toFormValues(account: AccountView): CareerInformationFormValues {
	const { career, academic, designations } = account
	return {
		workStatus: asText(career.currentlyWorkingStatus),
		industry: asText(career.areaOfConcentration),
		industryStartYear: asText(career.industryWorkingYear),
		company: asText(career.company),
		professionalLevel: asText(career.corporateTitle),
		jobFunction: asText(career.jobFunction),
		riskStartYear: asText(career.riskManagementWorkingYear),
		riskSpecialty: asText(account.expertise.riskSpecialty),
		designations: {
			ACCA: designations.ACCA === true,
			CA: designations.CA === true,
			CAIA: designations.CAIA === true,
			CFA: designations.CFA === true,
			CFP: designations.CFP === true,
			CIA: designations.CIA === true,
			CMA: designations.CMA === true,
			CMT: designations.CMT === true,
			CPA: designations.CPA === true,
			CQF: designations.CQF === true,
			PMP: designations.PMP === true,
		},
		otherDesignation: designations.Other === true,
		otherQualifications: asText(designations.otherQualifications),
		school: asText(academic.schoolName),
		degreeProgram: asText(academic.highestDegree),
		graduationYear: asText(academic.expectedGraduationDate),
		graduationMonth: asText(academic.expectedGraduationMonth),
	}
}

function optionsFor(
	picklists: Record<string, PicklistOption[]> | undefined,
	field: string,
): PicklistOption[] {
	return picklists?.[field] ?? []
}

function CareerInformationEditForm({
	account,
	onSaved,
}: CareerInformationEditFormProps) {
	const formId = useId()
	const optionsQuery = useAccountOptions(true)
	const saveMutation = useSaveAccountProfile(account.identity.contactId)
	const {
		control,
		register,
		handleSubmit,
		setValue,
		formState: { errors, isSubmitting },
	} = useForm<CareerInformationFormValues>({
		// Seed from the live account on mount. Do not use `values` + empty
		// `defaultValues` — Radix Select mounts one frame with no value, then
		// ignores the later update and shows the placeholder on reopen.
		defaultValues: toFormValues(account),
		mode: "onSubmit",
	})

	const jobFunction = useWatch({ control, name: "jobFunction" })
	const otherDesignation = useWatch({ control, name: "otherDesignation" })
	const showRiskSpecialty = jobFunction === RISK_JOB_FUNCTION
	const isBusy = isSubmitting || saveMutation.isPending
	const isLoading = optionsQuery.isLoading
	const loadFailed = optionsQuery.isError
	const picklists = optionsQuery.data?.picklists

	const onSubmit: SubmitHandler<CareerInformationFormValues> = async (values) => {
		const payload: AccountProfileValues = {
			Currently_Working_Status__c: emptyToNull(values.workStatus),
			Area_of_Concentration__c: emptyToNull(values.industry),
			Industry_Working_Year__c: emptyToNull(values.industryStartYear),
			Company__c: emptyToNull(values.company),
			Corporate_Title__c: emptyToNull(values.professionalLevel),
			Job_Function__c: emptyToNull(values.jobFunction),
			Risk_Management_Working_Year__c: emptyToNull(values.riskStartYear),
			Risk_Specialty__c: showRiskSpecialty
				? emptyToNull(values.riskSpecialty)
				: null,
			School_Name__c: emptyToNull(values.school),
			Highest_Degree__c: emptyToNull(values.degreeProgram),
			Expected_Graduation_Date__c: emptyToNull(values.graduationYear),
			Expected_Graduation_Month__c: emptyToNull(values.graduationMonth),
			Professional_Designation_Other__c: values.otherDesignation,
			Other_Qualifications__c: values.otherDesignation
				? emptyToNull(values.otherQualifications)
				: null,
		}

		for (const code of DESIGNATION_CODES) {
			payload[`Professional_Designation_${code}__c`] = values.designations[code]
		}

		try {
			await saveMutation.mutateAsync(payload)
			onSaved?.()
		} catch {
			// Toast via MutationCache.
		}
	}

	const canSubmit = !isLoading && !loadFailed && !isBusy

	return (
		<form
			className="flex min-h-0 flex-1 flex-col"
			onSubmit={(event) => {
				void handleSubmit(onSubmit)(event)
			}}
			noValidate
		>
			<div className="min-h-0 flex-1 overflow-y-auto px-6 py-4">
				{isLoading ? (
					<CareerInformationEditFormSkeleton />
				) : loadFailed ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load the career information options. Please try again
						later.
					</p>
				) : (
					<div className="flex flex-col gap-6">
						<section className="flex flex-col gap-3">
							<h3 className="font-heading text-sm font-semibold">Job Information</h3>
							<div className="grid gap-3 sm:grid-cols-2">
								<FormField
									label="What is your work status?"
									htmlFor={`${formId}-workStatus`}
									error={errors.workStatus?.message}
								>
									<Controller
										name="workStatus"
										control={control}
										rules={{ required: "Please select a work status" }}
										render={({ field }) => (
											<Select
												key={field.value || "empty"}
												value={field.value || undefined}
												onValueChange={field.onChange}
											>
												<SelectTrigger
													id={`${formId}-workStatus`}
													className="w-full"
													aria-invalid={Boolean(errors.workStatus)}
												>
													<SelectValue placeholder="Select work status" />
												</SelectTrigger>
												<SelectContent>
													{optionsFor(
														picklists,
														"Currently_Working_Status__c",
													).map((option) => (
														<SelectItem key={option.value} value={option.value}>
															{option.label}
														</SelectItem>
													))}
												</SelectContent>
											</Select>
										)}
									/>
								</FormField>
								<FormField
									label="What industry do/did you specialize in?"
									htmlFor={`${formId}-industry`}
									error={errors.industry?.message}
								>
									<Controller
										name="industry"
										control={control}
										rules={{ required: "Please select an industry" }}
										render={({ field }) => (
											<Select
												key={field.value || "empty"}
												value={field.value || undefined}
												onValueChange={field.onChange}
											>
												<SelectTrigger
													id={`${formId}-industry`}
													className="w-full"
													aria-invalid={Boolean(errors.industry)}
												>
													<SelectValue placeholder="Select industry" />
												</SelectTrigger>
												<SelectContent>
													{optionsFor(
														picklists,
														"Area_of_Concentration__c",
													).map((option) => (
														<SelectItem key={option.value} value={option.value}>
															{option.label}
														</SelectItem>
													))}
												</SelectContent>
											</Select>
										)}
									/>
								</FormField>
								<FormField
									label="What year did you start working in the industry?"
									htmlFor={`${formId}-industryStartYear`}
									error={errors.industryStartYear?.message}
								>
									<Input
										id={`${formId}-industryStartYear`}
										inputMode="numeric"
										placeholder="YYYY"
										aria-invalid={Boolean(errors.industryStartYear)}
										{...register("industryStartYear", optionalYearRules("year"))}
									/>
								</FormField>
								<FormField
									label="What is your most recent company?"
									htmlFor={`${formId}-company`}
									error={errors.company?.message}
								>
									<Input
										id={`${formId}-company`}
										placeholder="Enter company"
										aria-invalid={Boolean(errors.company)}
										{...register("company", optionalTextRules("Company"))}
									/>
								</FormField>
								<FormField
									label="What is your professional level?"
									htmlFor={`${formId}-professionalLevel`}
									error={errors.professionalLevel?.message}
								>
									<Controller
										name="professionalLevel"
										control={control}
										rules={{ required: "Please select a professional level" }}
										render={({ field }) => (
											<Select
												key={field.value || "empty"}
												value={field.value || undefined}
												onValueChange={field.onChange}
											>
												<SelectTrigger
													id={`${formId}-professionalLevel`}
													className="w-full"
													aria-invalid={Boolean(errors.professionalLevel)}
												>
													<SelectValue placeholder="Select professional level" />
												</SelectTrigger>
												<SelectContent>
													{optionsFor(picklists, "Corporate_Title__c").map(
														(option) => (
															<SelectItem key={option.value} value={option.value}>
																{option.label}
															</SelectItem>
														),
													)}
												</SelectContent>
											</Select>
										)}
									/>
								</FormField>
								<FormField
									label="What is your job function?"
									htmlFor={`${formId}-jobFunction`}
									error={errors.jobFunction?.message}
								>
									<Controller
										name="jobFunction"
										control={control}
										rules={{ required: "Please select a job function" }}
										render={({ field }) => (
											<Select
												key={field.value || "empty"}
												value={field.value || undefined}
												onValueChange={(next) => {
													field.onChange(next)
													if (next !== RISK_JOB_FUNCTION) {
														setValue("riskSpecialty", "")
													}
												}}
											>
												<SelectTrigger
													id={`${formId}-jobFunction`}
													className="w-full"
													aria-invalid={Boolean(errors.jobFunction)}
												>
													<SelectValue placeholder="Select job function" />
												</SelectTrigger>
												<SelectContent>
													{optionsFor(picklists, "Job_Function__c").map(
														(option) => (
															<SelectItem key={option.value} value={option.value}>
																{option.label}
															</SelectItem>
														),
													)}
												</SelectContent>
											</Select>
										)}
									/>
								</FormField>
								<FormField
									label="What year did you start working in risk management?"
									htmlFor={`${formId}-riskStartYear`}
									error={errors.riskStartYear?.message}
								>
									<Input
										id={`${formId}-riskStartYear`}
										inputMode="numeric"
										placeholder="YYYY"
										aria-invalid={Boolean(errors.riskStartYear)}
										{...register("riskStartYear", optionalYearRules("year"))}
									/>
								</FormField>
								{showRiskSpecialty ? (
									<FormField
										label="What is your risk specialty?"
										htmlFor={`${formId}-riskSpecialty`}
										error={errors.riskSpecialty?.message}
									>
										<Controller
											name="riskSpecialty"
											control={control}
											rules={{ required: "Please select a risk specialty" }}
											render={({ field }) => (
												<Select
													key={field.value || "empty"}
													value={field.value || undefined}
													onValueChange={field.onChange}
												>
													<SelectTrigger
														id={`${formId}-riskSpecialty`}
														className="w-full"
														aria-invalid={Boolean(errors.riskSpecialty)}
													>
														<SelectValue placeholder="Select risk specialty" />
													</SelectTrigger>
													<SelectContent>
														{optionsFor(picklists, "Risk_Specialty__c").map(
															(option) => (
																<SelectItem
																	key={option.value}
																	value={option.value}
																>
																	{option.label}
																</SelectItem>
															),
														)}
													</SelectContent>
												</Select>
											)}
										/>
									</FormField>
								) : null}
							</div>
						</section>

						<section className="flex flex-col gap-3">
							<p className="font-heading text-sm font-semibold">
								Do you currently hold any professional designations?
							</p>
							<div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
								{DESIGNATION_CODES.map((code) => (
									<div key={code} className="flex items-center gap-2">
										<Controller
											name={`designations.${code}`}
											control={control}
											render={({ field }) => (
												<Checkbox
													id={`${formId}-des-${code}`}
													checked={field.value}
													onCheckedChange={(checked) => {
														field.onChange(checked === true)
													}}
												/>
											)}
										/>
										<Label
											htmlFor={`${formId}-des-${code}`}
											className="font-normal"
										>
											{code}
										</Label>
									</div>
								))}
								<div className="flex items-center gap-2">
									<Controller
										name="otherDesignation"
										control={control}
										render={({ field }) => (
											<Checkbox
												id={`${formId}-des-other`}
												checked={field.value}
												onCheckedChange={(checked) => {
													field.onChange(checked === true)
												}}
											/>
										)}
									/>
									<Label htmlFor={`${formId}-des-other`} className="font-normal">
										Other
									</Label>
								</div>
							</div>
							{otherDesignation ? (
								<FormField
									label="Other qualifications"
									htmlFor={`${formId}-otherQualifications`}
									error={errors.otherQualifications?.message}
								>
									<Input
										id={`${formId}-otherQualifications`}
										aria-invalid={Boolean(errors.otherQualifications)}
										{...register("otherQualifications", {
											validate: (value) => {
												if (!otherDesignation) return true
												return value.trim()
													? true
													: "Enter your other qualification"
											},
										})}
									/>
								</FormField>
							) : null}
						</section>

						<section className="flex flex-col gap-3">
							<h3 className="font-heading text-sm font-semibold">
								Academic Information
							</h3>
							<div className="grid gap-3 sm:grid-cols-2">
								<FormField
									label="Current or most recent school attended"
									htmlFor={`${formId}-school`}
									error={errors.school?.message}
									className="sm:col-span-2"
								>
									<Input
										id={`${formId}-school`}
										placeholder="Enter school"
										aria-invalid={Boolean(errors.school)}
										{...register("school", optionalTextRules("School"))}
									/>
								</FormField>
								<FormField
									label="Degree program"
									htmlFor={`${formId}-degreeProgram`}
									error={errors.degreeProgram?.message}
								>
									<Controller
										name="degreeProgram"
										control={control}
										rules={{ required: "Please select a degree program" }}
										render={({ field }) => (
											<Select
												key={field.value || "empty"}
												value={field.value || undefined}
												onValueChange={field.onChange}
											>
												<SelectTrigger
													id={`${formId}-degreeProgram`}
													className="w-full"
													aria-invalid={Boolean(errors.degreeProgram)}
												>
													<SelectValue placeholder="Select degree program" />
												</SelectTrigger>
												<SelectContent>
													{optionsFor(picklists, "Highest_Degree__c").map(
														(option) => (
															<SelectItem key={option.value} value={option.value}>
																{option.label}
															</SelectItem>
														),
													)}
												</SelectContent>
											</Select>
										)}
									/>
								</FormField>
								<FormField
									label="Year of graduation"
									htmlFor={`${formId}-graduationYear`}
									error={errors.graduationYear?.message}
								>
									<Input
										id={`${formId}-graduationYear`}
										inputMode="numeric"
										placeholder="YYYY"
										aria-invalid={Boolean(errors.graduationYear)}
										{...register("graduationYear", optionalYearRules("year"))}
									/>
								</FormField>
								<FormField
									label="Month of graduation"
									htmlFor={`${formId}-graduationMonth`}
									error={errors.graduationMonth?.message}
								>
									<Controller
										name="graduationMonth"
										control={control}
										render={({ field }) => (
											<Select
												key={field.value || "empty"}
												value={field.value || undefined}
												onValueChange={field.onChange}
											>
												<SelectTrigger
													id={`${formId}-graduationMonth`}
													className="w-full"
													aria-invalid={Boolean(errors.graduationMonth)}
												>
													<SelectValue placeholder="Select month" />
												</SelectTrigger>
												<SelectContent>
													{optionsFor(
														picklists,
														"Expected_Graduation_Month__c",
													).map((option) => (
														<SelectItem key={option.value} value={option.value}>
															{option.label}
														</SelectItem>
													))}
												</SelectContent>
											</Select>
										)}
									/>
								</FormField>
							</div>
						</section>
					</div>
				)}
			</div>

			<DialogFooter className="shrink-0 border-t border-border px-6 py-4 sm:justify-end">
				<Button type="submit" disabled={!canSubmit}>
					{saveMutation.isPending ? "Saving…" : "Save"}
				</Button>
			</DialogFooter>
		</form>
	)
}

export { CareerInformationEditForm }
