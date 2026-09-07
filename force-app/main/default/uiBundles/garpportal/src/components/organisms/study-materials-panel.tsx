import { useEffect } from "react"
import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { LayoutGrid, Library, List } from "lucide-react"

import type {
	StudyMaterialItem,
	StudyMaterialsView,
	StudyProgram,
} from "@/api/study-materials/types"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/atoms/toggle-group"
import { CardCta } from "@/components/molecules/card-cta"
import { EmptyState } from "@/components/molecules/empty-state"
import { StudyMaterialsPending } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { StudyMaterialCard } from "@/components/molecules/study-material-card"
import { StudyMaterialRow } from "@/components/molecules/study-material-row"
import type { ListView } from "@/config/list-view"
import { programBrandSurface } from "@/config/program-brand"
import {
	DEFAULT_STUDY_MATERIALS_TAB,
	STUDY_MATERIALS_ARCHIVE_LABEL,
	STUDY_MATERIALS_DENIED,
	STUDY_MATERIALS_EMPTY,
	STUDY_MATERIALS_ERRATA_LABEL,
	STUDY_MATERIALS_TITLE,
	resolveStudyMaterialsView,
} from "@/config/study-materials"
import { useHasEBookArchive } from "@/hooks/use-ebook-archive"
import { useStudyMaterials } from "@/hooks/use-study-materials"
import { programErrataPath } from "@/lib/program-card-links"
import { groupByPart, studyCodeLabel } from "@/lib/study-materials-presentation"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"
import { useListViewStore } from "@/store/list-view-store"

type StudyMaterialsPanelProps = {
	tab: string
	view: ListView | undefined
}

const NO_PROGRAMS: StudyProgram[] = []

type DeniedView = Extract<StudyMaterialsView, { kind: "denied" }>

function deniedView(view: StudyMaterialsView | undefined): DeniedView | null {
	return view?.kind === "denied" ? view : null
}

/** One group of materials in the active layout — card and row share every rule. */
function StudyItemCollection({
	items,
	view,
	priority,
}: {
	items: StudyMaterialItem[]
	view: ListView
	/** Only the first group on screen gets eager artwork. */
	priority: boolean
}) {
	return (
		<StaggerReveal
			// Remount on view change so the cascade replays; `useTrail` will not
			// re-run on its own because the `to` values are unchanged.
			key={view}
			className={
				view === "grid"
					? "grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
					: "flex flex-col gap-3"
			}
			itemClassName={view === "grid" ? "h-full" : undefined}
		>
			{items.map((item, index) =>
				view === "grid" ? (
					<StudyMaterialCard
						key={item.id}
						item={item}
						priority={priority && index < 3}
					/>
				) : (
					<StudyMaterialRow
						key={item.id}
						item={item}
						priority={priority && index < 3}
					/>
				),
			)}
		</StaggerReveal>
	)
}

/**
 * One programme: heading, its errata link, and its materials — FRM split by
 * exam part, every other programme as one list.
 */
function ProgramSection({
	program,
	view,
	priority,
}: {
	program: StudyProgram
	view: ListView
	priority: boolean
}) {
	const errataPath = programErrataPath(program.key)
	const groups = groupByPart(program.items)

	return (
		<section className="space-y-4" aria-labelledby={`study-${program.key}`}>
			<div className="flex flex-wrap items-center justify-between gap-x-6 gap-y-2">
				<h2
					id={`study-${program.key}`}
					className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground"
				>
					<Badge
						className={cn(
							"rounded-md font-bold tracking-wider",
							programBrandSurface(program.key).chip,
						)}
					>
						{studyCodeLabel(program.key)}
					</Badge>
					{program.label}
					<span className="text-base font-normal text-muted-foreground">
						({program.items.length})
					</span>
				</h2>
				{errataPath ? (
					<CardCta
						label={STUDY_MATERIALS_ERRATA_LABEL}
						url={errataPath}
						isExternal={false}
					/>
				) : null}
			</div>

			{groups.map((group, index) => (
				<div key={group.part ?? "all"} className="space-y-3">
					{group.part ? (
						<h3 className="font-heading text-lg font-semibold tracking-wide text-foreground">
							{group.part}
						</h3>
					) : null}
					<StudyItemCollection
						items={group.items}
						view={view}
						priority={priority && index === 0}
					/>
				</div>
			))}
		</section>
	)
}

