import { useState } from "react"
import { MapPin, Plus } from "lucide-react"

import type { WorkExperience } from "@/api/work-experience"
import { Button } from "@/components/atoms/button"
import { CvAddressDialog } from "@/components/molecules/cv-address-dialog"
import { CvDeleteDialog } from "@/components/molecules/cv-delete-dialog"
import { CvExperienceDialog } from "@/components/molecules/cv-experience-dialog"
import { CvExperienceList } from "@/components/molecules/cv-experience-list"
import { CvProgressBar } from "@/components/molecules/cv-progress-bar"
import { CvSubmitPanel } from "@/components/molecules/cv-submit-panel"
import {
	CvStepSection,
	type CvStepStatus,
} from "@/components/molecules/cv-step-section"
import { animated } from "@react-spring/web"

import { WorkExperienceContentSkeleton } from "@/components/molecules/page-pending"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { StatusBadge } from "@/components/molecules/status-badge"
import {
	CV_SECTIONS,
	CV_UNAVAILABLE_STATE,
	WORK_EXPERIENCE_TITLE,
} from "@/config/work-experience"
import { useCv } from "@/hooks/use-cv"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import {
	canEditCv,
	cvProgramTypeFromSlug,
	cvProgress,
	cvStatusPresentation,
	cvSubmitBlocker,
	cvViewState,
	formatAddressLine,
	formatMonths,
	hasDeliveryAddress,
} from "@/lib/work-experience-presentation"
import { cn } from "@/lib/utils"

/**
 * The shell every programme subpage shares — a fixed-height column whose body
 * scrolls, so the back link and title stay put while the content moves.
 */
const SUBPAGE_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
const SUBPAGE_SCROLL =
	"mt-4 min-h-0 flex-1 space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

const STATUS_TONE = {
	info: "info",
	success: "success",
	warning: "warning",
	neutral: "neutral",
} as const

function CvUnavailable() {
	const Icon = CV_UNAVAILABLE_STATE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{CV_UNAVAILABLE_STATE.title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{CV_UNAVAILABLE_STATE.message}
			</p>
		</div>
	)
}

type WorkExperiencePanelProps = {
	programType: string
	className?: string
}

/**
 * Work Experience for one certification.
 *
 * One route, one page. Sections stay on screen and collapse to a summary as
 * they are satisfied, so there is nothing to navigate between and nothing to
 * go back to — the legacy split this across three routes and shipped no Back
 * button.
 *
 * All three sections are live: entries, the delivery address, and submission.
 * Once the CV is with GARP the same route becomes a read-only receipt — the
 * legacy needed four routes for this and shipped no way back from any of them.
 */
