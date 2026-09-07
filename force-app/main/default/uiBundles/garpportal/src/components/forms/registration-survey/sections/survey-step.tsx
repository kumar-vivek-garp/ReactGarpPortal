import type { ReactNode } from "react"

import { REGISTRATION_SURVEY_COPY } from "@/config/registration-survey"

export type SurveyStepKey = keyof typeof REGISTRATION_SURVEY_COPY.steps

/** The survey's steps, in order. Each fits a viewport without scrolling. */
export const SURVEY_STEPS: readonly SurveyStepKey[] = ["work", "experience", "education"]

type SurveyStepProps = {
	step: SurveyStepKey
	index: number
	children: ReactNode
}

/**
 * One step's frame: the "Step n of 3 · title" line and a two-column grid for
 * the four-or-so questions it holds. Short on purpose — a screen of twelve
 * questions is what makes people reach for Skip.
 */
function SurveyStep({ step, index, children }: SurveyStepProps) {
	const label = REGISTRATION_SURVEY_COPY.stepLabel
		.replace("{step}", String(index + 1))
		.replace("{count}", String(SURVEY_STEPS.length))
	return (
		<fieldset className="flex flex-col gap-4">
			<legend className="flex items-baseline gap-2">
				<span className="text-caption font-bold uppercase text-muted-foreground">
					{label}
				</span>
				<span className="text-body font-semibold text-foreground">
					{REGISTRATION_SURVEY_COPY.steps[step]}
				</span>
			</legend>
			<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">{children}</div>
		</fieldset>
	)
}

export { SurveyStep }
