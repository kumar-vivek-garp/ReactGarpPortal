import { useState } from "react"
import { useNavigate } from "@tanstack/react-router"

import type { CpdClaim } from "@/api/cpd"
import { CpdActivityList } from "@/components/molecules/cpd-activity-list"
import { CpdClaimDialog } from "@/components/molecules/cpd-claim-dialog"
import { CpdCreditSummaryCard } from "@/components/molecules/cpd-credit-summary-card"
import { CpdDeleteDialog } from "@/components/molecules/cpd-delete-dialog"
import { CpdViewDialog } from "@/components/molecules/cpd-view-dialog"
import { CpdCyclePicker } from "@/components/molecules/cpd-cycle-picker"
import { CpdManageBox } from "@/components/molecules/cpd-manage-box"
import { CpdContentSkeleton } from "@/components/molecules/page-pending"
import { PageEnterFade } from "@/components/molecules/page-enter-fade"
import { CPD_PAGE_TITLE, CPD_ZERO_STATE } from "@/config/cpd"
import { useCpdProgram } from "@/hooks/use-cpd-program"
import {
	dedupeCycleOptions,
	isCurrentCycle,
	resolveActiveCycle,
} from "@/lib/cpd-presentation"
import { cn } from "@/lib/utils"

/** Same dashed treatment the orders and programs zero states use. */
function CpdEmptyState() {
	const Icon = CPD_ZERO_STATE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{CPD_ZERO_STATE.title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{CPD_ZERO_STATE.message}
			</p>
		</div>
	)
}

/**
 * The `/cpd` page — cycle picker, the manage box, pending and approved
 * activities, and the credit summary.
 *
 * The chosen cycle round-trips through `?cycle=`, matching every other filter
 * in this app and making a cycle shareable. It does not touch the query key —
 * every cycle arrives in one `cpdProgram` payload, so switching must not
 * refetch.
 */
function CpdPanel({
	cycle: chosenCycle,
	className,
}: {
	cycle?: string
	className?: string
}) {
	const navigate = useNavigate({ from: "/cpd/" })
	const { data, isLoading, isError } = useCpdProgram()

	const cycleOptions = dedupeCycleOptions(data?.cycles)
	const cycle = resolveActiveCycle(data, chosenCycle)
	const isCurrent = isCurrentCycle(cycle, data)

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

	return (
		<PageEnterFade className={cn("space-y-6", className)}>
			<header className="flex flex-wrap items-center justify-between gap-3">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{CPD_PAGE_TITLE}
				</h1>
				{cycleOptions.length > 0 && cycle ? (
					<CpdCyclePicker
						cycles={cycleOptions}
						value={cycle.cycleName}
						onChange={selectCycle}
					/>
				) : null}
			</header>

			{isLoading ? <CpdContentSkeleton /> : null}

			{!isLoading && isError ? (
				<p className="text-sm text-muted-foreground">
					We couldn&apos;t load your CPD record. Please try again later.
				</p>
			) : null}

			{!isLoading && !isError && !cycle ? <CpdEmptyState /> : null}

			{!isLoading && !isError && cycle ? (
				<div className="grid items-start gap-6 app:grid-cols-[minmax(0,1fr)_20rem]">
					<div className="min-w-0 space-y-6">
						{/*
						 * Both are current-cycle only: Apex never attaches pending
						 * claims to a closed cycle, and a past cycle cannot be edited.
						 */}
						{isCurrent ? (
							<CpdManageBox
								handbookUrl={data?.cpdHandbookURL?.trim() || undefined}
								onAddCredits={() => setDialog({ kind: "add" })}
							/>
						) : null}
						{isCurrent ? (
							<CpdActivityList
								section="pending"
								claims={cycle.pendingClaims ?? []}
								onEdit={(claim) => setDialog({ kind: "edit", claim })}
								onDelete={(claim) => setDialog({ kind: "delete", claim })}
							/>
						) : null}
						<CpdActivityList
							section="approved"
							claims={cycle.approvedClaims ?? []}
							onView={(claim) => setDialog({ kind: "view", claim })}
						/>
					</div>

					{/* DOM-second, so it falls below the tables on mobile with no order-*. */}
					<CpdCreditSummaryCard cycle={cycle} />
				</div>
			) : null}

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
		</PageEnterFade>
	)
}

export { CpdPanel }
