import { useState, type FormEvent, type ReactNode } from "react"
import { useForm, type Resolver } from "react-hook-form"
import { animated } from "@react-spring/web"
import { CalendarX2, CircleAlert, CircleSlash, ReceiptText } from "lucide-react"

import type {
	ExamSetupFeesView,
	ExamSetupIdSaveResult,
	ExamSetupProgramType,
	ExamSetupView,
} from "@/api/exam-setup"
import { Alert, AlertDescription } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { ExamSetupOutcome } from "@/components/forms/exam-setup/sections/exam-setup-outcome"
import { ExamSetupRail } from "@/components/forms/exam-setup/sections/exam-setup-rail"
import { IdentitySection } from "@/components/forms/exam-setup/sections/identity-section"
import { OstaSection } from "@/components/forms/exam-setup/sections/osta-section"
import { SittingSection } from "@/components/forms/exam-setup/sections/sitting-section"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_BAR_TOTAL_BLOCK,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_SHELL,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { CardCta } from "@/components/molecules/card-cta"
import { EmptyState } from "@/components/molecules/empty-state"
import { ExamSetupContentSkeleton } from "@/components/molecules/page-pending"
import { ProgramBarIdentity } from "@/components/molecules/program-bar-identity"
import { registrationChromeForSlug } from "@/lib/registration-chrome"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import {
	EXAM_SETUP_MESSAGES,
	EXAM_SETUP_REFUSALS,
	EXAM_SETUP_SCHOOL_STATUS_PICKLIST,
	EXAM_SETUP_SUBMIT_LABEL,
	EXAM_SETUP_WORKING_STATUS_PICKLIST,
} from "@/config/exam-setup"
import type { MegaMenuHeading } from "@/config/navigation/types"
import { useAccountOptions } from "@/hooks/use-account-options"
import {
	useAuthorizeExamSetup,
	useExamSetup,
	useExamSetupFees,
	useSaveExamSetup,
} from "@/hooks/use-exam-setup"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import {
	examSetupHeading,
	examSetupProgramTypeFromSlug,
	examSetupViewState,
	hasSelectionChanges,
	idDefaultsFrom,
	isFrmProgram,
	outcomeFrom,
	selectionDefaults,
	sittingLine,
	sittingSummary,
	toIdInput,
	toSelectionInput,
	validateIdStep,
	validateSelectionStep,
	type ExamSetupIdFormValues,
	type ExamSetupSelection,
	type ExamSetupViewState,
} from "@/lib/exam-setup-presentation"
import { programExamSetupMyGarpHref } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

type BarProps = {
	heading: MegaMenuHeading
	programType: string
	onNavigateBack: (run: () => void) => void
	/** The control group — the sitting readout and the submit. Absent on the outcome screen. */
	children?: ReactNode
}

/**
 * The one bar carrying the back link, the branded title and the submit — the
 * registration form's, so a member moving between the two never re-learns
 * where things are. The back link IS the way out; no screen below needs one.
 */
function ExamSetupBar({ heading, programType, onNavigateBack, children }: BarProps) {
	/*
	 * Same seal and wash the registration bar wears — this is the same bar for
	 * the same programme, so the two must not diverge. Undefined for a programme
	 * with no designed chrome, which keeps the plain bar.
	 */
	const chrome = registrationChromeForSlug(programType)?.chrome

	return (
		<div className={cn(REGISTRATION_STICKY_BAR, chrome?.barWash)}>
			<div className={REGISTRATION_BAR_TITLE_GROUP}>
				{/* The acronym the title uses, not the route slug: "RAI", not "RISKAI". */}
				<ProgramsSubpageHeader
					onNavigateBack={onNavigateBack}
					back={{ kind: "program", programType, label: heading.highlight }}
					iconOnlyBackOnMobile
				/>
				<div className="hidden h-6 w-px shrink-0 bg-border sm:block" aria-hidden />
				<ProgramBarIdentity chrome={chrome} heading={heading} />
			</div>
			{children ? <div className={REGISTRATION_BAR_CONTROL_GROUP}>{children}</div> : null}
		</div>
	)
}

const REFUSAL_ICONS = {
	unsupported: CircleSlash,
	pendingReschedule: ReceiptText,
	noAdmins: CalendarX2,
	unavailable: CircleAlert,
} as const

function RefusalPanel({
	state,
	programType,
}: {
	state: Exclude<ExamSetupViewState, "ready">
	programType: string
}) {
	const copy = EXAM_SETUP_REFUSALS[state]
	const myGarpHref = programExamSetupMyGarpHref(programType)

	return (
		<EmptyState
			icon={REFUSAL_ICONS[state]}
			tone={state === "unavailable" ? "error" : state === "pendingReschedule" ? "notice" : "muted"}
			title={copy.title}
			message={copy.message}
			action={
				state === "pendingReschedule" ? (
					<div className="flex flex-wrap items-center justify-center gap-3">
						{/* The list, not a detail page — we are told a reschedule order
						    exists but never which one. */}
						<CardCta
							label={EXAM_SETUP_REFUSALS.pendingReschedule.ctaLabel}
							url="/my-account?tab=order-history"
							isExternal={false}
							className="text-sm"
						/>
						<CardCta
							label="Continue in MyGarp"
							url={myGarpHref}
							isExternal
							className="text-sm"
						/>
					</div>
				) : null
			}
		/>
	)
}

