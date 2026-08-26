import { useState } from "react"

import type { LucideIcon } from "lucide-react"
import { CalendarClock, TriangleAlert } from "lucide-react"

import { AppError } from "@/api/client"
import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import { ExamRegistrationForm } from "@/components/forms/exam-registration/exam-registration-form"
import {
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { EmptyState, type EmptyStateTone } from "@/components/molecules/empty-state"
import {
	SkeletonCard,
	SkeletonField,
	SkeletonRows,
} from "@/components/molecules/form-skeleton"
import { MegaMenuHeadingText } from "@/components/molecules/mega-menu-heading"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import {
	RegistrationOutcome,
	type RegistrationOutcomeKind,
} from "@/components/forms/exam-registration/sections/registration-outcome"
import {
	PUBLIC_REGISTRATION_EXIT,
	type ExamProgramConfig,
} from "@/config/registration"
import type { ExamSubmitOutcome } from "@/hooks/use-exam-registration-submit"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useExamRegistrationLoad } from "@/hooks/use-exam-registration"
import { usePersonalInfoEditData } from "@/hooks/use-personal-info-edit-data"
import { cn } from "@/lib/utils"

type ExamRegistrationPanelProps = {
	/** The programme's own copy, resolved by the dispatcher from the slug. */
	program: ExamProgramConfig
	programType: string
	regCode?: string
	/** Plays the page exit before Back navigates. */
	onNavigateBack: (run: () => void) => void
	/**
	 * The payment provider's answer, when the browser has just come back from
	 * it. Arrives as a fresh page load with no React state, so it has to be
	 * read from the URL rather than remembered.
	 */
	paymentReturn?: {
		orderNumber?: string
	} | null
}

/**
 * The page's own shape, greyed out.
 *
 * Mirrors the real layout field for field — two columns, the same card
 * boundaries, the same header bar — so the form does not jump or reflow when
 * the data lands. A generic block skeleton loads faster to write and then
 * makes every arrival feel like a lurch.
 */
/**
 * The page's own shape, greyed out.
 *
 * Mirrors the real layout field for field — the same 60/40 split, the same
 * card boundaries, the same header bar — so nothing moves when the payload
 * lands. It previously guessed 70/30 against a 60/40 form and an `h-11` submit
 * against an `h-10` one, so the whole page stepped sideways and the header
 * jumped 4px on arrival. The geometry now comes from the shared constants both
 * the form and this file import, which is the only way the two stay honest.
 *
 * A generic block skeleton is quicker to write and then makes every arrival
 * feel like a lurch.
 */
function RegistrationSkeleton({
	/**
	 * Members get a back link in the real bar; guests do not. False while the
	 * session is still resolving, so the placeholder is only ever *added* on
	 * arrival, never taken away — the less jarring of the two mistakes.
	 */
	hasBackLink,
}: {
	hasBackLink: boolean
}) {
	return (
		<div className="flex flex-col gap-6" aria-busy aria-live="polite">
			<span className="sr-only">Loading your registration…</span>

			{/* The header bar: back link, title, total, submit. */}
			<div className={REGISTRATION_STICKY_BAR}>
				<div className="flex min-w-0 items-center gap-4">
					{hasBackLink ? (
						<>
							<Skeleton className="h-6 w-28" />
							<div className="hidden h-6 w-px shrink-0 bg-border sm:block" />
						</>
					) : null}
					<Skeleton className="h-8 w-64" />
				</div>
				<div className="flex items-center gap-4">
					<Skeleton
						className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-24 shrink-0")}
					/>
					<Skeleton
						className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-40 rounded-xl")}
					/>
				</div>
			</div>

			<div className={REGISTRATION_GRID}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					{/* Your details. */}
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
					{/* Your exam — or, on a course, the membership offer. */}
					<SkeletonCard
						rows={
							<div className="flex flex-col gap-4">
								<SkeletonField />
								<Skeleton className="h-32 w-full rounded-xl" />
							</div>
						}
					/>
					{/*
					 * Payment and acknowledgements. Both are conditional on the real
					 * form, but every audience sees at least one of them, so the
					 * column is short by a card without this rather than long by one.
					 */}
					<SkeletonCard rows={<SkeletonRows count={3} />} />
				</div>

				<aside className={REGISTRATION_RAIL_COLUMN}>
					{/* Materials, then the order summary — the rail's two cards. */}
					<div className="flex flex-col gap-4">
						<SkeletonCard
							rows={
								<div className="flex flex-col gap-2">
									<Skeleton className="h-20 w-full rounded-xl" />
									<Skeleton className="h-20 w-full rounded-xl" />
								</div>
							}
						/>
						<SkeletonCard rows={<SkeletonRows count={4} />} />
					</div>
				</aside>
			</div>
		</div>
	)
}

/**
 * A programme page with no form on it.
 *
 * Same chrome as every other programme subpage — back link, then the
 * programme's own heading — with the reason in the standard empty-state block
 * underneath. It replaced a bare `Alert`, which stretched edge to edge with no
 * heading and, worse, no way out: the form carries Back in its sticky bar, and
 * these screens are what happens instead of the form.
 *
 * A guest gets the heading without the back link. Every in-app parent is
 * behind the session guard, so "back" would mean a login wall; they are
 * offered garp.org instead, in the block's own action.
 */
