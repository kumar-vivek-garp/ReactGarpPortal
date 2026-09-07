import { Controller, type Control, type UseFormRegister } from "react-hook-form"

import { FormField } from "@/components/molecules/form-field"
import { SuggestInput } from "@/components/molecules/suggest-input"
import { PicklistSelect } from "@/components/forms/registration-survey/sections/picklist-select"
import { SurveyStep } from "@/components/forms/registration-survey/sections/survey-step"
import type { SurveyFormValues } from "@/components/forms/registration-survey/registration-survey-values"
import { REGISTRATION_SURVEY_LABELS } from "@/config/registration-survey"
import type { SurveyOptions } from "@/hooks/use-registration-survey"

const L = REGISTRATION_SURVEY_LABELS

type WorkStepProps = {
	control: Control<SurveyFormValues>
	register: UseFormRegister<SurveyFormValues>
	options: SurveyOptions
	/** Only asked under the Risk Management job function. */
	showRiskSpecialty: boolean
	disabled?: boolean
}

/** Step 1 — where they work and what they do. */
function WorkStep({ control, register, options, showRiskSpecialty, disabled }: WorkStepProps) {
	const picklists = options.picklists
	return (
		<SurveyStep step="work" index={0}>
			<FormField id="survey-workingStatus" label={L.workingStatus}>
				<Controller
					control={control}
					name="workingStatus"
					render={({ field }) => (
						<PicklistSelect
							id="survey-workingStatus"
							value={field.value}
							options={picklists.Currently_Working_Status__c ?? []}
							placeholder="Select work status"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<FormField id="survey-industry" label={L.industry}>
				<Controller
					control={control}
					name="industry"
					render={({ field }) => (
						<PicklistSelect
							id="survey-industry"
							value={field.value}
							options={picklists.Area_of_Concentration__c ?? []}
							placeholder="Select industry"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			<FormField id="survey-company" label={L.company}>
				<SuggestInput
					id="survey-company"
					suggestions={options.organizations}
					maxLength={255}
					disabled={disabled}
					{...register("company")}
				/>
			</FormField>
			<FormField id="survey-jobFunction" label={L.jobFunction}>
				<Controller
					control={control}
					name="jobFunction"
					render={({ field }) => (
						<PicklistSelect
							id="survey-jobFunction"
							value={field.value}
							options={picklists.Job_Function__c ?? []}
							placeholder="Select job function"
							onChange={field.onChange}
							disabled={disabled}
						/>
					)}
				/>
			</FormField>
			{showRiskSpecialty ? (
				<FormField id="survey-riskSpecialty" label={L.riskSpecialty}>
					<Controller
						control={control}
						name="riskSpecialty"
						render={({ field }) => (
							<PicklistSelect
								id="survey-riskSpecialty"
								value={field.value}
								options={picklists.Risk_Specialty__c ?? []}
								placeholder="Select specialty"
								onChange={field.onChange}
								disabled={disabled}
							/>
						)}
					/>
				</FormField>
			) : null}
		</SurveyStep>
	)
}

export { WorkStep }
