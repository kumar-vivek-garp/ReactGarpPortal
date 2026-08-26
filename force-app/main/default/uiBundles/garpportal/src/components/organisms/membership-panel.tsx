import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"
import { BadgeCheck, LayoutGrid, List } from "lucide-react"

import type { Benefit, MembershipView } from "@/api/membership/types"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/atoms/toggle-group"
import { BenefitCard } from "@/components/molecules/benefit-card"
import { BenefitRow } from "@/components/molecules/benefit-row"
import { MemberDirectoryPanel } from "@/components/organisms/member-directory-panel"
import { MembershipHero } from "@/components/organisms/membership-hero"
import {
	MembershipBenefitsSkeleton,
	MembershipDirectorySkeleton,
	MembershipPendingShell,
} from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import type { ListView } from "@/config/list-view"
import {
	MEMBERSHIP_BENEFITS_EMPTY,
	MEMBERSHIP_TAB_ITEMS,
	resolveMembershipView,
	type MembershipTab,
} from "@/config/membership"
import { useMembership } from "@/hooks/use-membership"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"
import { useListViewStore } from "@/store/list-view-store"

type MembershipPanelProps = {
	tab: MembershipTab
	view: ListView | undefined
}

function BenefitsEmptyState() {
	const { icon: Icon, title, message } = MEMBERSHIP_BENEFITS_EMPTY

	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">{message}</p>
		</div>
	)
}

/** One section rendered in the active layout — card and row share a presentation. */
function BenefitCollection({
	benefits,
	view,
}: {
	benefits: Benefit[]
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
			{benefits.map((benefit, index) =>
				view === "grid" ? (
					<BenefitCard key={benefit.id} benefit={benefit} />
				) : (
					<BenefitRow key={benefit.id} benefit={benefit} priority={index < 3} />
				),
			)}
		</StaggerReveal>
	)
}

function BenefitsTabBody({
	data,
	view,
	isLoading,
	isError,
}: {
	data: MembershipView | undefined
	view: ListView
	isLoading: boolean
	isError: boolean
}) {
	if (isLoading) {
		return <MembershipBenefitsSkeleton view={view} />
	}

	if (isError || !data) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your membership benefits. Please try again later.
			</p>
		)
	}

	const { sections } = data

	return (
		<div className="space-y-8">
			<MembershipHero data={data} />

			{sections.length === 0 ? (
				<BenefitsEmptyState />
			) : (
				sections.map((section) => (
					<section key={section.name} className="space-y-4">
						{/*
						 * Section names come from Apex and are dynamic, so one shared
						 * icon rather than a per-name map — it carries the same visual
						 * rhythm as the Programs / Study Materials / Events headings
						 * without pretending to classify a name we have not seen.
						 */}
						<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
							<BadgeCheck className="size-5 shrink-0 text-primary" aria-hidden />
							{section.name}
							<span className="text-base font-normal text-muted-foreground">
								({section.benefits.length})
							</span>
						</h2>
						<BenefitCollection benefits={section.benefits} view={view} />
					</section>
				))
			)}
		</div>
	)
}

function DirectoryTabBody({
	data,
	isLoading,
}: {
	data: MembershipView | undefined
	isLoading: boolean
}) {
	if (isLoading) {
		return <MembershipDirectorySkeleton />
	}

	const identity = data?.identity
	const showAccessNote = Boolean(identity && !identity.isIndividualMember)

	/*
	 * The real directory, not a box that bounces to it. This tab used to hold a
	 * search field whose only job was to navigate away — a dead end that also
	 * left two implementations of one search in the app. The standalone
	 * `/member-directory` route still exists for the dashboard card and for
	 * links from outside; both mount this same panel.
	 */
	return (
		<div className="flex min-h-0 flex-1 flex-col gap-3 overflow-y-auto">
			<p className="shrink-0 text-sm text-muted-foreground">
				Find and connect with opted-in members of the global risk community.
			</p>

			{showAccessNote ? (
				<p className="shrink-0 rounded-md border border-border bg-muted/40 px-3 py-2 text-xs text-muted-foreground">
					Full directory access is an Individual Membership benefit. You can still
					search; results are limited to members who opted in.
				</p>
			) : null}

			<MemberDirectoryPanel showHeading={false} />
		</div>
	)
}

function MembershipPanel({ tab, view }: MembershipPanelProps) {
	const navigate = useNavigate({ from: "/membership/" })
	const { data, isLoading, isError } = useMembership()

	const preferredView = useListViewStore((state) => state.preferred.membership)
	const setPreferredView = useListViewStore((state) => state.setPreferred)
	const activeView = resolveMembershipView(view, preferredView)

	const benefitsCount = data
		? data.sections.reduce((sum, section) => sum + section.benefits.length, 0)
		: undefined

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	const selectView = (next: ListView) => {
		// Remembered so the choice survives leaving the page and coming back.
		setPreferredView("membership", next)
		void navigate({
			search: (prev) => ({ ...prev, view: next }),
			replace: true,
		})
	}

	if (isLoading) {
		return <MembershipPendingShell tab={tab} view={view} />
	}

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: (prev) => ({ ...prev, tab: value as MembershipTab }),
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						Membership Benefits
					</h1>

					{/* The directory has no grid/list layouts, so no dead control there. */}
					{tab === "benefits" ? (
						<ToggleGroup
							variant="outline"
							type="single"
							value={activeView}
							onValueChange={(value) => {
								// Radix allows deselecting the active item; ignore that.
								if (!value) return
								selectView(value as ListView)
							}}
							aria-label="Benefits layout"
						>
							<ToggleGroupItem value="grid" aria-label="Grid view">
								<LayoutGrid aria-hidden />
							</ToggleGroupItem>
							<ToggleGroupItem value="list" aria-label="List view">
								<List aria-hidden />
							</ToggleGroupItem>
						</ToggleGroup>
					) : null}
				</div>

				<PillTabs
					items={MEMBERSHIP_TAB_ITEMS.map((item) =>
						item.value === "benefits" && benefitsCount !== undefined
							? { ...item, count: benefitsCount }
							: item,
					)}
					value={tab}
				/>
			</header>

			<div className="mt-6 flex min-h-0 flex-1 flex-col overflow-hidden">
				{tabTransitions((style, currentTab) => (
					<animated.div
						key={currentTab}
						role="tabpanel"
						style={style}
						className={cn(
							"flex min-h-0 flex-1 flex-col",
							currentTab === "benefits" &&
								"overflow-y-auto overscroll-contain pb-2 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
							currentTab === "directory" && "overflow-hidden pb-2",
						)}
					>
						{currentTab === "benefits" ? (
							<BenefitsTabBody
								data={data}
								view={activeView}
								isLoading={false}
								isError={isError}
							/>
						) : null}
						{currentTab === "directory" ? (
							<DirectoryTabBody data={data} isLoading={false} />
						) : null}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export { MembershipPanel }
