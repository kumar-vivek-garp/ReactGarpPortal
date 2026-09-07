import { useState } from "react"

import { AppError, notifySuccess } from "@/api/client"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { RegistrationSurveyForm } from "@/components/forms/registration-survey/registration-survey-form"
import {
	EMPTY_SURVEY_VALUES,
	toSurveyPayload,
	toSurveyValues,
} from "@/components/forms/registration-survey/registration-survey-values"
import { SkeletonField } from "@/components/molecules/form-skeleton"
import { REGISTRATION_SURVEY_COPY } from "@/config/registration-survey"
import { useCurrentUser } from "@/hooks/use-current-user"
import {
	useRegistrationSurveySave,
	useRegistrationSurveySource,
} from "@/hooks/use-registration-survey"

export type SurveyOutcome = "saved" | "skipped" | "unavailable"

type RegistrationSurveyProps = {
	/**
	 * The guest save key: the caller's own registration id (order or staged
	 * row). Internal — it never travels in a URL. Ignored for a member, whose
	 * answers save through their own profile.
	 */
	surveyKey: string | null
	/** Called once the survey is over, whichever way it ended. */
	onFinished: (outcome: SurveyOutcome) => void
	/** The programme's short name, for the title — "FRM". */
	programName?: string | null
	className?: string
}

/**
 * The post-registration survey's data owner, rendered inline on the outcome
 * screens straight after payment confirms — GarpAppv1's registration-
 * information sequence: poll, then "Complete Your Profile", then thank-you.
 *
 * Two save paths, picked here from the CLIENT session and never by the
 * caller: a member reads and writes through the member portal; a guest reads
 * the registration module's own picklists and saves with `surveyKey`, from
 * which the server resolves the contact. A guest with no key, or a session
 * with no member record (an internal org user), has nothing to attach answers
 * to — rather than collect answers that would be dropped, the survey reports
 * itself unavailable and offers Continue.
 */
function RegistrationSurvey({
	surveyKey,
	onFinished,
	programName,
	className,
}: RegistrationSurveyProps) {
	const currentUser = useCurrentUser()
	const mode = currentUser.data ? "member" : "guest"
	const source = useRegistrationSurveySource(mode, surveyKey)
	const save = useRegistrationSurveySave(mode, surveyKey)
	const [failure, setFailure] = useState<string | null>(null)

	if (currentUser.isPending || source.isPending) {
		return (
			<div
				className="grid grid-cols-1 gap-4 sm:grid-cols-2"
				aria-busy
				aria-live="polite"
			>
				<span className="sr-only">Loading the survey…</span>
				<SkeletonField />
				<SkeletonField />
				<SkeletonField />
				<SkeletonField />
			</div>
		)
	}

	if (source.isUnavailable || !source.options) {
		return (
			<div className={className}>
				<Alert>
					<AlertTitle>{REGISTRATION_SURVEY_COPY.unavailableTitle}</AlertTitle>
					<AlertDescription>
						{REGISTRATION_SURVEY_COPY.unavailableMessage}
					</AlertDescription>
				</Alert>
				<div className="mt-4 flex justify-end">
					<Button variant="ghost" onClick={() => onFinished("unavailable")}>
						{REGISTRATION_SURVEY_COPY.continue}
					</Button>
				</div>
			</div>
		)
	}

	return (
		<RegistrationSurveyForm
			className={className}
			options={source.options}
			programName={programName}
			defaultValues={
				source.account ? toSurveyValues(source.account) : EMPTY_SURVEY_VALUES
			}
			isSaving={save.isPending}
			failure={failure}
			onSkip={() => onFinished("skipped")}
			onSubmit={(values) => {
				setFailure(null)
				save.mutate(toSurveyPayload(values), {
					onSuccess: () => {
						// The one bit of feedback the answers earn — the actions that
						// replace the form say nothing about them.
						notifySuccess(REGISTRATION_SURVEY_COPY.saved)
						onFinished("saved")
					},
					onError: (error) => {
						setFailure(AppError.fromUnknown(error).messages[0])
					},
				})
			}}
		/>
	)
}

export { RegistrationSurvey }
