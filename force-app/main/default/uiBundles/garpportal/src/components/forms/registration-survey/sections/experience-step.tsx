import { Controller, type Control, type UseFormRegister } from "react-hook-form"

import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { FormField } from "@/components/molecules/form-field"
import { SuggestInput } from "@/components/molecules/suggest-input"
import {
	asPicklistOptions,
	PicklistSelect,
} from "@/components/forms/registration-survey/sections/picklist-select"
import { SurveyStep } from "@/components/forms/registration-survey/sections/survey-step"
import type { SurveyFormValues } from "@/components/forms/registration-survey/registration-survey-values"
import { DESIGNATION_CODES } from "@/config/career-information"
import { REGISTRATION_SURVEY_LABELS } from "@/config/registration-survey"
import type { SurveyOptions } from "@/hooks/use-registration-survey"

const L = REGISTRATION_SURVEY_LABELS

type ExperienceStepProps = {
	control: Control<SurveyFormValues>
	register: UseFormRegister<SurveyFormValues>
	options: SurveyOptions
	/** Only asked once the Other designation is ticked. */
	showOtherQualifications: boolean
	disabled?: boolean
}

/** Step 2 — how long they have been at it, and the letters after their name. */
function ExperienceStep({
	control,
	register,
	options,
	showOtherQualifications,
	disabled,
}: ExperienceStepProps) {
	const years = asPicklistOptions(options.workingYears)
	return (
		<SurveyStep step="experience" index={1}>
			<FormField id="survey-corporateTitle" label={L.corporateTitle}>
				<Controller
					control={control}
					name="corporateTitle"
					render={({ field }) => (
						<PicklistSelect
							id="survey-corporateTitle"
							value={field.value}
							options={options.picklists.Corporate_Title__c ?? []}
							placeholder="Select professional level"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<FormField id="survey-industryWorkingYear" label={L.industryWorkingYear}>
				<Controller
					control={control}
					name="industryWorkingYear"
					render={({ field }) => (
						<PicklistSelect
							id="survey-industryWorkingYear"
							value={field.value}
							options={years}
							placeholder="Select year"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<FormField id="survey-riskManagementWorkingYear" label={L.riskManagementWorkingYear} className="sm:col-span-2">
				<Controller
					control={control}
					name="riskManagementWorkingYear"
					render={({ field }) => (
						<PicklistSelect
							id="survey-riskManagementWorkingYear"
							value={field.value}
							options={years}
							placeholder="Select year"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<fieldset className="flex flex-col gap-2 sm:col-span-2">
				<legend className="text-sm font-bold">{L.designations}</legend>
				<div className="grid grid-cols-3 gap-2 sm:grid-cols-6">
					{DESIGNATION_CODES.map((code) => (
						<div key={code} className="flex items-center gap-2">
							<Controller
								control={control}
								name={`designations.${code}`}
								render={({ field }) => (
									<Checkbox
										id={`survey-des-${code}`}
										checked={field.value}
										disabled={disabled}
										onCheckedChange={(checked) => field.onChange(checked === true)}
									/>
								)}
							/>
							<Label htmlFor={`survey-des-${code}`} className="font-normal">
								{code}
							</Label>
						</div>
					))}
					<div className="flex items-center gap-2">
						<Controller
							control={control}
							name="otherDesignation"
							render={({ field }) => (
								<Checkbox
									id="survey-des-other"
									checked={field.value}
									disabled={disabled}
									onCheckedChange={(checked) => field.onChange(checked === true)}
								/>
							)}
						/>
						<Label htmlFor="survey-des-other" className="font-normal">
							Other
						</Label>
					</div>
				</div>
			</fieldset>
			{showOtherQualifications ? (
				<FormField
					id="survey-otherQualifications"
					label={L.otherQualifications}
					className="sm:col-span-2"
				>
					<SuggestInput
						id="survey-otherQualifications"
						suggestions={[]}
						maxLength={255}
						disabled={disabled}
						{...register("otherQualifications")}
					/>
				</FormField>
			) : null}
		</SurveyStep>
	)
}

export { ExperienceStep }
