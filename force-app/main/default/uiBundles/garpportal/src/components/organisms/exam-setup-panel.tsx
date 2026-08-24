import { useState } from "react"
import { useForm, useWatch } from "react-hook-form"
import { animated } from "@react-spring/web"

import type {
	ExamSetupProgramType,
	ExamSetupSelectionInput,
	ExamSetupView,
} from "@/api/exam-setup"
import { Button } from "@/components/atoms/button"
import { CardCta } from "@/components/molecules/card-cta"
import { CvStepSection } from "@/components/molecules/cv-step-section"
import { ExamSetupFeeGate } from "@/components/molecules/exam-setup-fee-gate"
import {
	ExamSetupIdSection,
	type ExamSetupIdFormValues,
} from "@/components/molecules/exam-setup-id-section"
import { ExamSetupOutcome } from "@/components/molecules/exam-setup-outcome"
import { ExamSetupSelectionSection } from "@/components/molecules/exam-setup-selection-section"
import { ExamSetupContentSkeleton } from "@/components/molecules/page-pending"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import {
	EXAM_SETUP_REFUSALS,
	EXAM_SETUP_SECTIONS,
	EXAM_SETUP_TITLE,
} from "@/config/exam-setup"
import {
	useAuthorizeExamSetup,
	useExamSetup,
	useSaveExamSetup,
} from "@/hooks/use-exam-setup"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import {
	canChangeAdmin,
	examSetupPayFeesFallback,
	examSetupProgramTypeFromSlug,
	examSetupViewState,
	hasIdOnFile,
	hasSelectionChanges,
	idDefaultsFrom,
	isValidIdNumber,
	outcomeFrom,
	predictFee,
	selectionDefaults,
	toIdInput,
	type ExamSetupViewState,
} from "@/lib/exam-setup-presentation"
import { programExamSetupMyGarpHref } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

/** Shared with the other programme subpages so the chrome does not drift. */
const SUBPAGE_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
const SUBPAGE_SCROLL =
	"mt-4 min-h-0 flex-1 space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

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
		<div className="rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<p className="font-heading text-lg font-semibold tracking-wide text-foreground">
				{copy.title}
			</p>
			<p className="mx-auto mt-2 max-w-md text-sm text-muted-foreground">
				{copy.message}
			</p>
			{state === "pendingReschedule" ? (
				<div className="mt-5 flex flex-wrap items-center justify-center gap-3">
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
			) : null}
		</div>
	)
}

type ExamSetupFormProps = {
	view: ExamSetupView
	programType: ExamSetupProgramType
	routeSlug: string
	isSaving: boolean
	onSave: (args: {
		id: ExamSetupIdFormValues
		selection: ExamSetupSelectionInput
	}) => void
}

/**
 * The form itself, mounted only once the payload exists.
 *
 * That is the whole reason this is a separate component rather than part of
 * the panel. React Hook Form seeds from `defaultValues` at MOUNT; re-seeding a
 * live form from late-arriving data (`values`, or `reset()` in an effect) does
 * update the text inputs but silently fails to reach the Radix selects, which
 * then render their placeholder forever and post empty strings over stored
 * data. Mounting after the data lands means `defaultValues` is simply correct
 * the first time and there is nothing to re-seed.
 */
