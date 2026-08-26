import { IdCard } from "lucide-react"

import {
	Controller,
	type Control,
	type FieldErrors,
	type UseFormGetValues,
	type UseFormRegister,
} from "react-hook-form"

import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
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
import type { ExamFormValues } from "@/components/forms/exam-registration/exam-form-values"
import {
	EXAM_SETUP_GENDERS,
	EXAM_SETUP_ID_LOCATIONS,
	EXAM_SETUP_ID_TYPES,
	EXAM_SETUP_SCHOOL_STATUSES,
	EXAM_SETUP_WORKING_STATUSES,
} from "@/config/exam-setup"
import { OSTA_COPY, PHONE_PATTERN } from "@/config/registration"
import { idFormatError } from "@/lib/registration-presentation"

/**
 * A string-list select.
 *
 * `value` is always a string, never `undefined` — handing Radix `undefined`
 * latches the Select into uncontrolled mode, after which every later value is
 * ignored and the field renders its placeholder forever.
 */
function OptionSelect({
	id,
	value,
	options,
	placeholder,
	onChange,
	invalid,
	disabled,
}: {
	id: string
	value: string
	options: readonly string[]
	placeholder: string
	onChange: (value: string) => void
	invalid?: boolean
	disabled?: boolean
}) {
	return (
		<Select value={value ?? ""} onValueChange={onChange} disabled={disabled}>
			<SelectTrigger
				id={id}
				aria-invalid={invalid ? true : undefined}
				className="w-full"
			>
				<SelectValue placeholder={placeholder} />
			</SelectTrigger>
			<SelectContent>
				{options.map((option) => (
					<SelectItem key={option} value={option}>
						{option}
					</SelectItem>
				))}
			</SelectContent>
		</Select>
	)
}

type OstaSectionProps = {
	register: UseFormRegister<ExamFormValues>
	control: Control<ExamFormValues>
	errors: FieldErrors<ExamFormValues>
	getValues: UseFormGetValues<ExamFormValues>
	/** Watched so the labels track the current choices. */
	idType: string
	workStatus: string
	studentStatus: string
	/** Typeahead suggestions from the load payload — free text still submits. */
	companies?: string[]
	schools?: string[]
	disabled?: boolean
}

/**
 * Identity details required by a Chinese exam centre.
 *
 * **Apex validates none of this.** It writes whatever arrives straight onto
 * the Contact whenever an ID number is present, so every rule protecting this
 * data lives here — including `idFormatError`, which is ported character for
 * character rather than approximated.
 *
 * Required-ness is expressed through `validate` closures reading `getValues`,
 * never through a toggled `rules` object: react-hook-form registers `rules`
 * once at mount and never re-reads them, so a rule switched off by a later
 * choice would carry on being enforced and make the form unsubmittable.
 */
