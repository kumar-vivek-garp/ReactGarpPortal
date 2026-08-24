import { useEffect, type ReactNode } from "react"
import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { LayoutGrid, Library, List } from "lucide-react"

import type { StudyMaterial, StudyProgram } from "@/api/study-materials/types"
import { Button } from "@/components/atoms/button"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/atoms/toggle-group"
import { StudyMaterialsPending } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { StudyMaterialCard } from "@/components/molecules/study-material-card"
import { StudyMaterialRow } from "@/components/molecules/study-material-row"
import type { ListView } from "@/config/list-view"
import { programBrandSurface } from "@/config/program-brand"
import {
	DEFAULT_STUDY_MATERIALS_TAB,
	STUDY_MATERIALS_SECTIONS,
	resolveStudyMaterialsView,
	type StudyMaterialsSectionMeta,
} from "@/config/study-materials"
import { useStudyMaterials } from "@/hooks/use-study-materials"
import {
	buildCatalogueItemPresentation,
	buildOwnedItemPresentation,
	studyCodeLabel,
	type StudyItemPresentation,
} from "@/lib/study-materials-presentation"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { useListViewStore } from "@/store/list-view-store"

type StudyMaterialsPanelProps = {
	tab: string
	view: ListView | undefined
}

/** One bucket rendered in the active layout — card and row share a presentation. */
function StudyItemCollection({
	items,
	view,
}: {
	items: StudyItemPresentation[]
	view: ListView
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
					<StudyMaterialCard key={item.id} item={item} priority={index < 3} />
				) : (
					<StudyMaterialRow key={item.id} item={item} priority={index < 3} />
				),
			)}
		</StaggerReveal>
	)
}

function StudySection({
	meta,
	count,
	children,
}: {
	meta: StudyMaterialsSectionMeta
	count: number
	children: ReactNode
}) {
	const Icon = meta.icon
	return (
		<section className="space-y-4">
			<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
				<Icon className="size-5 shrink-0 text-primary" aria-hidden />
				{meta.heading}
				<span className="text-base font-normal text-muted-foreground">
					({count})
				</span>
			</h2>
			{children}
		</section>
	)
}

function StudyMaterialsBody({
	tab,
	view,
	programs,
	entitlements,
}: {
	tab: string
	view: ListView
	programs: StudyProgram[]
	entitlements: StudyMaterial[]
}) {
	const visiblePrograms =
		tab === DEFAULT_STUDY_MATERIALS_TAB
			? programs
			: programs.filter((entry) => entry.key === tab)

	// Owned materials follow the same program filter as the catalogue, so a
	// program tab shows only that program's items in both sections.
	const ownedItems = entitlements
		.filter(
			(material) =>
				tab === DEFAULT_STUDY_MATERIALS_TAB || material.programKey === tab,
		)
		.map(buildOwnedItemPresentation)

	const catalogueItems = visiblePrograms.flatMap((entry) =>
		entry.materials.map(buildCatalogueItemPresentation),
	)

	if (programs.length === 0 && entitlements.length === 0) {
		return (
			<p className="text-sm text-muted-foreground">
				{STUDY_MATERIALS_SECTIONS.all.emptyMessage}
			</p>
		)
	}

	return (
		<div className="space-y-8">
			{ownedItems.length > 0 ? (
				<StudySection
					meta={STUDY_MATERIALS_SECTIONS.entitlements}
					count={ownedItems.length}
				>
					<StudyItemCollection items={ownedItems} view={view} />
					{/*
					 * The archive lists eBook *keys* by edition year, which this
					 * catalogue view does not — a member with several years of
					 * purchases has no other way to reach the older ones.
					 */}
					<Button asChild variant="outline" size="sm" className="mt-4">
						<Link to="/study-materials/archive">
							<Library className="size-4" aria-hidden />
							My Access Links
						</Link>
					</Button>
				</StudySection>
			) : null}

			{catalogueItems.length === 0 ? (
				<p className="text-sm text-muted-foreground">
					{STUDY_MATERIALS_SECTIONS.catalogue.emptyMessage}
				</p>
			) : (
				<StudySection
					meta={STUDY_MATERIALS_SECTIONS.catalogue}
					count={catalogueItems.length}
				>
					<StudyItemCollection items={catalogueItems} view={view} />
				</StudySection>
			)}
		</div>
	)
}

function StudyMaterialsPanel({ tab, view }: StudyMaterialsPanelProps) {
	const navigate = useNavigate({ from: "/study-materials/" })
	const { data, isLoading, isError } = useStudyMaterials()
	const programs = data?.programs ?? []
	const entitlements = data?.myEntitlements ?? []
	const showProgramTabs = programs.length > 1

	const preferredView = useListViewStore(
		(state) => state.preferred["study-materials"],
	)
	const setPreferredView = useListViewStore((state) => state.setPreferred)
	const activeView = resolveStudyMaterialsView(view, preferredView)

	useEffect(() => {
		if (!data || tab === DEFAULT_STUDY_MATERIALS_TAB) return
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
						Study Materials for Risk Professionals
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
				) : null}
			</header>

			{/* Only this region scrolls; cards stagger in via StaggerReveal inside grids. */}
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your study materials. Please try again later.
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
								<StudyMaterialsBody
									tab={currentTab}
									view={activeView}
									programs={programs}
									entitlements={entitlements}
								/>
							</animated.div>
						))
					: null}
			</div>
		</Tabs>
	)
}

export { StudyMaterialsPanel }