function ExamSetupForm({
	view,
	programType,
	routeSlug,
	isSaving,
	onSave,
}: ExamSetupFormProps) {
	const [override, setOverride] = useState<ExamSetupSelectionInput | null>(null)
	const [isIdOpen, setIdOpen] = useState(true)

	const {
		control,
		handleSubmit,
		formState: { errors },
	} = useForm<ExamSetupIdFormValues>({
		defaultValues: idDefaultsFrom(view.idInfo),
	})

	// `useWatch`, not the destructured `watch()` — the latter returns a fresh
	// function each render, which makes React Compiler skip memoising this
	// component. Every other form in the app subscribes this way too.
	const idType = useWatch({ control, name: "idType" })
	const idName = useWatch({ control, name: "idName" })
	const idNumber = useWatch({ control, name: "idNumber" })
	const workingStatus = useWatch({ control, name: "ostaCurrentWorkingStatus" })
	const schoolStatus = useWatch({ control, name: "ostaCurrentSchoolStatus" })

	const selection = override ?? selectionDefaults(view)
	const resetSelection = () => setOverride(null)

	const forecast = predictFee(programType, view, selection)
	const myGarpHref = programExamSetupMyGarpHref(routeSlug)
	const idOnFile = hasIdOnFile(view.idInfo)
	const isIDRequired = view.idInfo?.isIDRequired === true
	const changed = hasSelectionChanges(view, selection)

	const onSubmit = handleSubmit((values) => {
		// Belt and braces: the gate already replaces the submit button, so this
		// only fires if something reintroduces one.
		if (forecast) return
		onSave({ id: values, selection })
	})

	return (
		<form onSubmit={onSubmit} className="space-y-6" noValidate>
			<CvStepSection
				step={1}
				title={EXAM_SETUP_SECTIONS.selection.title}
				description={EXAM_SETUP_SECTIONS.selection.description}
				status={changed ? "complete" : "current"}
				open
			>
				<ExamSetupSelectionSection
					part1Admins={view.examPart1SelectionInfo ?? []}
					part2Admins={view.examPart2SelectionInfo ?? []}
					selection={selection}
					canChangeAdminPart1={canChangeAdmin(view, 1)}
					canChangeAdminPart2={canChangeAdmin(view, 2)}
					onSelectionChange={setOverride}
				/>
			</CvStepSection>

			<CvStepSection
				step={2}
				title={EXAM_SETUP_SECTIONS.identity.title}
				description={EXAM_SETUP_SECTIONS.identity.description}
				status={isIdOpen ? "current" : "complete"}
				open={isIdOpen}
				onOpenChange={setIdOpen}
				isLast
			>
				<ExamSetupIdSection
					control={control}
					errors={errors}
					idOnFile={idOnFile}
					isIDRequired={isIDRequired}
					isOSTA={view.idInfo?.isOSTA === true}
					mobilePhoneLocations={view.idInfo?.mobilePhoneLocations ?? []}
					idType={idType}
					workingStatus={workingStatus}
					schoolStatus={schoolStatus}
				/>
			</CvStepSection>

			{forecast ? (
				<ExamSetupFeeGate
					forecast={forecast}
					myGarpHref={myGarpHref}
					onReset={resetSelection}
				/>
			) : (
				<div className="flex flex-wrap items-center gap-3">
					<Button
						type="submit"
						disabled={
							isSaving ||
							!isValidIdNumber(idType, idNumber, idOnFile) ||
							(isIDRequired && !idName?.trim())
						}
					>
						{isSaving ? "Saving…" : "Save and continue"}
					</Button>
					{changed ? (
						<Button type="button" variant="ghost" onClick={resetSelection}>
							Reset
						</Button>
					) : null}
				</div>
			)}
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
 * One page rather than the legacy's three screens. `examSetup` returns the ID
 * step's fields alongside the sitting lists, and `examSetupId` accepts both
 * halves in one call — the split existed for an AngularJS wizard, not because
 * the contract needs it.
 *
 * This component owns the query and the branching; the form is a child so it
 * can mount with real defaults. See `ExamSetupForm` for why that matters.
 */
function ExamSetupPanel({ programType, className }: ExamSetupPanelProps) {
	const { style, exit } = useSubpageTransition()
	const program = examSetupProgramTypeFromSlug(programType)
	const { data, isLoading, isError } = useExamSetup(program)

	const save = useSaveExamSetup(program ?? "frm")
	const authorize = useAuthorizeExamSetup(program ?? "frm")

	const state = examSetupViewState(data)
	const myGarpHref = programExamSetupMyGarpHref(programType)
	const outcome = outcomeFrom(save.data)
	const payFeesFallback = examSetupPayFeesFallback(save.data)

	const shell = (children: React.ReactNode) => (
		<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
			<ProgramsSubpageHeader
				back={{
					kind: "program",
					programType,
					label: programType.toUpperCase(),
				}}
				title={EXAM_SETUP_TITLE}
				onNavigateBack={exit}
			/>
			<div className={SUBPAGE_SCROLL}>{children}</div>
		</animated.div>
	)

	if (!program) {
		return shell(<RefusalPanel state="unsupported" programType={programType} />)
	}

	if (isLoading) return shell(<ExamSetupContentSkeleton />)

	if (isError || state !== "ready" || !data) {
		return shell(
			<RefusalPanel
				state={state === "ready" ? "unavailable" : state}
				programType={programType}
			/>,
		)
	}

	// A save that came back wanting payment still wrote a modification — the
	// OSTA case `predictFee` cannot see. The gate says "pending" for that.
	if (payFeesFallback) {
		return shell(
			<ExamSetupFeeGate
				forecast={{ amount: 0, reason: "Your exam change carries a fee" }}
				myGarpHref={myGarpHref}
				onReset={() => save.reset()}
				isPending
			/>,
		)
	}

	if (save.isSuccess) {
		return shell(
			<ExamSetupOutcome
				kind={outcome === "scheduling" ? "scheduling" : "complete"}
				authorize={authorize}
				myGarpHref={myGarpHref}
				onStartOver={() => save.reset()}
			/>,
		)
	}

	return shell(
		<ExamSetupForm
			view={data}
			programType={program}
			routeSlug={programType}
			isSaving={save.isPending}
			onSave={({ id, selection }) =>
				save.mutate({ id: toIdInput(id), selection })
			}
		/>,
	)
}

export { ExamSetupPanel }