function WorkExperiencePanel({
	programType,
	className,
}: WorkExperiencePanelProps) {
	const { style, exit } = useSubpageTransition()
	const [editing, setEditing] = useState<WorkExperience | null>(null)
	const [isReviewOpen, setReviewOpen] = useState(false)
	const [isFormOpen, setFormOpen] = useState(false)
	const [deleting, setDeleting] = useState<WorkExperience | null>(null)
	const [isAddressOpen, setAddressOpen] = useState(false)
	const [addressSectionOpen, setAddressSectionOpen] = useState<boolean | null>(null)
	const cvProgram = cvProgramTypeFromSlug(programType)
	const { data, isLoading, isError } = useCv(
		cvProgram ?? "FRM",
		cvProgram !== null,
	)

	const progress = cvProgress(data)
	const state = cvViewState(data)
	const status = cvStatusPresentation(data?.status ?? null)
	const experiences = data?.workExperiences ?? []
	const addressGiven = hasDeliveryAddress(data)
	// Once the CV is with GARP the rows become a record, not a workspace.
	const editable = canEditCv(data)

	const blocker = cvSubmitBlocker(data)
	// Default: open only when there is something to act on. An explicit toggle
	// by the member always wins over that.
	const isAddressSectionOpen = addressSectionOpen ?? !addressGiven

	const openForm = (experience: WorkExperience | null) => {
		setEditing(experience)
		setFormOpen(true)
	}

	const stepStatus = (satisfied: boolean, active: boolean): CvStepStatus =>
		satisfied ? "complete" : active ? "current" : "upcoming"

	const header = (
		<ProgramsSubpageHeader
			back={{ kind: "program", programType, label: programType.toUpperCase() }}
			title={WORK_EXPERIENCE_TITLE}
			onNavigateBack={exit}
		/>
	)

	// A programme with no CV requirement, or a member who owes none — Apex
	// answers the latter with a 401 that `fetchCv` turns into null.
	if (!cvProgram || (!isLoading && !isError && !data)) {
		return (
			<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
				{header}
				<div className={SUBPAGE_SCROLL}>
					<CvUnavailable />
				</div>
			</animated.div>
		)
	}

	return (
		<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
			{header}

			<div className={SUBPAGE_SCROLL}>
			{isLoading ? <WorkExperienceContentSkeleton /> : null}

			{!isLoading && isError ? (
				<p className="text-sm text-muted-foreground">
					We couldn&apos;t load your work experience. Please try again later.
				</p>
			) : null}

			{!isLoading && !isError && data ? (
				<>
					<div className="flex flex-wrap items-center gap-3">
						<StatusBadge label={status.label} tone={STATUS_TONE[status.tone]} />
						{data.submissionMessage ? (
							<p className="text-sm text-muted-foreground">
								{data.submissionMessage}
							</p>
						) : null}
					</div>

					<CvProgressBar progress={progress} />

					<div>
						<CvStepSection
							step={1}
							title={CV_SECTIONS[0].title}
							description={CV_SECTIONS[0].description}
							status={stepStatus(progress.remaining === 0, true)}
							summary={
								experiences.length > 0
									? `${experiences.length} added · ${formatMonths(progress.logged)}`
									: null
							}
							open
						>
							<CvExperienceList
								experiences={experiences}
								onEdit={editable ? openForm : undefined}
								onDelete={editable ? setDeleting : undefined}
							/>
							{editable ? (
								<Button
									type="button"
									variant="outline"
									size="sm"
									className="mt-3"
									onClick={() => openForm(null)}
								>
									<Plus className="size-4" aria-hidden />
									Add experience
								</Button>
							) : null}
						</CvStepSection>

						<CvStepSection
							step={2}
							title={CV_SECTIONS[1].title}
							description={CV_SECTIONS[1].description}
							status={stepStatus(addressGiven, progress.remaining === 0)}
							summary={addressGiven ? "Added" : "Not started"}
							open={isAddressSectionOpen}
							onOpenChange={setAddressSectionOpen}
						>
							<p className="text-sm text-foreground">
								{formatAddressLine(data.address) ??
									"No delivery address on file yet."}
							</p>
							{editable ? (
								<Button
									type="button"
									variant="outline"
									size="sm"
									className="mt-3"
									onClick={() => setAddressOpen(true)}
								>
									<MapPin className="size-4" aria-hidden />
									{addressGiven ? "Change address" : "Add address"}
								</Button>
							) : null}
						</CvStepSection>

						<CvStepSection
							step={3}
							title={CV_SECTIONS[2].title}
							description={CV_SECTIONS[2].description}
							status={stepStatus(
								state === "submitted" || state === "closed",
								blocker === null,
							)}
							summary={
								state === "submitted"
									? "Sent to GARP"
									: progress.remaining > 0
										? `${progress.remaining} months to go`
										: null
							}
							open={isReviewOpen || blocker === null || !editable}
							onOpenChange={setReviewOpen}
							isLast
						>
							<CvSubmitPanel view={data} programType={cvProgram} />
						</CvStepSection>
					</div>
				</>
			) : null}
			</div>

			{cvProgram ? (
				<CvExperienceDialog
					open={isFormOpen}
					onOpenChange={setFormOpen}
					programType={cvProgram}
					experience={editing}
				/>
			) : null}
			<CvAddressDialog
				open={isAddressOpen}
				onOpenChange={setAddressOpen}
				view={data ?? null}
			/>
			<CvDeleteDialog
				open={deleting !== null}
				onOpenChange={(next) => {
					if (!next) setDeleting(null)
				}}
				experience={deleting}
			/>
		</animated.div>
	)
}

export { WorkExperiencePanel }
