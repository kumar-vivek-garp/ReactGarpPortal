import { useState } from "react"
import { animated, useSprings, useTransition } from "@react-spring/web"
import { BookOpen, ClipboardList, MapPin, TrendingUp, type LucideIcon } from "lucide-react"
import { useForm, useWatch } from "react-hook-form"

import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { EducationStep } from "@/components/forms/registration-survey/sections/education-step"
import { ExperienceStep } from "@/components/forms/registration-survey/sections/experience-step"
import { SURVEY_STEPS } from "@/components/forms/registration-survey/sections/survey-step"
import { WorkStep } from "@/components/forms/registration-survey/sections/work-step"
import {
	surveyProgress,
	type SurveyFormValues,
} from "@/components/forms/registration-survey/registration-survey-values"
import { CompletionRing } from "@/components/molecules/completion-ring"
import { RISK_JOB_FUNCTION } from "@/config/career-information"
import { REGISTRATION_SURVEY_COPY } from "@/config/registration-survey"
import type { SurveyOptions } from "@/hooks/use-registration-survey"

const BENEFIT_ICONS: LucideIcon[] = [BookOpen, MapPin, TrendingUp]

/** Physics for the step change: quick to settle, no overshoot on layout. */
const STEP_SPRING = { mass: 0.9, tension: 320, friction: 26 }
/** The segment fill sweeps a little slower, so it reads as progress. */
const SEGMENT_SPRING = { mass: 1, tension: 220, friction: 28 }
/** How far a step slides in from the direction of travel. */
const STEP_SLIDE_PX = 28

type RegistrationSurveyFormProps = {
	options: SurveyOptions
	/** Read once at mount — mount this form only when the seed is in hand. */
	defaultValues: SurveyFormValues
	/** The programme's short name for the title — "FRM". */
	programName?: string | null
	isSaving: boolean
	/** A failed save, shown inline. The form stays so they can retry or skip. */
	failure: string | null
	onSkip: () => void
	onSubmit: (values: SurveyFormValues) => void
	className?: string
}

/**
 * The "Complete Your Profile" questions — the same fields as My Account's
 * career form, asked once straight after a registration lands.
 *
 * ENTIRELY OPTIONAL, and nothing is validated, so the work here is making it
 * worth answering and easy to finish: the header says what the answers buy,
 * the questions come three or four at a time in steps that fit one screen,
 * the ring fills with every answer, and Skip is a deferral rather than the
 * primary action. Values survive a step change (react-hook-form keeps
 * unmounted fields), so Back never loses anything. Which backend the answers
 * go to is the data owner's business, not this form's.
 */
