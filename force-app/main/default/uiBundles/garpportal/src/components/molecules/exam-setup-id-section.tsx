import { Controller, type Control, type FieldErrors } from "react-hook-form"

import { Input } from "@/components/atoms/input"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { ExamSetupField } from "@/components/molecules/exam-setup-field"
import {
	EXAM_SETUP_GENDERS,
	EXAM_SETUP_ID_LOCATIONS,
	EXAM_SETUP_ID_TYPES,
	EXAM_SETUP_ID_ON_FILE_HINT,
	EXAM_SETUP_PASSPORT_HINT,
	EXAM_SETUP_SCHOOL_STATUSES,
	EXAM_SETUP_WORKING_STATUSES,
} from "@/config/exam-setup"
import { cn } from "@/lib/utils"

/** The shape the panel's `useForm` holds. Dates are ISO here; converted on submit. */
export type ExamSetupIdFormValues = {
	idName: string
	idNumber: string
	idType: string
	idExpireDate: string
	mobilePhoneLocation: string
	mobilePhoneNumber: string
	ostaIDLocation: string
	ostaGender: string
	ostaFullNameInChinese: string
	ostaDateOfBirth: string
	ostaPhoneNumber: string
	ostaCurrentWorkingStatus: string
	ostaCompany: string
	ostaCurrentSchoolStatus: string
	ostaSchool: string
	ostaDegreeProgramName: string
}

type OptionSelectProps = {
	id: string
	value: string
	options: readonly string[]
	placeholder: string
	onChange: (value: string) => void
}