function OstaSection({
	register,
	control,
	errors,
	getValues,
	idType,
	workStatus,
	studentStatus,
	companies = [],
	schools = [],
	disabled,
}: OstaSectionProps) {
	const osta = errors.osta
	const idLabel = idType === "Passport" ? "passport" : "ID"
	const isWorking = workStatus === "Working"
	const isInSchool = studentStatus === "In School"

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<IdCard className="size-5 text-muted-foreground" aria-hidden />
					{OSTA_COPY.title}
				</CardTitle>
				<p className="text-body text-muted-foreground">{OSTA_COPY.intro}</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				<FormField
					id="osta-idType"
					label="ID type"
					required
					error={osta?.idType?.message}
				>
					<Controller
						control={control}
						name="osta.idType"
						rules={{ required: "Please select an ID type." }}
						render={({ field }) => (
							<OptionSelect
								id="osta-idType"
								value={field.value}
								options={EXAM_SETUP_ID_TYPES}
								placeholder="Select ID type"
								onChange={field.onChange}
								invalid={Boolean(osta?.idType)}
								disabled={disabled}
							/>
						)}
					/>
				</FormField>

				<FormField
					id="osta-idLocation"
					label="Where was your ID issued?"
					required
					error={osta?.idLocation?.message}
				>
					<Controller
						control={control}
						name="osta.idLocation"
						rules={{ required: "Please select where your ID was issued." }}
						render={({ field }) => (
							<OptionSelect
								id="osta-idLocation"
								value={field.value}
								options={EXAM_SETUP_ID_LOCATIONS}
								placeholder="Select location"
								onChange={field.onChange}
								invalid={Boolean(osta?.idLocation)}
								disabled={disabled}
							/>
						)}
					/>
				</FormField>

				<FormField
					id="osta-idNumber"
					label="ID number"
					required
					error={osta?.idNumber?.message}
				>
					<Input
						id="osta-idNumber"
						disabled={disabled}
						aria-invalid={osta?.idNumber ? true : undefined}
						{...register("osta.idNumber", {
							required: "Please enter your ID number.",
							// Read at validation time: the rule depends on two other
							// fields, and a `rules` object would freeze whichever values
							// happened to be set at mount.
							validate: (value) =>
								idFormatError(
									getValues("osta.idLocation"),
									getValues("osta.idType"),
									value.trim(),
								) ?? true,
						})}
					/>
				</FormField>

				<FormField
					id="osta-confirmIdNumber"
					label="Confirm ID number"
					required
					error={osta?.confirmIdNumber?.message}
				>
					{/* Never sent — it exists purely to catch a typo in a value
					    nothing downstream will check. */}
					<Input
						id="osta-confirmIdNumber"
						disabled={disabled}
						aria-invalid={osta?.confirmIdNumber ? true : undefined}
						{...register("osta.confirmIdNumber", {
							validate: (value) =>
								value.trim() === getValues("osta.idNumber").trim() ||
								"Your ID numbers do not match.",
						})}
					/>
				</FormField>

				<FormField
					id="osta-nameOnId"
					label={`Name as it appears on your ${idLabel}`}
					required
					error={osta?.nameOnId?.message}
					className="sm:col-span-2"
				>
					<Input
						id="osta-nameOnId"
						disabled={disabled}
						aria-invalid={osta?.nameOnId ? true : undefined}
						{...register("osta.nameOnId", {
							required: `Please enter your name as it appears on your ${idLabel}.`,
						})}
					/>
				</FormField>

				<FormField
					id="osta-idExpireDate"
					label={`${idLabel === "passport" ? "Passport" : "ID"} expiry date`}
					required
					error={osta?.idExpireDate?.message}
				>
					<Input
						id="osta-idExpireDate"
						type="date"
						disabled={disabled}
						aria-invalid={osta?.idExpireDate ? true : undefined}
						{...register("osta.idExpireDate", {
							required: "Please enter your ID expiry date.",
						})}
					/>
				</FormField>

				<FormField
					id="osta-dateOfBirth"
					label="Date of birth"
					required
					error={osta?.dateOfBirth?.message}
				>
					<Input
						id="osta-dateOfBirth"
						type="date"
						disabled={disabled}
						aria-invalid={osta?.dateOfBirth ? true : undefined}
						{...register("osta.dateOfBirth", {
							required: "Please enter your date of birth.",
						})}
					/>
				</FormField>

				<FormField
					id="osta-gender"
					label="Gender"
					required
					error={osta?.gender?.message}
				>
					<Controller
						control={control}
						name="osta.gender"
						rules={{ required: "Please select a gender." }}
						render={({ field }) => (
							<OptionSelect
								id="osta-gender"
								value={field.value}
								options={EXAM_SETUP_GENDERS}
								placeholder="Select gender"
								onChange={field.onChange}
								invalid={Boolean(osta?.gender)}
								disabled={disabled}
							/>
						)}
					/>
				</FormField>

				<FormField
					id="osta-fullNameInChinese"
					label="Full name in Chinese (中文姓名)"
					required
					error={osta?.fullNameInChinese?.message}
				>
					<Input
						id="osta-fullNameInChinese"
						disabled={disabled}
						aria-invalid={osta?.fullNameInChinese ? true : undefined}
						{...register("osta.fullNameInChinese", {
							required: "Please enter your full name in Chinese.",
						})}
					/>
				</FormField>

				<FormField
					id="osta-phone"
					label="Phone number"
					required
					error={osta?.phone?.message}
				>
					<Input
						id="osta-phone"
						type="tel"
						inputMode="numeric"
						disabled={disabled}
						aria-invalid={osta?.phone ? true : undefined}
						{...register("osta.phone", {
							required: "Please enter a phone number.",
							pattern: {
								value: PHONE_PATTERN,
								message: "Please enter between 7 and 15 numbers.",
							},
						})}
					/>
				</FormField>

				<FormField
					id="osta-workStatus"
					label="Work status"
					required
					error={osta?.workStatus?.message}
				>
					<Controller
						control={control}
						name="osta.workStatus"
						rules={{ required: "Please select your work status." }}
						render={({ field }) => (
							<OptionSelect
								id="osta-workStatus"
								value={field.value}
								options={EXAM_SETUP_WORKING_STATUSES}
								placeholder="Select work status"
								onChange={field.onChange}
								invalid={Boolean(osta?.workStatus)}
								disabled={disabled}
							/>
						)}
					/>
				</FormField>

				<FormField
					id="osta-company"
					label={isWorking ? "Current company" : "Last company"}
					required
					error={osta?.company?.message}
				>
					<Input
						id="osta-company"
						list={companies.length > 0 ? "osta-company-options" : undefined}
						disabled={disabled}
						aria-invalid={osta?.company ? true : undefined}
						{...register("osta.company", {
							required: "Please enter a company name.",
						})}
					/>
					{/* The legacy typeahead, as the platform's own control. */}
					{companies.length > 0 ? (
						<datalist id="osta-company-options">
							{companies.map((name) => (
								<option key={name} value={name} />
							))}
						</datalist>
					) : null}
				</FormField>

				<FormField
					id="osta-studentStatus"
					label="Education"
					required
					error={osta?.studentStatus?.message}
				>
					<Controller
						control={control}
						name="osta.studentStatus"
						rules={{ required: "Please select your education status." }}
						render={({ field }) => (
							<OptionSelect
								id="osta-studentStatus"
								value={field.value}
								options={EXAM_SETUP_SCHOOL_STATUSES}
								placeholder="Select education status"
								onChange={field.onChange}
								invalid={Boolean(osta?.studentStatus)}
								disabled={disabled}
							/>
						)}
					/>
				</FormField>

				<FormField
					id="osta-schoolName"
					label={isInSchool ? "Current school" : "Last school attended"}
					required
					error={osta?.schoolName?.message}
				>
					<Input
						id="osta-schoolName"
						list={schools.length > 0 ? "osta-school-options" : undefined}
						disabled={disabled}
						aria-invalid={osta?.schoolName ? true : undefined}
						{...register("osta.schoolName", {
							required: "Please enter a school name.",
						})}
					/>
					{schools.length > 0 ? (
						<datalist id="osta-school-options">
							{schools.map((name) => (
								<option key={name} value={name} />
							))}
						</datalist>
					) : null}
				</FormField>

				<FormField
					id="osta-degreeName"
					label={isInSchool ? "Degree you are seeking" : "Highest degree earned"}
					required
					error={osta?.degreeName?.message}
					className="sm:col-span-2"
				>
					<Input
						id="osta-degreeName"
						disabled={disabled}
						aria-invalid={osta?.degreeName ? true : undefined}
						{...register("osta.degreeName", {
							required: "Please enter a degree name.",
						})}
					/>
				</FormField>

				<div className="flex flex-col gap-2 sm:col-span-2">
					<Controller
						control={control}
						name="osta.ostaConsent"
						rules={{
							validate: (value) =>
								value === true ||
								"Please confirm you consent to these details being shared.",
						}}
						render={({ field }) => (
							<div className="flex items-start gap-3">
								<Checkbox
									id="osta-consent"
									checked={field.value}
									onCheckedChange={(next) => field.onChange(next === true)}
									aria-invalid={osta?.ostaConsent ? true : undefined}
									disabled={disabled}
									className="mt-0.5"
								/>
								<Label
									htmlFor="osta-consent"
									className="text-body leading-5 font-normal"
								>
									{OSTA_COPY.consent}
								</Label>
							</div>
						)}
					/>
					<FieldError message={osta?.ostaConsent?.message} />
				</div>
			</CardContent>
		</Card>
	)
}

export { OstaSection }