function RegistrationSurveyForm({
	options,
	defaultValues,
	programName,
	isSaving,
	failure,
	onSkip,
	onSubmit,
	className,
}: RegistrationSurveyFormProps) {
	const { control, register, handleSubmit } = useForm<SurveyFormValues>({
		defaultValues,
		mode: "onTouched",
	})
	/*
	 * The step and the direction it was reached by, as one value: Next slides
	 * the new step in from the right, Back from the left, and the transition
	 * config reads the direction during render.
	 */
	const [{ stepIndex, direction }, setPosition] = useState<{
		stepIndex: number
		direction: 1 | -1
	}>({ stepIndex: 0, direction: 1 })
	const isLast = stepIndex === SURVEY_STEPS.length - 1
	const goTo = (next: number) => {
		setPosition({ stepIndex: next, direction: next > stepIndex ? 1 : -1 })
	}

	/*
	 * The step segments fill one after another as the candidate advances, and
	 * drain again on Back — a spring on each segment's width, not a class
	 * swap, so the bar visibly travels.
	 */
	const [segments] = useSprings(
		SURVEY_STEPS.length,
		(index) => ({
			width: index <= stepIndex ? "100%" : "0%",
			config: SEGMENT_SPRING,
		}),
		[stepIndex],
	)

	/*
	 * The outgoing step slides away before the incoming one arrives
	 * (`exitBeforeEnter`), so the two never stack and the card's height only
	 * ever changes once per step. Direction follows the button pressed.
	 */
	const stepTransition = useTransition(stepIndex, {
		keys: (index: number) => index,
		from: { opacity: 0, x: direction * STEP_SLIDE_PX },
		enter: { opacity: 1, x: 0 },
		leave: { opacity: 0, x: -direction * STEP_SLIDE_PX },
		exitBeforeEnter: true,
		config: STEP_SPRING,
	})

	// `useWatch`, not the destructured `watch()` — see the exam form. The whole
	// value set is watched here because the progress ring reads every answer.
	const watched = useWatch({ control }) as Partial<SurveyFormValues>
	const values: SurveyFormValues = { ...defaultValues, ...watched }
	const progress = surveyProgress(values)
	// A specialty only means anything under Risk Management. The control is
	// hidden otherwise, and `toSurveyPayload` drops the value, so a stale
	// answer is never posted.
	const showRiskSpecialty = values.jobFunction === RISK_JOB_FUNCTION

	const title = programName
		? REGISTRATION_SURVEY_COPY.title.replace("{program}", programName)
		: REGISTRATION_SURVEY_COPY.titleFallback
	const progressText = REGISTRATION_SURVEY_COPY.progress
		.replace("{answered}", String(progress.answered))
		.replace("{total}", String(progress.total))

	return (
		<form
			className={className}
			noValidate
			onSubmit={handleSubmit((submitted) => onSubmit(submitted))}
			aria-label={title}
		>
			<Card className="flex flex-col gap-5 p-5 sm:p-6">
				{/* Why answer, in one glance: pitch left, progress right. */}
				<div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
					<div className="flex flex-col gap-2">
						<h3 className="font-heading text-xl font-semibold tracking-wide text-foreground">
							{title}
						</h3>
						<p className="text-sm text-muted-foreground">{REGISTRATION_SURVEY_COPY.intro}</p>
						<ul className="flex flex-wrap gap-x-4 gap-y-1">
							{REGISTRATION_SURVEY_COPY.benefits.map((benefit, index) => {
								const Icon = BENEFIT_ICONS[index] ?? BookOpen
								return (
									<li
										key={benefit.title}
										className="flex items-center gap-1.5 text-caption text-muted-foreground"
										title={benefit.description}
									>
										<Icon className="size-3.5 text-primary" aria-hidden />
										{benefit.title}
									</li>
								)
							})}
						</ul>
					</div>
					<div className="flex shrink-0 items-center gap-3 sm:flex-col sm:gap-1">
						<CompletionRing
							percent={progress.percent}
							className="size-14 text-primary"
							label={REGISTRATION_SURVEY_COPY.progressLabel}
						>
							<ClipboardList className="size-5 text-muted-foreground" aria-hidden />
						</CompletionRing>
						<span className="text-caption whitespace-nowrap text-muted-foreground" aria-live="polite">
							{progressText}
						</span>
					</div>
				</div>

				{/* Where they are in the three steps. */}
				<ol className="flex gap-1.5" aria-hidden>
					{segments.map((style, index) => (
						<li
							key={SURVEY_STEPS[index]}
							className="h-1 flex-1 overflow-hidden rounded-full bg-muted"
						>
							<animated.div className="h-full rounded-full bg-primary" style={style} />
						</li>
					))}
				</ol>

				{/* Overflow clipped so the sliding step never widens the card. */}
				<div className="overflow-x-clip">
					{stepTransition((style, index) => {
						const step = SURVEY_STEPS[index]
						return (
							<animated.div style={style}>
								{step === "work" ? (
									<WorkStep
										control={control}
										register={register}
										options={options}
										showRiskSpecialty={showRiskSpecialty}
										disabled={isSaving}
									/>
								) : step === "experience" ? (
									<ExperienceStep
										control={control}
										register={register}
										options={options}
										showOtherQualifications={values.otherDesignation === true}
										disabled={isSaving}
									/>
								) : (
									<EducationStep
										control={control}
										register={register}
										options={options}
										disabled={isSaving}
									/>
								)}
							</animated.div>
						)
					})}
				</div>

				{failure ? (
					<Alert variant="destructive">
						<AlertTitle>Your answers could not be saved</AlertTitle>
						<AlertDescription>{failure}</AlertDescription>
					</Alert>
				) : null}

				<div className="flex flex-col gap-3 border-t border-border pt-4 sm:flex-row sm:items-center sm:justify-between">
					<div className="flex items-center gap-3">
						<Button type="button" variant="ghost" disabled={isSaving} onClick={onSkip}>
							{REGISTRATION_SURVEY_COPY.skip}
						</Button>
						<p className="hidden text-caption text-muted-foreground lg:block">
							{REGISTRATION_SURVEY_COPY.footnote}
						</p>
					</div>
					<div className="flex items-center justify-end gap-3">
						{stepIndex > 0 ? (
							<Button
								type="button"
								variant="outline"
								disabled={isSaving}
								onClick={() => goTo(stepIndex - 1)}
							>
								{REGISTRATION_SURVEY_COPY.back}
							</Button>
						) : null}
						{/*
						 * Distinct keys, deliberately. Without them React keeps ONE
						 * button node and flips its `type` from "button" to "submit"
						 * as the last step arrives — and the very click that reached
						 * that step then runs the browser's submit as its default
						 * action, saving a survey nobody finished. Shipped once.
						 */}
						{isLast ? (
							<Button key="save" type="submit" disabled={isSaving}>
								{isSaving
									? REGISTRATION_SURVEY_COPY.saving
									: REGISTRATION_SURVEY_COPY.submit}
							</Button>
						) : (
							<Button
								key="next"
								type="button"
								disabled={isSaving}
								onClick={() => goTo(stepIndex + 1)}
							>
								{REGISTRATION_SURVEY_COPY.next}
							</Button>
						)}
					</div>
				</div>
			</Card>
		</form>
	)
}

export { RegistrationSurveyForm }
