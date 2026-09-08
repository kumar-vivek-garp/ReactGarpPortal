import { useState } from "react"
import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { BookOpen, Compass, Plus, TriangleAlert } from "lucide-react"

import type { CpdClaim } from "@/api/cpd"
import { Button } from "@/components/atoms/button"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { CpdActivityList } from "@/components/molecules/cpd-activity-list"
import { CpdClaimDialog } from "@/components/molecules/cpd-claim-dialog"
import { CpdCreditSummaryCard } from "@/components/molecules/cpd-credit-summary-card"
import { CpdDeleteDialog } from "@/components/molecules/cpd-delete-dialog"
import { CpdViewDialog } from "@/components/molecules/cpd-view-dialog"
import { CpdCyclePicker } from "@/components/molecules/cpd-cycle-picker"
import { EmptyState } from "@/components/molecules/empty-state"
import { CpdPendingShell } from "@/components/molecules/page-pending"
import { PAGE_SHELL, PAGE_STICKY_HEADER } from "@/components/molecules/page-shell"
import {
	CPD_HANDBOOK_URL,
	CPD_PAGE_SUBTITLE,
	CPD_PAGE_TITLE,
	CPD_TAB_ITEMS,
	CPD_ZERO_STATE,
	type CpdTab,
} from "@/config/cpd"
import { useCpdProgram } from "@/hooks/use-cpd-program"
import {
	dedupeCycleOptions,
	isCurrentCycle,
	resolveActiveCycle,
	resolveCpdTab,
} from "@/lib/cpd-presentation"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

type CpdActivityTabsProps = {
	activeTab: CpdTab
	/** Off for a closed cycle, where the list keeps its own heading. */
	showTabs: boolean
	pendingClaims: CpdClaim[]
	approvedClaims: CpdClaim[]
	onEdit: (claim: CpdClaim) => void
	onDelete: (claim: CpdClaim) => void
	onView: (claim: CpdClaim) => void
}

/**
 * The two lists, one at a time, cross-fading on a tab change.
 *
 * A child rather than part of `CpdPanel` because `useTransition` must not be
 * created before the payload lands. `resolveCpdTab` answers "approved" while
 * there is no cycle — nothing can be pending yet — so a transition built in
 * that state treats the arrival of the claims as a tab CHANGE and plays the
 * swap: the bar reads Pending while the approved list is still fading out
 * beneath it. Hooks run before any early return, so guarding the render was
 * not enough; the transition had to move behind the guard.
 *
 * `/programs` and `/membership` never hit this — their opening tab comes from
 * the URL, so nothing about it changes when data arrives.
 */
function CpdActivityTabs({
	activeTab,
	showTabs,
	pendingClaims,
	approvedClaims,
	onEdit,
	onDelete,
	onView,
}: CpdActivityTabsProps) {
	const tabPanels = useTransition(activeTab, TAB_PANEL_TRANSITION)

	return tabPanels((style, currentTab) => (
		<animated.div
			key={currentTab}
			role="tabpanel"
			style={style}
			className="pb-2"
		>
			{currentTab === "pending" ? (
				<CpdActivityList
					section="pending"
					claims={pendingClaims}
					showTitle={!showTabs}
					onEdit={onEdit}
					onDelete={onDelete}
				/>
			) : (
				<CpdActivityList
					section="approved"
					claims={approvedClaims}
					showTitle={!showTabs}
					onView={onView}
				/>
			)}
		</animated.div>
	))
}

/**
 * The `/cpd` page — cycle picker, the credit summary, and the cycle's pending
 * and approved activities.
 *
 * The chosen cycle round-trips through `?cycle=`, matching every other filter
 * in this app and making a cycle shareable. It does not touch the query key —
 * every cycle arrives in one `cpdProgram` payload, so switching must not
 * refetch.
 *
 * The legacy's "Manage CPD Credits" box is gone: its three rows were the
 * page's only actions, and a card of links is a worse home for them than the
 * header toolbar every other module puts its actions in. Add Credits is
 * current-cycle only, as it was — Apex will not accept a claim against a
 * closed contract — while the handbook and the catalogue are useful whichever
 * cycle is being read.
 */
