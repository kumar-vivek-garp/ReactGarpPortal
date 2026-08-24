import { animated } from "@react-spring/web"

import type { ProgramDetail } from "@/api/programs"
import { ProgramDetailHero } from "@/components/molecules/program-detail-hero"
import { ProgramDetailRail } from "@/components/molecules/program-detail-rail"
import { ProgramExamOverview } from "@/components/molecules/program-exam-overview"
import { ProgramJourney } from "@/components/molecules/program-journey"
import { ProgramDetailSkeleton } from "@/components/molecules/page-pending"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { localizeProgramLogoUrl } from "@/config/program-logos"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { useProgramDetail } from "@/hooks/use-program-detail"
import { buildProgramDetailPresentation } from "@/lib/program-detail-presentation"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

/** Forward-nav feel when opening `/programs/$programType` from the listing. */
type ProgramDetailPanelProps = {
	programType: string
}

function logoForDetail(detail: ProgramDetail): string | undefined {
	return localizeProgramLogoUrl(
		resolvePortalAssetUrl(
			detail.programInformation?.myProgramsLogoURL,
		) ?? detail.programInformation?.myProgramsLogoURL,
	)
}

function DetailBody({ detail }: { detail: ProgramDetail }) {
	const presentation = buildProgramDetailPresentation(detail)
	const logoUrl = logoForDetail(detail)
	const showPart1 =
		detail.examPart1Info != null && detail.examPart1Info.isResultStale !== true
	const showPart2 =
		detail.examPart2Info != null && detail.examPart2Info.isResultStale !== true

	return (
		<div className="space-y-6 pb-2">
			<ProgramDetailHero presentation={presentation} logoUrl={logoUrl} />

			{/* Mobile: urgent deadlines / notifications right after next step */}
			<div className="app:hidden">
				<ProgramDetailRail detail={detail} variant="urgent" />
			</div>

			<div
				className={cn(
					"grid items-start gap-8",
					"app:grid-cols-[minmax(0,1fr)_minmax(16rem,20rem)]",
				)}
			>
				<div className="flex min-w-0 flex-col gap-5">
					<ProgramJourney milestones={presentation.milestones} />
					{showPart1 && detail.examPart1Info ? (
						<ProgramExamOverview
							detail={detail}
							part={detail.examPart1Info}
							partIndex={1}
						/>
					) : null}
					{showPart2 && detail.examPart2Info ? (
						<ProgramExamOverview
							detail={detail}
							part={detail.examPart2Info}
							partIndex={2}
						/>
					) : null}
					{!showPart1 &&
					!showPart2 &&
					detail.programState === "ExamAttempt" ? (
						<p className="text-sm text-muted-foreground">
							No exam attempt details are available for this program yet.
						</p>
					) : null}
				</div>

				{/* Desktop sticky utility rail */}
				<div className="hidden app:block">
					<div className="sticky top-4">
						<ProgramDetailRail detail={detail} />
					</div>
				</div>
			</div>

			{/* Mobile: collapsible secondary rail */}
			<div className="app:hidden">
				<ProgramDetailRail detail={detail} variant="secondary" />
			</div>
		</div>
	)
}

function ProgramDetailPanelView({ programType }: ProgramDetailPanelProps) {
	const { data, isLoading, isError, error } = useProgramDetail(programType)
	const detail = data?.programsDetailInfo ?? null

	const { style, exit } = useSubpageTransition()

	return (
		<animated.div
			style={style}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<ProgramsSubpageHeader
				title={
					isLoading || detail
						? undefined
						: programType.trim().toUpperCase() || "Program"
				}
				onNavigateBack={exit}
			/>

			<div className="mt-4 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <ProgramDetailSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						{error instanceof Error && error.message
							? error.message
							: "We couldn't load this program. Please try again later."}
					</p>
				) : null}

				{!isLoading && !isError && !detail ? (
					<p className="text-sm text-muted-foreground">
						No details were returned for this program.
					</p>
				) : null}

				{!isLoading && !isError && detail ? (
					<DetailBody detail={detail} />
				) : null}
			</div>
		</animated.div>
	)
}

/** Remount on type change so the enter spring re-runs between programs. */
function ProgramDetailPanel({ programType }: ProgramDetailPanelProps) {
	return (
		<ProgramDetailPanelView
			key={programType.trim().toLowerCase()}
			programType={programType}
		/>
	)
}

export { ProgramDetailPanel }
