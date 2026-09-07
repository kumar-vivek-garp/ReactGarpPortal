import { Controller, type Control, type UseFormRegister } from "react-hook-form"

import { FormField } from "@/components/molecules/form-field"
import { SuggestInput } from "@/components/molecules/suggest-input"
import {
	asPicklistOptions,
	PicklistSelect,
} from "@/components/forms/registration-survey/sections/picklist-select"
import { SurveyStep } from "@/components/forms/registration-survey/sections/survey-step"
import type { SurveyFormValues } from "@/components/forms/registration-survey/registration-survey-values"
import { REGISTRATION_SURVEY_LABELS } from "@/config/registration-survey"
import type { SurveyOptions } from "@/hooks/use-registration-survey"

const L = REGISTRATION_SURVEY_LABELS

type EducationStepProps = {
	control: Control<SurveyFormValues>
	register: UseFormRegister<SurveyFormValues>
	options: SurveyOptions
	disabled?: boolean
}

/** Step 3 — where they studied. */
function EducationStep({ control, register, options, disabled }: EducationStepProps) {
	return (
		<SurveyStep step="education" index={2}>
			<FormField id="survey-school" label={L.school}>
				<SuggestInput
					id="survey-school"
					suggestions={options.schools}
					maxLength={255}
					disabled={disabled}
					{...register("school")}
				/>
			</FormField>
			<FormField id="survey-highestDegree" label={L.highestDegree}>
				<Controller
					control={control}
					name="highestDegree"
					render={({ field }) => (
						<PicklistSelect
							id="survey-highestDegree"
							value={field.value}
							options={options.picklists.Highest_Degree__c ?? []}
							placeholder="Select degree programme"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<FormField id="survey-graduationYear" label={L.graduationYear}>
				<Controller
					control={control}
					name="graduationYear"
					render={({ field }) => (
						<PicklistSelect
							id="survey-graduationYear"
							value={field.value}
							options={asPicklistOptions(options.graduationYears)}
							placeholder="Select year"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<FormField id="survey-graduationMonth" label={L.graduationMonth}>
				<Controller
					control={control}
					name="graduationMonth"
					render={({ field }) => (
						<PicklistSelect
							id="survey-graduationMonth"
							value={field.value}
							options={options.picklists.Expected_Graduation_Month__c ?? []}
							placeholder="Select month"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
		</SurveyStep>
	)
}

export { EducationStep }
