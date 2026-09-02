import { useState } from "react"
import { animated } from "@react-spring/web"

import { AppError } from "@/api/client"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Skeleton } from "@/components/atoms/skeleton"
import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import { AffiliateOutcome } from "@/components/forms/affiliate/sections/affiliate-outcome"
import {
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_GRID,
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_SCROLL,
	REGISTRATION_SHELL,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import {
	SkeletonCard,
	SkeletonField,
	SkeletonRows,
} from "@/components/molecules/form-skeleton"
import { useAffiliateRegistration } from "@/hooks/use-affiliate-registration"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { cn } from "@/lib/utils"

/**
 * The page's own shape, greyed out.
 *
 * Same 60/40 split and same bar geometry as the real form, taken from the
 * shared constants rather than restated — a skeleton that guesses its own
 * numbers is a skeleton that drifts, and the exam one had.
 *
 * No back-link placeholder: this route is guest-only, so the real bar never
 * has one.
 */
function AffiliateRegistrationSkeleton() {
	return (
		<div className="flex flex-col gap-6" aria-busy aria-live="polite">
			<span className="sr-only">Loading Affiliate membership registration…</span>

			{/* The header bar: title, total, submit. */}
			<div className={REGISTRATION_STICKY_BAR}>
				<Skeleton className="h-8 w-80 max-w-full" />
				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					<Skeleton
						className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-16 shrink-0")}
					/>
					<Skeleton
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							REGISTRATION_BAR_SUBMIT,
							"rounded-xl sm:w-32",
						)}
					/>
				</div>
			</div>

			<div className={REGISTRATION_GRID}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					<SkeletonCard
						rows={
							<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
								<SkeletonField />
								<SkeletonField />
								<SkeletonField />
								<SkeletonField />
								<SkeletonField className="sm:col-span-2" />
							</div>
						}
					/>
					<SkeletonCard rows={<SkeletonRows count={3} />} />
				</div>

				<aside className={REGISTRATION_RAIL_COLUMN}>
					<div className="flex flex-col gap-4">
						<SkeletonCard rows={<SkeletonRows count={4} />} />
					</div>
				</aside>
			</div>
		</div>
	)
}

/**
 * Owns the one read the form needs, and decides whether there is a form to
 * show at all.
 *
 * The load payload answers three different things over one request: the form
 * data (countries), a refusal (`isEligible: false` — HTTP 200 with its own
 * sentence), and an actual failure. The refusal carries its own wording, so it
 * is shown as a message rather than as an error state.
 *
 * There is deliberately no session read here, unlike the exam panel. This
 * route is guest-only by construction — `redirectMemberToDashboard` runs in
 * `beforeLoad` — so there is no member branch to resolve, nothing to prefill,
 * and no in-app destination any of these screens could point at.
 */
function AffiliateRegistrationPanel({ className }: { className?: string }) {
	const { style } = useSubpageTransition()
	const load = useAffiliateRegistration()
	const [completed, setCompleted] = useState(false)

	const body = completed ? (
		<AffiliateOutcome />
	) : load.isPending ? (
		<AffiliateRegistrationSkeleton />
	) : load.isError ? (
		<Alert variant="destructive">
			<AlertTitle>Unable to open registration</AlertTitle>
			<AlertDescription>
				{AppError.fromUnknown(load.error).messages[0]}
			</AlertDescription>
		</Alert>
	) : load.data.eligibility?.isEligible === false ? (
		<Alert>
			<AlertTitle>Registration unavailable</AlertTitle>
			<AlertDescription>
				{load.data.eligibility.message ??
					"Affiliate registration is not available right now."}
			</AlertDescription>
		</Alert>
	) : (
		<AffiliateRegistrationForm
			load={load.data}
			onRegistered={() => {
				setCompleted(true)
			}}
		/>
	)

	return (
		<animated.div style={style} className={cn(REGISTRATION_SHELL, className)}>
			<div className={REGISTRATION_SCROLL}>{body}</div>
		</animated.div>
	)
}

export { AffiliateRegistrationPanel }
