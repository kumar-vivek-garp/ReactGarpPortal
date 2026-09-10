import { useState } from "react"

import type { LucideIcon } from "lucide-react"
import { CalendarClock, TriangleAlert } from "lucide-react"

import { useQuery } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import { examResumeQueryOptions } from "@/api/registration/query-options"
import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import { ExamRegistrationForm } from "@/components/forms/exam-registration/exam-registration-form"
import { CheckoutCancelledScreen } from "@/components/forms/exam-registration/sections/checkout-cancelled-screen"
import { PaymentReturnScreen } from "@/components/forms/exam-registration/sections/payment-return-screen"
import { RegistrationSurvey } from "@/components/forms/registration-survey/registration-survey"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_RAIL_COLUMN_GUEST,
	REGISTRATION_RAIL_CONTROLS,
	REGISTRATION_RAIL_STACK,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { type EmptyStateTone } from "@/components/molecules/empty-state"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
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
import type { ProgramChrome } from "@/config/program-chrome"
import { registrationChromeForSlug } from "@/lib/registration-chrome"
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
	 * read from the URL rather than remembered. `statusId` is the order — or,
	 * under the deferred flow, the staged row — to poll on.
	 */
	paymentReturn?: { statusId?: string; orderNumber?: string } | null
	/** The provider's cancel leg for an ORDER: roll it back, offer a restart. */
	checkoutCancelled?: { orderId?: string } | null
	/**
	 * A staged registration to rebuild the form from (deferred flow). Arrives
	 * on the provider's cancel leg — the server appends it to that URL — and
	 * on the declined screen's Try again.
	 */
	resumeStagedId?: string
	/** The `?track_cta=` attribution tag, for the identity call. */
	trackCta?: string
	/**
	 * True when the shell above already shows the programme title, so the
	 * form's sticky bar drops its own. Set by the public route, whose shell
	 * renders the banner; the member route leaves it alone.
	 */
	titleInBanner?: boolean
	/**
	 * True when the total and submit belong in the order rail instead of the
	 * sticky bar — the 2027 guest layout, which applies to every guest form,
	 * not only the ones with a banner.
	 */
	controlsInRail?: boolean
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
	titleInBanner = false,
	controlsInRail = false,
	chrome,
}: {
	hasBackLink: boolean
	titleInBanner?: boolean
	controlsInRail?: boolean
	/** Mirrors the real bar's seal and wash so neither arrives late. */
	chrome?: ProgramChrome
}) {
	/* Mirrors the form's own derivation — see `showBar` there. */
	const showBar = hasBackLink || !titleInBanner || !controlsInRail
	const controls = (
		<div
			className={
				controlsInRail
					? REGISTRATION_RAIL_CONTROLS
					: REGISTRATION_BAR_CONTROL_GROUP
			}
		>
			<Skeleton className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-24 shrink-0")} />
			<Skeleton
				className={cn(
					REGISTRATION_BAR_CONTROL_HEIGHT,
					REGISTRATION_BAR_SUBMIT,
					"rounded-xl sm:w-40",
				)}
			/>
		</div>
	)

	return (
		<div className="flex flex-col gap-6" aria-busy aria-live="polite">
			<span className="sr-only">Loading your registration…</span>

			{/* The header bar: back link, title, total, submit — each of which the
			    real bar can lose, so this one has to lose them on the same terms. */}
			{showBar ? (
				<div className={cn(REGISTRATION_STICKY_BAR, chrome?.barWash)}>
					<div className={REGISTRATION_BAR_TITLE_GROUP}>
						{hasBackLink ? (
							<>
								{/* Arrow-only below `sm`, like the real back link. */}
								<Skeleton className="h-6 w-6 shrink-0 sm:w-28" />
								<div className="hidden h-6 w-px shrink-0 bg-border sm:block" />
							</>
						) : null}
						{titleInBanner ? null : (
							<>
								{/* Same 36px box the real seal takes, so the row does not
								    reflow when the payload lands. */}
								{chrome ? (
									<Skeleton className="size-9 shrink-0 rounded-full" />
								) : null}
								<Skeleton className="h-8 w-64 max-w-full" />
							</>
						)}
					</div>
					{controlsInRail ? null : controls}
				</div>
			) : null}

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

				<aside
					className={cn(
						showBar ? REGISTRATION_RAIL_COLUMN : REGISTRATION_RAIL_COLUMN_GUEST,
						controlsInRail && REGISTRATION_RAIL_STACK,
					)}
				>
					{controlsInRail ? controls : null}
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
	titleInBanner = false,
}: {
	program: ExamProgramConfig
	icon: LucideIcon
	tone: EmptyStateTone
	title: string
	message: string
	isAuthenticated: boolean
	onNavigateBack: (run: () => void) => void
	/**
	 * True when the shell's banner is already showing this title above. Without
	 * it a guest hitting a CLOSED registration on a redesigned programme got the
	 * banner's `h1` and this one, in two different fonts — the exact thing the
	 * flag exists to stop, missed because this screen never received it.
	 */
	titleInBanner?: boolean
}) {
	const heading = <MegaMenuHeadingText heading={program.heading} />

	return (
		<div className="flex flex-col gap-6">
			{isAuthenticated ? (
				<ProgramsSubpageHeader title={heading} onNavigateBack={onNavigateBack} />
			) : titleInBanner ? null : (
				<h1 className="font-sans text-3xl font-extrabold text-foreground">
					{heading}
				</h1>
			)}

			<RegistrationStatusPanel
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
	checkoutCancelled,
	resumeStagedId,
	trackCta,
	titleInBanner = false,
	controlsInRail = false,
}: ExamRegistrationPanelProps) {
	const [outcome, setOutcome] = useState<{
		kind: RegistrationOutcomeKind
		orderNumber?: string | null
		total?: number | null
		currency?: string | null
		/** The order or staged id — the survey's save key. */
		settlementId: string | null
	} | null>(null)
	/* The survey shows once after a success, then gives way to the actions. */
	const [surveyDone, setSurveyDone] = useState(false)
	/*
	 * Neither payment leg renders the form, so neither loads it: the return
	 * leg should be network-silent apart from its own status poll.
	 */
	const onPaymentLeg = Boolean(paymentReturn || checkoutCancelled)
	const load = useExamRegistrationLoad(programType, regCode, undefined, {
		enabled: !onPaymentLeg,
	})
	const resume = useQuery(
		examResumeQueryOptions(onPaymentLeg ? null : resumeStagedId),
	)
	const currentUser = useCurrentUser()
	const contactId = currentUser.data?.contactId ?? ""
	/* Empty for a guest — the public route serves this form with no session. */
	const hasContact = Boolean(contactId)
	const isAuthenticated = Boolean(currentUser.data)
	/* Seal + wash for the signed-in bar; undefined for an un-redesigned one. */
	const chrome = registrationChromeForSlug(programType)?.chrome
	const profile = usePersonalInfoEditData(hasContact)

	/*
	 * A return from the payment provider is shown before anything else is
	 * fetched. The order is already written by this point — re-rendering the
	 * form while the load resolves would invite a second registration.
	 */
	if (paymentReturn) {
		return (
			<PaymentReturnScreen
				statusId={paymentReturn.statusId}
				orderNumber={paymentReturn.orderNumber}
				programName={program.abbrevName}
				isAuthenticated={isAuthenticated}
			/>
		)
	}

	if (checkoutCancelled) {
		return (
			<CheckoutCancelledScreen
				orderId={checkoutCancelled.orderId}
				isAuthenticated={isAuthenticated}
			/>
		)
	}

	/*
	 * Done. The "Complete Your Profile" survey first — GarpAppv1 shows it after
	 * every successful registration, card or offline — then the closing copy
	 * with its actions. A REG- number is shown as a reference, not an order.
	 */
	if (outcome) {
		return (
			<RegistrationOutcome
				kind={outcome.kind}
				orderNumber={outcome.orderNumber}
				referenceLabel={outcome.orderNumber?.startsWith("REG-") ? "Reference" : "Order"}
				total={outcome.total}
				currency={outcome.currency}
				isAuthenticated={isAuthenticated}
				hideActions={!surveyDone}
			>
				{surveyDone ? null : (
					<RegistrationSurvey
						surveyKey={outcome.settlementId}
						programName={program.abbrevName}
						onFinished={() => setSurveyDone(true)}
					/>
				)}
			</RegistrationOutcome>
		)
	}

	/*
	 * The profile is only waited for when there is a contact to load. A
	 * disabled React Query sits at `status: "pending"` for ever, so testing it
	 * unconditionally strands a guest — who has no contact id, so the query
	 * never runs — on the skeleton permanently. The same applies to the resume
	 * read, waited for only when there is a staged id: the form seeds itself at
	 * mount, so it must not mount before the restored payload is in hand.
	 * `currentUser` is settled before this by both route guards; it is tested
	 * anyway so the one-shot form seed cannot lose a race with it.
	 */
	if (
		load.isPending ||
		currentUser.isPending ||
		(hasContact && profile.isPending) ||
		(Boolean(resumeStagedId) && resume.isPending)
	) {
		return (
			<RegistrationSkeleton
				hasBackLink={isAuthenticated}
				titleInBanner={titleInBanner}
				controlsInRail={controlsInRail}
				chrome={chrome}
			/>
		)
	}

	if (load.isError) {
		return (
			<RegistrationNotice
				titleInBanner={titleInBanner}
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
				titleInBanner={titleInBanner}
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
			trackCta={trackCta}
			titleInBanner={titleInBanner}
			controlsInRail={controlsInRail}
			onNavigateBack={onNavigateBack}
			onRegistered={(result: ExamSubmitOutcome) => {
				if (result.kind === "redirecting") return
				setOutcome({
					kind: result.kind,
					orderNumber:
						result.result.orderNumber ?? result.result.registrationRef ?? null,
					total: result.result.total,
					currency: "USD",
					settlementId: result.settlementId,
				})
			}}
			/*
			 * Restored only when the server says the row is still payable and
			 * holds a payload. Anything else — expired, already paid, unknown —
			 * is a plain empty form, not an error screen.
			 */
			resume={
				resumeStagedId && resume.data?.resumable && resume.data.payload
					? {
							stagedId: resume.data.stagedId ?? resumeStagedId,
							request: resume.data.payload,
						}
					: null
			}
			// A missing profile is not fatal — the form renders empty and the
			// member fills it in, which beats blocking registration on a
			// secondary read.
			profile={profile.data ?? null}
			isAuthenticated={isAuthenticated}
		/>
	)
}

export { ExamRegistrationPanel }