type ExamSetupFormProps = {
	view: ExamSetupView
	programType: ExamSetupProgramType
	routeSlug: string
	heading: MegaMenuHeading
	onNavigateBack: (run: () => void) => void
}

/**
 * The form, mounted only once the payload exists.
 *
 * React Hook Form seeds from `defaultValues` at MOUNT; re-seeding a live form
 * from late-arriving data does update the text inputs but silently fails to
 * reach the Radix selects, which then render their placeholder forever and
 * post empty strings over stored data. Mounting after the data lands means
 * `defaultValues` is simply correct the first time.
 *
 * One page, one Save. Both rule sets run on that click — the sitting's, then
 * the ID's — and nothing is posted until both pass. Same rules and the same
 * words as before; the step gating between them was a wizard's, not the
 * contract's, since `examSetupId` takes both halves in one call.
 */
function ExamSetupForm({
	view,
	programType,
	routeSlug,
	heading,
	onNavigateBack,
}: ExamSetupFormProps) {
	const [selection, setSelection] = useState<ExamSetupSelection>(() =>
		selectionDefaults(view),
	)
	const [selectionError, setSelectionError] = useState<{
		part: 1 | 2
		message: string
	} | null>(null)
	const [problem, setProblem] = useState<string | null>(null)
	const [saveResult, setSaveResult] = useState<ExamSetupIdSaveResult | null>(null)
	const [fees, setFees] = useState<ExamSetupFeesView | null>(null)

	const { data: options } = useAccountOptions()
	const save = useSaveExamSetup(programType)
	const priceFees = useExamSetupFees()
	const authorize = useAuthorizeExamSetup(programType)

	const part1 = view.examPart1SelectionInfo ?? []
	const part2 = view.examPart2SelectionInfo ?? []
	const twoPart = part2.length > 0
	const isFrm = isFrmProgram(routeSlug)
	const isOSTA = view.idInfo?.isOSTA === true
	const myGarpHref = programExamSetupMyGarpHref(routeSlug)

	const parts = sittingSummary(view, selection)
	const line = sittingLine(parts)
	const changed = hasSelectionChanges(parts)

	// The rules run fresh on every submit. Expressed as per-field `rules` they
	// would be read once at mount, so a requirement switched off by a later
	// answer would carry on being enforced with nothing on screen to satisfy it.
	const resolver: Resolver<ExamSetupIdFormValues> = (values) => {
		const found = validateIdStep(values, { isFrm, isOSTA })
		const entries = Object.entries(found)
		if (entries.length === 0) return { values, errors: {} }
		return {
			values: {},
			errors: Object.fromEntries(
				entries.map(([name, message]) => [name, { type: "validate", message }]),
			),
		}
	}

	const {
		control,
		handleSubmit,
		formState: { errors },
	} = useForm<ExamSetupIdFormValues>({
		defaultValues: idDefaultsFrom(view.idInfo),
		resolver,
	})

	const pickList = (name: string) =>
		(options?.picklists?.[name] ?? []).map((option) => option.label)

	function onSubmit(event: FormEvent<HTMLFormElement>) {
		event.preventDefault()
		setProblem(null)

		const failure = validateSelectionStep(selection, {
			hasPart1: part1.length > 0,
			twoPart,
		})
		setSelectionError(
			failure
				? {
						part: failure === EXAM_SETUP_MESSAGES.selectAdminPart2 ? 2 : 1,
						message: failure,
					}
				: null,
		)

		void handleSubmit(async (values) => {
			// The sitting's rule ran first and its message is already on screen;
			// the ID's errors are shown alongside so one click reports everything.
			if (failure) return

			let result: ExamSetupIdSaveResult
			try {
				result = await save.mutateAsync({
					id: toIdInput(values, { isFrm, isOSTA }),
					selection: toSelectionInput(selection),
				})
			} catch (error) {
				// The mutation is silent, so nothing else will say this out loud.
				setProblem(
					error instanceof Error && error.message
						? error.message
						: EXAM_SETUP_MESSAGES.saveFailed,
				)
				return
			}

			// A refusal resolves rather than throws — the deferral rules arrive
			// this way, and they belong against the form that has to change.
			if (result.statusCode !== 200) {
				setProblem(result.statusMessage ?? EXAM_SETUP_MESSAGES.saveFailed)
				return
			}

			setSaveResult(result)

			const outcome = outcomeFrom(result)
			if (outcome === "pay-fees" && result.examModificationId) {
				// The breakdown is a nicety; the checkout link works without it.
				priceFees
					.mutateAsync(result.examModificationId)
					.then(setFees)
					.catch(() => setFees(null))
			} else if (outcome === "scheduling") {
				authorize.run()
			}
		})()
	}

	if (saveResult) {
		return (
			<>
				<ExamSetupBar
					heading={heading}
					programType={routeSlug}
					onNavigateBack={onNavigateBack}
				/>
				<ExamSetupOutcome
					result={saveResult}
					fees={fees}
					authorize={authorize}
					myGarpHref={myGarpHref}
					className="mt-6"
				/>
			</>
		)
	}

	return (
		<form onSubmit={onSubmit} noValidate>
			<ExamSetupBar
				heading={heading}
				programType={routeSlug}
				onNavigateBack={onNavigateBack}
			>
				{/* Always rendered and pinned to the button's height, so a longer
				    readout never moves the bar. */}
				<div
					className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, REGISTRATION_BAR_TOTAL_BLOCK)}
					aria-live="polite"
				>
					<p className="text-caption leading-none text-muted-foreground">
						{changed ? "New sitting" : "Sitting"}
					</p>
					<span
						className={cn(
							"max-w-64 truncate text-sm leading-tight font-semibold sm:max-w-xs",
							line ? (changed ? "text-primary" : "text-foreground") : "text-muted-foreground",
						)}
					>
						{line ?? "—"}
					</span>
				</div>
				{/* Never disabled for invalid input: the member is told what is wrong
				    when they ask to save, not left with a dead button. */}
				<Button
					type="submit"
					size="lg"
					className={REGISTRATION_BAR_SUBMIT}
					disabled={save.isPending}
				>
					{save.isPending ? "Saving…" : EXAM_SETUP_SUBMIT_LABEL}
				</Button>
			</ExamSetupBar>

			<div className="flex flex-col gap-6 pt-6">
				{problem ? (
					<Alert variant="destructive" role="alert">
						<CircleAlert aria-hidden />
						<AlertDescription>{problem}</AlertDescription>
					</Alert>
				) : null}

				<div className={REGISTRATION_GRID}>
					<div className={REGISTRATION_MAIN_COLUMN}>
						<SittingSection
							part1Admins={part1}
							part2Admins={part2}
							selection={selection}
							onSelectionChange={(next) => {
								setSelectionError(null)
								setSelection(next)
							}}
							error={selectionError}
							hasChanges={changed}
							onReset={() => {
								setSelectionError(null)
								setSelection(selectionDefaults(view))
							}}
						/>
						<IdentitySection
							control={control}
							errors={errors}
							isFrm={isFrm}
							isOSTA={isOSTA}
							mobilePhoneLocations={view.idInfo?.mobilePhoneLocations ?? []}
						/>
						{isFrm && isOSTA ? (
							<OstaSection
								control={control}
								errors={errors}
								workingStatuses={pickList(EXAM_SETUP_WORKING_STATUS_PICKLIST)}
								schoolStatuses={pickList(EXAM_SETUP_SCHOOL_STATUS_PICKLIST)}
							/>
						) : null}
					</div>

					<aside className={REGISTRATION_RAIL_COLUMN}>
						<ExamSetupRail programType={routeSlug} parts={parts} />
					</aside>
				</div>
			</div>
		</form>
	)
}

