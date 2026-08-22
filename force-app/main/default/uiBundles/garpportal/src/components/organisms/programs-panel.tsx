import { useMemo } from "react"
import type { ReactNode } from "react"
import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"
import { LayoutGrid, List } from "lucide-react"

import type {
	CompletedProgram,
	EnrolledProgram,
	OtherProgram,
} from "@/api/programs"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/atoms/toggle-group"
import { ProgramCard } from "@/components/molecules/program-card"
import { ProgramRow } from "@/components/molecules/program-row"
import { ProgramsPendingShell } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	PROGRAM_BUCKET_META,
	PROGRAM_TAB_ITEMS,
	resolveProgramsTab,
	resolveProgramsView,
	type ProgramsTab,
	type ProgramsView,
} from "@/config/programs"
import {
	examResultProgramSlugs,
	examResultsRouteSlug,
} from "@/lib/exam-results-presentation"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import type { ProgramCardVariant } from "@/lib/program-listing-presentation"
import { useExamResults } from "@/hooks/use-exam-results"
import { usePrograms } from "@/hooks/use-programs"
import { useListViewStore } from "@/store/list-view-store"

type ProgramsPanelProps = {
	tab: ProgramsTab | undefined
	view: ProgramsView | undefined
}

type BucketProgram = EnrolledProgram | CompletedProgram | OtherProgram

function ProgramsEmptyState({ tab }: { tab: ProgramsTab }) {
	const { icon: Icon, emptyTitle, emptyMessage } = PROGRAM_BUCKET_META[tab]

	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{emptyTitle}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{emptyMessage}
			</p>
		</div>
	)
}

/**
 * One bucket rendered in the active view. Grid and list share the same
 * presentation layer, so only the wrapper geometry differs.
 */
function ProgramCollection({
	programs,
	variant,
	view,
	resultSlugs,
}: {
	programs: BucketProgram[]
	variant: ProgramCardVariant
	view: ProgramsView
	/** Route slugs the member has exam results for. */
	resultSlugs: ReadonlySet<string>
}) {
	return (
		<StaggerReveal
			// Remount on view change so the cascade replays when switching
			// grid <-> list; `useTrail` will not re-run on its own because the
			// `to` values are unchanged.
			key={view}
			className={
				view === "grid"
					? "grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
					: "flex flex-col gap-3"
			}
			itemClassName={view === "grid" ? "h-full" : undefined}
		>
			{programs.map((program, index) =>
				view === "grid" ? (
					<ProgramCard
						key={program.programType}
						variant={variant}
						program={program}
						priority={index < 3}
						hasResults={resultSlugs.has(
							examResultsRouteSlug(program.programType),
						)}
					/>
				) : (
					<ProgramRow
						key={program.programType}
						variant={variant}
						program={program}
						priority={index < 3}
						hasResults={resultSlugs.has(
							examResultsRouteSlug(program.programType),
						)}
					/>
				),
			)}
		</StaggerReveal>
	)
}

function ProgramsSection({
	tab,
	count,
	children,
}: {
	tab: Exclude<ProgramsTab, "all">
	count: number
	children: ReactNode
}) {
	const { icon: Icon, label } = PROGRAM_BUCKET_META[tab]
	const heading = tab === "explore" ? "Explore Other Programs" : label

	return (
		<section className="space-y-4">
			<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
				<Icon className="size-5 shrink-0 text-primary" aria-hidden />
				{heading}
				<span className="text-base font-normal text-muted-foreground">
					({count})
				</span>
			</h2>
			{children}
		</section>
	)
}