function StudyMaterialsBody({
	tab,
	view,
	programs,
}: {
	tab: string
	view: ListView
	programs: StudyProgram[]
}) {
	if (programs.length === 0) {
		return (
			<EmptyState
				icon={STUDY_MATERIALS_EMPTY.icon}
				title={STUDY_MATERIALS_EMPTY.title}
				message={STUDY_MATERIALS_EMPTY.message}
			/>
		)
	}

	const visiblePrograms =
		tab === DEFAULT_STUDY_MATERIALS_TAB
			? programs
			: programs.filter((entry) => entry.key === tab)

	return (
		<div className="space-y-10">
			{visiblePrograms.map((program, index) => (
				<ProgramSection
					key={program.key}
					program={program}
					view={view}
					priority={index === 0}
				/>
			))}
		</div>
	)
}

function StudyMaterialsPanel({ tab, view }: StudyMaterialsPanelProps) {
	const navigate = useNavigate({ from: "/study-materials/" })
	const { data, isLoading, isError } = useStudyMaterials()
	const hasArchive = useHasEBookArchive()
	const programs = data?.kind === "ok" ? data.programs : NO_PROGRAMS
	const denied = deniedView(data)
	const showProgramTabs = programs.length > 1

	const preferredView = useListViewStore(
		(state) => state.preferred["study-materials"],
	)
	const setPreferredView = useListViewStore((state) => state.setPreferred)
	const activeView = resolveStudyMaterialsView(view, preferredView)

	useEffect(() => {
		if (!data || data.kind !== "ok" || tab === DEFAULT_STUDY_MATERIALS_TAB) return
		if (data.programs.some((entry) => entry.key === tab)) return
		void navigate({
			search: (prev) => ({ ...prev, tab: DEFAULT_STUDY_MATERIALS_TAB }),
			replace: true,
		})
	}, [data, tab, navigate])

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	const selectView = (next: ListView) => {
		// Remembered so the choice survives leaving the page and coming back.
		setPreferredView("study-materials", next)
		void navigate({
			search: (prev) => ({ ...prev, view: next }),
			replace: true,
		})
	}

	if (isLoading) {
		return <StudyMaterialsPending />
	}

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: (prev) => ({ ...prev, tab: value }),
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			{/* Fixed chrome: heading + program tabs — does not scroll. */}
			<header className="shrink-0 space-y-4">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						{STUDY_MATERIALS_TITLE}
					</h1>

					<ToggleGroup
						variant="outline"
						type="single"
						value={activeView}
						onValueChange={(value) => {
							// Radix allows deselecting the active item; ignore that.
							if (!value) return
							selectView(value as ListView)
						}}
						aria-label="Study materials layout"
					>
						<ToggleGroupItem value="grid" aria-label="Grid view">
							<LayoutGrid aria-hidden />
						</ToggleGroupItem>
						<ToggleGroupItem value="list" aria-label="List view">
							<List aria-hidden />
						</ToggleGroupItem>
					</ToggleGroup>
				</div>

				{showProgramTabs || hasArchive ? (
					<div className="flex flex-wrap items-center justify-between gap-3">
						{showProgramTabs ? (
							<PillTabs
								items={[
									{ value: DEFAULT_STUDY_MATERIALS_TAB, label: "All" },
									...programs.map((entry) => ({
										value: entry.key,
										label: entry.label,
										badge: studyCodeLabel(entry.key),
										badgeClassName: programBrandSurface(entry.key).chip,
									})),
								]}
								value={tab}
							/>
						) : (
							<span />
						)}
						{/*
						 * The archive lists eBook KEYS by edition year, which this
						 * catalogue does not — a member with several years of purchases
						 * has no other way to reach the older ones. Offered only to
						 * members who hold a key, as the legacy gates it.
						 */}
						{hasArchive ? (
							<Button asChild variant="outline" size="sm">
								<Link to="/study-materials/archive">
									<Library className="size-4" aria-hidden />
									{STUDY_MATERIALS_ARCHIVE_LABEL}
								</Link>
							</Button>
						) : null}
					</div>
				) : null}
			</header>

			{/* Only this region scrolls; cards stagger in via StaggerReveal inside grids. */}
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your study materials. Please try again later.
					</p>
				) : null}

				{denied ? (
					<EmptyState
						icon={STUDY_MATERIALS_DENIED.icon}
						tone="notice"
						title={STUDY_MATERIALS_DENIED.title}
						message={denied.message ?? STUDY_MATERIALS_DENIED.fallbackMessage}
					/>
				) : null}

				{!isError && !denied
					? tabTransitions((style, currentTab) => (
							<animated.div
								key={currentTab}
								role="tabpanel"
								style={style}
								className="pb-2"
							>
								<StudyMaterialsBody
									tab={currentTab}
									view={activeView}
									programs={programs}
								/>
							</animated.div>
						))
					: null}
			</div>
		</Tabs>
	)
}

export { StudyMaterialsPanel }
