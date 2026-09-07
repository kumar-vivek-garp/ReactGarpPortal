import { Globe, MapPin, ShieldCheck } from "lucide-react"
import { Controller, type Control, type FieldErrors } from "react-hook-form"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { DatePicker } from "@/components/molecules/date-picker"
import { FieldError, FormField } from "@/components/molecules/form-field"
import { TileRadioGroup, type TileRadioOption } from "@/components/molecules/tile-radio-group"
import { OptionSelect } from "@/components/forms/exam-setup/sections/option-select"
import {
	EXAM_SETUP_CONSENT_LABEL,
	EXAM_SETUP_GENDERS,
	EXAM_SETUP_SECTIONS,
} from "@/config/exam-setup"
import type { ExamSetupIdFormValues } from "@/lib/exam-setup-presentation"

const ID_LOCATION_OPTIONS: TileRadioOption[] = [
	{ value: "China", label: "China", icon: MapPin },
	{ value: "Non-China", label: "Non-China", icon: Globe },
]

/** Nobody sitting an exam was born before this; the dropdown need not offer it. */
const EARLIEST_BIRTH_YEAR = 1920

type OstaSectionProps = {
	control: Control<ExamSetupIdFormValues>
	errors: FieldErrors<ExamSetupIdFormValues>
	/** `Currently_Working_Status__c`, from `GET /memberportal/options`. */
	workingStatuses: string[]
	/** `Currently_in_School_Status__c`, from the same call. */
	schoolStatuses: string[]
}

/**
 * What a mainland-China centre additionally needs: the candidate's Chinese
 * name, date of birth, gender, contact number and working/schooling status,
 * plus explicit consent to share the ID with OSTA.
 *
 * KNOWN LIMIT: `isOSTA` describes where the member sits TODAY, not where they
 * have just chosen to sit. The site list carries only `{ id, name, isSelected }`
 * — the flag that decides this is `Exam_Site__r.Site__r.Is_OSTA_Information_Required__c`,
 * which is not on the wire — so a member moving INTO a China centre is not
 * asked for these until they come back. Apex accepts that save (it writes the
 * OSTA block only `if (ostaIDLocation != null)`).
 */
function OstaSection({
	control,
	errors,
	workingStatuses,
	schoolStatuses,
}: OstaSectionProps) {
	const today = new Date()

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<Globe className="size-5 text-muted-foreground" aria-hidden />
					{EXAM_SETUP_SECTIONS.osta.title}
				</CardTitle>
				<p className="text-body text-muted-foreground">
					{EXAM_SETUP_SECTIONS.osta.description}
				</p>
			</CardHeader>
			<CardContent className="flex flex-col gap-6">
				{/* Consent first — the rest is only asked for once it is given. */}
				<Controller
					control={control}
					name="ostaConsent"
					render={({ field }) => (
						<div className="flex flex-col gap-2">
							<div className="flex items-start gap-3">
								<ShieldCheck
									className="mt-0.5 size-5 shrink-0 text-muted-foreground"
									aria-hidden
								/>
								<Checkbox
									id="exam-setup-osta-consent"
									className="mt-0.5"
									checked={field.value}
									onCheckedChange={(next) => field.onChange(next === true)}
									aria-invalid={errors.ostaConsent ? true : undefined}
								/>
								<Label
									htmlFor="exam-setup-osta-consent"
									className="font-normal leading-snug"
								>
									{EXAM_SETUP_CONSENT_LABEL}
								</Label>
							</div>
							<FieldError message={errors.ostaConsent?.message} className="pl-8" />
						</div>
					)}
				/>

				<Controller
					control={control}
					name="ostaIDLocation"
					render={({ field }) => (
						<TileRadioGroup
							id="exam-setup-osta-location"
							legend="Where was your ID issued?"
							required
							value={field.value}
							options={ID_LOCATION_OPTIONS}
							onChange={field.onChange}
							error={errors.ostaIDLocation?.message}
						/>
					)}
				/>

				<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
					<Controller
						control={control}
						name="ostaFullNameInChinese"
						render={({ field }) => (
							<FormField
								id="exam-setup-osta-name"
								label="Full name in Chinese (中文姓名)"
								required
								error={errors.ostaFullNameInChinese?.message}
							>
								<Input
									id="exam-setup-osta-name"
									aria-invalid={errors.ostaFullNameInChinese ? true : undefined}
									{...field}
								/>
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaDateOfBirth"
						render={({ field }) => (
							<FormField
								id="exam-setup-osta-dob"
								label="Date of birth"
								required
								error={errors.ostaDateOfBirth?.message}
							>
								<DatePicker
									id="exam-setup-osta-dob"
									value={field.value}
									onChange={field.onChange}
									placeholder="Select your date of birth"
									startMonth={new Date(EARLIEST_BIRTH_YEAR, 0)}
									endMonth={today}
									aria-invalid={Boolean(errors.ostaDateOfBirth)}
								/>
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaGender"
						render={({ field }) => (
							<FormField
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
									aria-invalid={Boolean(errors.ostaGender)}
								/>
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaPhoneNumber"
						render={({ field }) => (
							<FormField
								id="exam-setup-osta-phone"
								label="Phone number"
								required
								error={errors.ostaPhoneNumber?.message}
							>
								<Input
									id="exam-setup-osta-phone"
									type="tel"
									inputMode="numeric"
									aria-invalid={errors.ostaPhoneNumber ? true : undefined}
									{...field}
								/>
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaCurrentWorkingStatus"
						render={({ field }) => (
							<FormField id="exam-setup-osta-working" label="Current working status">
								<OptionSelect
									id="exam-setup-osta-working"
									value={field.value}
									options={workingStatuses}
									placeholder="Select"
									onChange={field.onChange}
								/>
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaCompany"
						render={({ field }) => (
							<FormField id="exam-setup-osta-company" label="Company">
								<Input id="exam-setup-osta-company" {...field} />
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaCurrentSchoolStatus"
						render={({ field }) => (
							<FormField id="exam-setup-osta-school-status" label="Current school status">
								<OptionSelect
									id="exam-setup-osta-school-status"
									value={field.value}
									options={schoolStatuses}
									placeholder="Select"
									onChange={field.onChange}
								/>
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaSchool"
						render={({ field }) => (
							<FormField id="exam-setup-osta-school" label="School">
								<Input id="exam-setup-osta-school" {...field} />
							</FormField>
						)}
					/>

					<Controller
						control={control}
						name="ostaDegreeProgramName"
						render={({ field }) => (
							<FormField
								id="exam-setup-osta-degree"
								label="Degree program name"
								className="sm:col-span-2"
							>
								<Input id="exam-setup-osta-degree" {...field} />
							</FormField>
						)}
					/>
				</div>
			</CardContent>
		</Card>
	)
}

export { OstaSection }