function ProgramsTabBody({
	tab,
	view,
	enrolled,
	completed,
	other,
	resultSlugs,
}: {
	tab: ProgramsTab
	view: ProgramsView
	enrolled: EnrolledProgram[]
	completed: CompletedProgram[]
	other: OtherProgram[]
	resultSlugs: ReadonlySet<string>
}) {
	if (tab !== "all") {
		const programs: BucketProgram[] =
			tab === "in-progress" ? enrolled : tab === "completed" ? completed : other
		const variant: ProgramCardVariant =
			tab === "in-progress"
				? "inProgress"
				: tab === "completed"
					? "completed"
					: "other"

		if (programs.length === 0) return <ProgramsEmptyState tab={tab} />

		return (
			<ProgramCollection
				programs={programs}
				variant={variant}
				view={view}
				resultSlugs={resultSlugs}
			/>
		)
	}

	if (enrolled.length === 0 && completed.length === 0 && other.length === 0) {
		return <ProgramsEmptyState tab="all" />
	}

	return (
		<div className="space-y-8">
			{enrolled.length > 0 ? (
				<ProgramsSection tab="in-progress" count={enrolled.length}>
					<ProgramCollection
						programs={enrolled}
						variant="inProgress"
						view={view}
						resultSlugs={resultSlugs}
					/>
				</ProgramsSection>
			) : null}

			{completed.length > 0 ? (
				<ProgramsSection tab="completed" count={completed.length}>
					<ProgramCollection
						programs={completed}
						variant="completed"
						view={view}
						resultSlugs={resultSlugs}
					/>
				</ProgramsSection>
			) : null}

			{other.length > 0 ? (
				<ProgramsSection tab="explore" count={other.length}>
					<ProgramCollection
						programs={other}
						variant="other"
						view={view}
						resultSlugs={resultSlugs}
					/>
				</ProgramsSection>
			) : null}
		</div>
	)
}

function tabCount(
	tab: ProgramsTab,
	enrolled: number,
	completed: number,
	other: number,
): number {
	if (tab === "in-progress") return enrolled
	if (tab === "completed") return completed
	if (tab === "explore") return other
	return enrolled + completed + other
}

function ProgramsPanel({ tab, view }: ProgramsPanelProps) {
	const navigate = useNavigate({ from: "/programs/" })
	const { data, isLoading, isError } = usePrograms()
	const enrolled = data?.enrolledPrograms ?? []
	const completed = data?.completedPrograms ?? []
	const other = data?.otherPrograms ?? []

	const preferredView = useListViewStore((state) => state.preferred.programs)
	const setPreferredView = useListViewStore((state) => state.setPreferred)

	/*
	 * Only fetched when the programs payload says there is something to find,
	 * so a member with no attempts costs no request. The result decides which
	 * cards earn a "Results" chip.
	 */
	const examResults = useExamResults(data?.hasExamResults === true)
	const resultSlugs = useMemo(
		() => examResultProgramSlugs(examResults.data),
		[examResults.data],
	)

	const activeTab = resolveProgramsTab(tab, enrolled.length)
	const activeView = resolveProgramsView(view, activeTab, preferredView)

	const selectTab = (next: ProgramsTab) => {
		void navigate({
			search: (prev) => ({ ...prev, tab: next }),
			replace: true,
		})
	}

	const tabTransitions = useTransition(activeTab, TAB_PANEL_TRANSITION)

	const selectView = (next: ProgramsView) => {
		// Remember it so the choice survives a trip to a program detail page,
		// where there is no `view` param to carry it.
		setPreferredView("programs", next)
		void navigate({
			search: (prev) => ({ ...prev, view: next }),
			replace: true,
		})
	}

	if (isLoading) {
		return <ProgramsPendingShell tab={tab} view={view} />
	}

	return (
		<Tabs
			value={activeTab}
			onValueChange={(value) => selectTab(value as ProgramsTab)}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						My Programs
					</h1>

					<ToggleGroup
						variant="outline"
						type="single"
						value={activeView}
						onValueChange={(value) => {
							// Radix allows deselecting the active item; ignore that.
							if (!value) return
							selectView(value as ProgramsView)
						}}
						aria-label="Programs layout"
					>
						<ToggleGroupItem value="grid" aria-label="Grid view">
							<LayoutGrid aria-hidden />
						</ToggleGroupItem>
						<ToggleGroupItem value="list" aria-label="List view">
							<List aria-hidden />
						</ToggleGroupItem>
					</ToggleGroup>
				</div>

				<PillTabs
					items={PROGRAM_TAB_ITEMS.map((item) => ({
						...item,
						count: tabCount(
							item.value,
							enrolled.length,
							completed.length,
							other.length,
						),
					}))}
					value={activeTab}
				/>
			</header>

			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your programs. Please try again later.
					</p>
				) : null}

				{!isError
					? tabTransitions((style, currentTab) => (
							<animated.div
								key={currentTab}
								role="tabpanel"
								style={style}
								className="pb-2"
							>
								<ProgramsTabBody
									tab={currentTab}
									view={activeView}
									enrolled={enrolled}
									completed={completed}
									other={other}
									resultSlugs={resultSlugs}
								/>
							</animated.div>
						))
					: null}
			</div>
		</Tabs>
	)
}

export { ProgramsPanel }