type ExamSetupPanelProps = {
	programType: string
	className?: string
}

/**
 * Exam setup for one programme — and, by the same route, exam deferral.
 *
 * There is no separate defer flow. Choosing a different administration IS the
 * deferral: Apex prices it as a "Standard exam administration change fee" and
 * stamps `Deferral_Subtype__c = 'Deferral Standard'` on the modification it
 * raises. Changing only the site, within the same administration, is free.
 *
 * Served in the registration form's shell — sticky bar, 60/40 grid, pinned
 * rail — so the two forms a candidate meets read as one product. This
 * component owns the query and the refusals; the form is a child so it can
 * mount with real defaults.
 */
function ExamSetupPanel({ programType, className }: ExamSetupPanelProps) {
	const { style, exit } = useSubpageTransition()
	const program = examSetupProgramTypeFromSlug(programType)
	const { data, isLoading, isError } = useExamSetup(program)
	const heading = examSetupHeading(programType)

	const state = examSetupViewState(data)

	const shell = (children: ReactNode) => (
		<animated.div style={style} className={cn(REGISTRATION_SHELL, className)}>
			<div>{children}</div>
		</animated.div>
	)

	const bare = (children: ReactNode) =>
		shell(
			<>
				<ExamSetupBar heading={heading} programType={programType} onNavigateBack={exit} />
				<div className="pt-6">{children}</div>
			</>,
		)

	if (!program) {
		return bare(<RefusalPanel state="unsupported" programType={programType} />)
	}

	if (isLoading) return bare(<ExamSetupContentSkeleton />)

	if (isError || state !== "ready" || !data) {
		return bare(
			<RefusalPanel
				state={state === "ready" ? "unavailable" : state}
				programType={programType}
			/>,
		)
	}

	return shell(
		<ExamSetupForm
			view={data}
			programType={program}
			routeSlug={programType}
			heading={heading}
			onNavigateBack={exit}
		/>,
	)
}

export { ExamSetupPanel }