function OptionSelect({
	id,
	value,
	options,
	placeholder,
	onChange,
}: OptionSelectProps) {
	return (
		// `value` is always a string, never undefined: handing Radix `undefined`
		// on the first render (before the payload lands) latches the Select into
		// uncontrolled mode, and every later value is then ignored — the field
		// renders its placeholder forever and saves blank over stored data.
		<Select value={value} onValueChange={onChange}>
			<SelectTrigger id={id} className="w-full">
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

type ExamSetupIdSectionProps = {
	control: Control<ExamSetupIdFormValues>
	errors: FieldErrors<ExamSetupIdFormValues>
	/** Apex `isIDRequired` — true for FRM sites, which demand government ID. */
	isIDRequired: boolean
	/** True when a number is already stored, so blank means "leave it alone". */
	idOnFile: boolean
	/** Apex `isOSTA` — true when either part sits at a mainland-China centre. */
	isOSTA: boolean
	/** Picklist values of `Contact.Mobile_Phone_Code__c`. */
	mobilePhoneLocations: string[]
	/** Watched separately so the passport hint only shows for a passport. */
	idType: string
	/** Watched so the company and school labels read correctly. */
	workingStatus: string
	schoolStatus: string
	className?: string
}

/**
 * "Confirm your ID" — the details the test centre checks on exam day.
 *
 * Two conditional layers, both server-decided rather than inferred:
 *
 *   `isIDRequired`  FRM sites demand a government ID, so the four base fields
 *                   become mandatory. Other programmes still collect them.
 *   `isOSTA`        a mainland-China centre additionally needs the candidate's
 *                   Chinese name, date of birth, gender and working/schooling
 *                   status. Hidden entirely elsewhere — it is a long block and
 *                   irrelevant to most members.
 *
 * KNOWN LIMIT: `isOSTA` describes where the member sits TODAY, not where they
 * have just chosen to sit. The site list carries only `{ id, name, isSelected }`
 * — the flag that decides this is `Exam_Site__r.Site__r.Is_OSTA_Information_Required__c`,
 * which is not on the wire — so a member moving INTO a China centre is not
 * asked for these fields until they come back. Apex accepts that save (it
 * writes the OSTA block only `if (ostaIDLocation != null)`), and today the
 * provider step is a MyGarp hand-off which collects them anyway. It stops being
 * harmless the moment `EXAM_SETUP_AUTHORIZE_ENABLED` is turned on.
 *
 * The company and school labels change with the status above them, the way the
 * legacy's do: "Current Company" against Working, "Last Company" against Not
 * Working. Asking for a *current* employer of someone who just said they are
 * not working reads as though the form was not listening.
 */
function ExamSetupIdSection({
	control,
	errors,
	isIDRequired,
	idOnFile,
	isOSTA,
	mobilePhoneLocations,
	idType,
	workingStatus,
	schoolStatus,
	className,
}: ExamSetupIdSectionProps) {
	const isWorking = workingStatus === "Working"
	const isInSchool = schoolStatus === "In School"

	return (
		<div className={cn("space-y-6", className)}>
			<div className="grid gap-4 sm:grid-cols-2">
				<Controller
					control={control}
					name="idName"
					render={({ field }) => (
						<ExamSetupField
							id="exam-setup-id-name"
							label="Name as it appears on your ID"
							required={isIDRequired}
							error={errors.idName?.message}
						>
							<Input id="exam-setup-id-name" {...field} />
						</ExamSetupField>
					)}
				/>

				<Controller
					control={control}
					name="idType"
					render={({ field }) => (
						<ExamSetupField
							id="exam-setup-id-type"
							label="ID type"
							required={isIDRequired}
							error={errors.idType?.message}
						>
							<OptionSelect
								id="exam-setup-id-type"
								value={field.value}
								options={EXAM_SETUP_ID_TYPES}
								placeholder="Select an ID type"
								onChange={field.onChange}
							/>
						</ExamSetupField>
					)}
				/>

				<Controller
					control={control}
					name="idNumber"
					render={({ field }) => (
						<ExamSetupField
							id="exam-setup-id-number"
							label="ID number"
							required={isIDRequired && !idOnFile}
							error={errors.idNumber?.message}
							hint={
								idOnFile
									? EXAM_SETUP_ID_ON_FILE_HINT
									: idType === "Passport"
										? EXAM_SETUP_PASSPORT_HINT
										: undefined
							}
						>
							<Input id="exam-setup-id-number" {...field} />
						</ExamSetupField>
					)}
				/>

				<Controller
					control={control}
					name="idExpireDate"
					render={({ field }) => (
						<ExamSetupField
							id="exam-setup-id-expiry"
							label="ID expiry date"
							required={isIDRequired}
							error={errors.idExpireDate?.message}
						>
							{/* Bound as ISO because that is what Apex returns AND what the
							    control accepts; `toIdInput` converts on submit. */}
							<Input id="exam-setup-id-expiry" type="date" {...field} />
						</ExamSetupField>
					)}
				/>

				<Controller
					control={control}
					name="mobilePhoneLocation"
					render={({ field }) => (
						<ExamSetupField
							id="exam-setup-phone-location"
							label="Mobile country code"
							error={errors.mobilePhoneLocation?.message}
						>
							<OptionSelect
								id="exam-setup-phone-location"
								value={field.value}
								options={mobilePhoneLocations}
								placeholder="Select a country"
								onChange={field.onChange}
							/>
						</ExamSetupField>
					)}
				/>

				<Controller
					control={control}
					name="mobilePhoneNumber"
					render={({ field }) => (
						<ExamSetupField
							id="exam-setup-phone-number"
							label="Mobile number"
							error={errors.mobilePhoneNumber?.message}
						>
							<Input id="exam-setup-phone-number" type="tel" {...field} />
						</ExamSetupField>
					)}
				/>
			</div>

			{isOSTA ? (
				<fieldset className="space-y-4 rounded-xl border border-border bg-muted/20 p-4">
					<legend className="px-1 text-sm font-semibold text-foreground">
						Additional details for your exam centre
					</legend>
					<p className="text-xs text-muted-foreground">
						Your exam centre requires these before you can be scheduled.
					</p>

					<div className="grid gap-4 sm:grid-cols-2">
						<Controller
							control={control}
							name="ostaFullNameInChinese"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-name"
									label="Full name in Chinese"
									required
									error={errors.ostaFullNameInChinese?.message}
								>
									<Input id="exam-setup-osta-name" {...field} />
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaIDLocation"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-location"
									label="ID issued in"
									required
									error={errors.ostaIDLocation?.message}
								>
									<OptionSelect
										id="exam-setup-osta-location"
										value={field.value}
										options={EXAM_SETUP_ID_LOCATIONS}
										placeholder="Select a location"
										onChange={field.onChange}
									/>
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaGender"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-gender"
									label="Gender"
									required
									error={errors.ostaGender?.message}
								>
									<OptionSelect
										id="exam-setup-osta-gender"
										value={field.value}
										options={EXAM_SETUP_GENDERS}
										placeholder="Select"
										onChange={field.onChange}
									/>
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaDateOfBirth"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-dob"
									label="Date of birth"
									required
									error={errors.ostaDateOfBirth?.message}
								>
									<Input id="exam-setup-osta-dob" type="date" {...field} />
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaPhoneNumber"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-phone"
									label="Phone number"
									error={errors.ostaPhoneNumber?.message}
								>
									<Input id="exam-setup-osta-phone" type="tel" {...field} />
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaCurrentWorkingStatus"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-working"
									label="Working status"
									required
									error={errors.ostaCurrentWorkingStatus?.message}
								>
									<OptionSelect
										id="exam-setup-osta-working"
										value={field.value}
										options={EXAM_SETUP_WORKING_STATUSES}
										placeholder="Select"
										onChange={field.onChange}
									/>
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaCompany"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-company"
									label={isWorking ? "Current company" : "Last company"}
									error={errors.ostaCompany?.message}
								>
									<Input id="exam-setup-osta-company" {...field} />
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaCurrentSchoolStatus"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-school-status"
									label="Schooling status"
									required
									error={errors.ostaCurrentSchoolStatus?.message}
								>
									<OptionSelect
										id="exam-setup-osta-school-status"
										value={field.value}
										options={EXAM_SETUP_SCHOOL_STATUSES}
										placeholder="Select"
										onChange={field.onChange}
									/>
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaSchool"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-school"
									label={
										isInSchool ? "Current school" : "Last school attended"
									}
									error={errors.ostaSchool?.message}
								>
									<Input id="exam-setup-osta-school" {...field} />
								</ExamSetupField>
							)}
						/>

						<Controller
							control={control}
							name="ostaDegreeProgramName"
							render={({ field }) => (
								<ExamSetupField
									id="exam-setup-osta-degree"
									label={
										isInSchool
											? "Degree you are seeking"
											: "Highest degree earned"
									}
									error={errors.ostaDegreeProgramName?.message}
								>
									<Input id="exam-setup-osta-degree" {...field} />
								</ExamSetupField>
							)}
						/>
					</div>
				</fieldset>
			) : null}
		</div>
	)
}

export { ExamSetupIdSection }
