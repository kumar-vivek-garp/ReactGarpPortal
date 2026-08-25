import { useState } from "react"
import { animated } from "@react-spring/web"

import { AppError } from "@/api/client"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import {
	Card,
	CardContent,
	CardHeader,
} from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { AffiliateRegistrationForm } from "@/components/forms/affiliate/affiliate-registration-form"
import { AffiliateOutcome } from "@/components/forms/affiliate/sections/affiliate-outcome"
import {
	REGISTRATION_SCROLL,
	REGISTRATION_SHELL,
} from "@/components/forms/registration-shell"
import { useAffiliateRegistration } from "@/hooks/use-affiliate-registration"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { cn } from "@/lib/utils"

function SkeletonField({ className }: { className?: string }) {
	return (
		<div className={cn("flex flex-col gap-2", className)}>
			<Skeleton className="h-4 w-24" />
			<Skeleton className="h-9 w-full rounded-xl" />
		</div>
	)
}

function SkeletonCard({
	rows,
	className,
}: {
	rows: React.ReactNode
	className?: string
}) {
	return (
		<Card className={className}>
			<CardHeader>
				<Skeleton className="h-5 w-40" />
			</CardHeader>
			<CardContent>{rows}</CardContent>
		</Card>
	)
}

/**
 * The page's own shape, greyed out.
 *
 * Mirrors the real layout card for card — the header bar, the 60/40 split, the
 * same field grid — so nothing jumps or reflows when the countries land. A
 * generic block skeleton is quicker to write and then makes every arrival feel
 * like a lurch.
 */
function AffiliateRegistrationSkeleton() {
	return (
		<div className="flex flex-col gap-6" aria-busy aria-live="polite">
			<span className="sr-only">Loading Affiliate membership registration…</span>

			{/* The header bar: title, total, submit. */}
			<div className="flex flex-wrap items-center justify-between gap-4 py-3">
				<Skeleton className="h-6 w-80" />
				<div className="flex items-center gap-4">
					<Skeleton className="h-10 w-16" />
					<Skeleton className="h-11 w-32 rounded-xl" />
				</div>
			</div>

			<div className="grid grid-cols-1 gap-6 lg:grid-cols-10">
				<div className="flex flex-col gap-6 lg:col-span-6">
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
					<SkeletonCard
						rows={
							<div className="flex flex-col gap-3">
								{Array.from({ length: 3 }).map((_, index) => (
									<Skeleton key={index} className="h-5 w-full rounded-lg" />
								))}
							</div>
						}
					/>
				</div>

				<div className="flex flex-col gap-4 lg:col-span-4">
					<SkeletonCard
						rows={
							<div className="flex flex-col gap-3">
								{Array.from({ length: 4 }).map((_, index) => (
									<Skeleton key={index} className="h-5 w-full rounded-lg" />
								))}
							</div>
						}
					/>
					<SkeletonCard
						rows={<Skeleton className="h-20 w-full rounded-xl" />}
					/>
				</div>
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