function RegistrationNotice({
	program,
	icon,
	tone,
	title,
	message,
	isAuthenticated,
	onNavigateBack,
}: {
	program: ExamProgramConfig
	icon: LucideIcon
	tone: EmptyStateTone
	title: string
	message: string
	isAuthenticated: boolean
	onNavigateBack: (run: () => void) => void
}) {
	const heading = <MegaMenuHeadingText heading={program.heading} />

	return (
		<div className="flex flex-col gap-6">
			{isAuthenticated ? (
				<ProgramsSubpageHeader title={heading} onNavigateBack={onNavigateBack} />
			) : (
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{heading}
				</h1>
			)}

			<EmptyState
				icon={icon}
				tone={tone}
				title={title}
				message={message}
				action={
					isAuthenticated ? null : (
						<Button asChild variant="outline">
							<a href={PUBLIC_REGISTRATION_EXIT.href}>
								Back to {PUBLIC_REGISTRATION_EXIT.label}
							</a>
						</Button>
					)
				}
			/>
		</div>
	)
}

/**
 * Owns the two reads the form needs, and decides whether there is a form to
 * show at all.
 *
 * The registration payload answers three different things over one request:
 * the form data, a refusal (`isEligible: false` — a closed window, or a reg
 * code that resolved to nothing, both HTTP 200), and an actual failure. The
 * refusal carries its own sentence, so it is shown as a message rather than an
 * error state.
 *
 * The profile read is separate and deliberately non-blocking in spirit — but
 * the form still waits for it, because seeding react-hook-form after mount
 * does not reach the Radix selects.
 */
function ExamRegistrationPanel({
	program,
	programType,
	regCode,
	onNavigateBack,
	paymentReturn,
}: ExamRegistrationPanelProps) {
	const [outcome, setOutcome] = useState<{
		kind: RegistrationOutcomeKind
		orderNumber?: string | null
		total?: number | null
		currency?: string | null
	} | null>(null)
	const load = useExamRegistrationLoad(programType, regCode)
	const currentUser = useCurrentUser()
	const contactId = currentUser.data?.contactId ?? ""
	/* Empty for a guest — the public route serves this form with no session. */
	const hasContact = Boolean(contactId)
	const isAuthenticated = Boolean(currentUser.data)
	const profile = usePersonalInfoEditData(contactId, hasContact)

	/*
	 * A return from the payment provider is shown before anything else is
	 * fetched. The order is already written by this point — re-rendering the
	 * form while the load resolves would invite a second registration.
	 */
	if (paymentReturn) {
		return (
			<RegistrationOutcome
				kind="paid"
				orderNumber={paymentReturn.orderNumber}
				isAuthenticated={isAuthenticated}
			/>
		)
	}

	if (outcome) {
		return (
			<RegistrationOutcome
				kind={outcome.kind}
				orderNumber={outcome.orderNumber}
				total={outcome.total}
				currency={outcome.currency}
				isAuthenticated={isAuthenticated}
			/>
		)
	}

	/*
	 * The profile is only waited for when there is a contact to load. A
	 * disabled React Query sits at `status: "pending"` for ever, so testing it
	 * unconditionally strands a guest — who has no contact id, so the query
	 * never runs — on the skeleton permanently. `currentUser` is settled
	 * before this by both route guards; it is tested anyway so the one-shot
	 * form seed cannot lose a race with it.
	 */
	if (
		load.isPending ||
		currentUser.isPending ||
		(hasContact && profile.isPending)
	) {
		return <RegistrationSkeleton hasBackLink={isAuthenticated} />
	}

	if (load.isError) {
		return (
			<RegistrationNotice
				program={program}
				icon={TriangleAlert}
				tone="error"
				title="Unable to open registration"
				message={AppError.fromUnknown(load.error).messages[0]}
				isAuthenticated={isAuthenticated}
				onNavigateBack={onNavigateBack}
			/>
		)
	}

	const data = load.data
	if (data.eligibility?.isEligible === false) {
		return (
			/*
			 * Saffron, not destructive red. A closed window — or a programme the
			 * candidate is not yet eligible for — is the system working, and an
			 * error colour sends them looking for a fault that is not there. The
			 * server's own sentence is kept: it is the only thing that knows why.
			 */
			<RegistrationNotice
				program={program}
				icon={CalendarClock}
				tone="notice"
				title="Registration is not open"
				message={
					data.eligibility.message ??
					"Registration is not currently open for this exam."
				}
				isAuthenticated={isAuthenticated}
				onNavigateBack={onNavigateBack}
			/>
		)
	}

	return (
		<ExamRegistrationForm
			load={data}
			program={program}
			programType={programType}
			regCode={regCode}
			onNavigateBack={onNavigateBack}
			onRegistered={(result: ExamSubmitOutcome) => {
				if (result.kind === "redirecting") return
				setOutcome({
					kind: result.kind,
					orderNumber: result.result.orderNumber,
					total: result.result.total,
					currency: "USD",
				})
			}}
			// A missing profile is not fatal — the form renders empty and the
			// member fills it in, which beats blocking registration on a
			// secondary read.
			profile={profile.data ?? null}
			isAuthenticated={isAuthenticated}
		/>
	)
}

export { ExamRegistrationPanel }