function CpdPanel({
	cycle: chosenCycle,
	tab,
	className,
}: {
	cycle?: string
	tab?: CpdTab
	className?: string
}) {
	const navigate = useNavigate({ from: "/cpd/" })
	const { data, isLoading, isError } = useCpdProgram()

	const cycleOptions = dedupeCycleOptions(data?.cycles)
	const cycle = resolveActiveCycle(data, chosenCycle)
	const isCurrent = isCurrentCycle(cycle, data)
	const handbookUrl = data?.cpdHandbookURL?.trim() || CPD_HANDBOOK_URL

	const pendingClaims = cycle?.pendingClaims ?? []
	const approvedClaims = cycle?.approvedClaims ?? []
	const activeTab = resolveCpdTab(tab, {
		isCurrent,
		pendingCount: pendingClaims.length,
	})
	/*
	 * A closed cycle can only ever show one list, so the bar would be a single
	 * pill with nothing to switch to.
	 */
	const showTabs = Boolean(cycle) && isCurrent
	const tabItems = CPD_TAB_ITEMS.map((item) => ({
		...item,
		count:
			item.value === "pending" ? pendingClaims.length : approvedClaims.length,
	}))

	/*
	 * One piece of dialog state, not three booleans — the dialogs are mutually
	 * exclusive and a single discriminated value cannot get into a state where
	 * two are open or a stale claim is shown by the wrong one.
	 */
	const [dialog, setDialog] = useState<
		| { kind: "add" }
		| { kind: "edit"; claim: CpdClaim }
		| { kind: "view"; claim: CpdClaim }
		| { kind: "delete"; claim: CpdClaim }
		| null
	>(null)
	const closeDialog = () => setDialog(null)

	const selectCycle = (next: string) => {
		// Functional updater — a literal would drop any sibling search param.
		void navigate({
			search: (prev) => ({ ...prev, cycle: next }),
			replace: true,
		})
	}

	const selectTab = (next: CpdTab) => {
		void navigate({
			search: (prev) => ({ ...prev, tab: next }),
			replace: true,
		})
	}

	/*
	 * Bail out to the shell rather than rendering the skeleton inside the real
	 * panel — the same shape every other listing panel uses, and here it is
	 * load-bearing rather than tidiness.
	 *
	 * `resolveCpdTab` answers "approved" before the payload lands, because with
	 * no cycle there is nothing pending. Mounting the panel in that state built
	 * the tab transition around "approved", so when the claims arrived and the
	 * default flipped to "pending" the swap ran as an ANIMATED transition: the
	 * bar said Pending while the approved list was still cross-fading out
	 * underneath it. Not mounting until the data is in means the opening tab is
	 * decided once, from real numbers, and the transition only ever runs for a
	 * click.
	 *
	 * `!data` as well as `isLoading`: React Query reports `isLoading` false the
	 * moment the fetch settles, and this component re-renders with the flag
	 * down before `data` is readable on a cache write. `/programs` and
	 * `/membership` never hit this because their opening tab comes from the
	 * URL — it does not depend on the payload, so nothing flips underneath it.
	 */
	// `!data` as well as the flag: React Query drops `isLoading` as the fetch
	// settles, and an error has no data to render either — that case belongs to
	// the error state below, not to the shell.
	if (!isError && (isLoading || !data)) return <CpdPendingShell />

	return (
		<Tabs
			value={activeTab}
			onValueChange={(value) => selectTab(value as CpdTab)}
			className={cn(PAGE_SHELL, className)}
		>
			<header className={cn(PAGE_STICKY_HEADER, "space-y-4")}>
				<div className="flex flex-wrap items-start justify-between gap-x-4 gap-y-3">
					<div className="min-w-0">
						<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
							{CPD_PAGE_TITLE}
						</h1>
						<p className="mt-1 text-sm text-muted-foreground">
							{CPD_PAGE_SUBTITLE}
						</p>
					</div>

					<div className="flex flex-wrap items-center gap-2">
						{cycleOptions.length > 0 && cycle ? (
							<CpdCyclePicker
								cycles={cycleOptions}
								value={cycle.cycleName}
								onChange={selectCycle}
							/>
						) : null}

						<Button asChild variant="outline" size="sm">
							<a href={handbookUrl} target="_blank" rel="noreferrer noopener">
								<BookOpen className="size-4 shrink-0" aria-hidden />
								Download Handbook
							</a>
						</Button>

						<Button asChild variant="outline" size="sm">
							<Link to="/cpd/activities">
								<Compass className="size-4 shrink-0" aria-hidden />
								Browse Credit Opportunities
							</Link>
						</Button>

						{/*
						 * Apex only ever attaches pending claims to the current cycle
						 * and a past cycle cannot be edited, so the write actions are
						 * current-cycle only — here and on the pending list below.
						 */}
						{isCurrent ? (
							<Button
								type="button"
								size="sm"
								onClick={() => setDialog({ kind: "add" })}
							>
								<Plus className="size-4 shrink-0" aria-hidden />
								Add Credits
							</Button>
						) : null}
					</div>
				</div>

				{/*
				 * Pinned with the title, the way `/programs` and `/membership` pin
				 * theirs: switching lists is chrome, and a bar that scrolls out of
				 * reach on a long list is a bar you have to scroll back up to use.
				 */}
				{showTabs ? <PillTabs items={tabItems} value={activeTab} /> : null}
			</header>

			<div className="space-y-4">
				{isError ? (
					<EmptyState
						icon={TriangleAlert}
						tone="error"
						title="We couldn't load your CPD record"
						message="Please try again later."
					/>
				) : null}

				{!isError && !cycle ? (
					<EmptyState
						icon={CPD_ZERO_STATE.icon}
						title={CPD_ZERO_STATE.title}
						message={CPD_ZERO_STATE.message}
					/>
				) : null}

				{!isError && cycle ? (
					<>
						{/*
						 * Outside the tabs, because the credits standing is true of
						 * the CYCLE rather than of either list — putting it in both
						 * panels would redraw it on every switch. It is one strip
						 * tall precisely so it can sit between the pinned tab bar
						 * and the list without separating them.
						 */}
						<CpdCreditSummaryCard cycle={cycle} />

						<CpdActivityTabs
							activeTab={activeTab}
							showTabs={showTabs}
							pendingClaims={pendingClaims}
							approvedClaims={approvedClaims}
							onEdit={(claim) => setDialog({ kind: "edit", claim })}
							onDelete={(claim) => setDialog({ kind: "delete", claim })}
							onView={(claim) => setDialog({ kind: "view", claim })}
						/>
					</>
				) : null}
			</div>

			<CpdClaimDialog
				open={dialog?.kind === "add" || dialog?.kind === "edit"}
				onOpenChange={(next) => {
					if (!next) closeDialog()
				}}
				claim={dialog?.kind === "edit" ? dialog.claim : null}
			/>
			<CpdViewDialog
				open={dialog?.kind === "view"}
				onOpenChange={(next) => {
					if (!next) closeDialog()
				}}
				claim={dialog?.kind === "view" ? dialog.claim : null}
			/>
			<CpdDeleteDialog
				open={dialog?.kind === "delete"}
				onOpenChange={(next) => {
					if (!next) closeDialog()
				}}
				claim={dialog?.kind === "delete" ? dialog.claim : null}
			/>
		</Tabs>
	)
}

export { CpdPanel }
