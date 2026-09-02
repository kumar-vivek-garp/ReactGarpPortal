import { useEffect, useRef, useState } from "react"
import { animated } from "@react-spring/web"
import { CalendarCheck2, CalendarX2, LogIn, ShieldAlert } from "lucide-react"
import { Link, useLocation } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
import { RegistrationOutcome } from "@/components/forms/exam-registration/sections/registration-outcome"
import {
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_SCROLL,
	REGISTRATION_SHELL,
	REGISTRATION_SINGLE_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { EventRegistrationForm } from "@/components/forms/event-registration/event-registration-form"
import { RsvpGate } from "@/components/forms/event-registration/sections/rsvp-gate"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import type { EventCountry, EventVariant } from "@/api/registration/event-types"
import { AppError, notifyError } from "@/api/client"
import { rollbackEventRegistration } from "@/api/registration/event-registration"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import {
	EVENT_REGISTRATION_OUTCOMES,
	EVENT_REGISTRATION_TITLES,
} from "@/config/event-registration"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useEventRegistrationLoad } from "@/hooks/use-event-registration"
import { usePersonalInfoEditData } from "@/hooks/use-personal-info-edit-data"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import {
	useDeclineEventRsvp,
	useEventRegistrationSubmit,
} from "@/hooks/use-event-registration-submit"
import { resolveEventScreen } from "@/lib/event-registration-presentation"
import { buildEventRegisterRequest } from "@/lib/event-registration-payloads"
import { cn } from "@/lib/utils"

type EventRegistrationPanelProps = {
	variant: EventVariant
	eventId: string
	/** Set when the payment provider returned successfully (`?stripe_return=1`). */
	paymentReturn: { orderNumber?: string | null } | null
	/** Set when the provider returned from a cancelled checkout. */
	checkoutCancelled: { orderId?: string | null } | null
	className?: string
}

function errorMessage(error: unknown, fallback: string): string {
	if (error instanceof AppError && error.messages.length > 0) {
		return error.messages.join(" ")
	}
	if (error instanceof Error && error.message) return error.message
	return fallback
}

/**
 * The same sticky-bar chrome the form carries — back link for members, the
 * event's title when it is known — wrapped around every non-form screen, so a
 * refusal or an outcome never floats context-free in an empty page.
 */
function ScreenChrome({
	title,
	showBack,
	onNavigateBack,
	wide = false,
	children,
}: {
	title: string
	showBack: boolean
	/** `useSubpageTransition().exit` — receives the deferred navigation. */
	onNavigateBack?: (run: () => void) => void
	/** Full-bleed content (the status surfaces); default is the centred column. */
	wide?: boolean
	children: React.ReactNode
}) {
	return (
		<>
			<div className={REGISTRATION_STICKY_BAR}>
				<div className={REGISTRATION_BAR_TITLE_GROUP}>
					{showBack ? (
						<>
							<ProgramsSubpageHeader
								back={{ kind: "events" }}
								onNavigateBack={onNavigateBack}
								iconOnlyBackOnMobile
							/>
							<div
								className="hidden h-6 w-px shrink-0 bg-border sm:block"
								aria-hidden
							/>
						</>
					) : null}
					<h1 className={REGISTRATION_BAR_TITLE}>{title}</h1>
				</div>
			</div>
			<div className={cn(wide ? "w-full" : REGISTRATION_SINGLE_COLUMN, "mt-4")}>
				{children}
			</div>
		</>
	)
}

/** Mirrors the real bar + 60/40 grid so nothing shifts when the load lands. */
function EventRegistrationSkeleton() {
	return (
		<>
			<div className={REGISTRATION_STICKY_BAR} aria-busy aria-label="Loading">
				<Skeleton className="h-8 w-64 max-w-full" />
				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					<Skeleton
						className={cn(REGISTRATION_BAR_CONTROL_HEIGHT, "w-24 shrink-0")}
					/>
					<Skeleton
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							REGISTRATION_BAR_SUBMIT,
							"rounded-xl sm:w-44",
						)}
					/>
				</div>
			</div>
			<div className={cn(REGISTRATION_GRID, "mt-4")}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					{[0, 1, 2].map((key) => (
						<Skeleton
							key={key}
							className="h-44 w-full rounded-xl border border-border bg-card"
						/>
					))}
				</div>
				<aside className={REGISTRATION_RAIL_COLUMN}>
					<div className="flex flex-col gap-4">
						<Skeleton className="h-52 w-full rounded-xl border border-border bg-card" />
						<Skeleton className="h-36 w-full rounded-xl border border-border bg-card" />
					</div>
				</aside>
			</div>
		</>
	)
}

/**
 * Load / eligibility / outcome switch for one event registration.
 *
 * Screen order is the ported GarpAppv1 contract: payment legs render before
 * ANY query result is consulted (the order is already charged or already needs
 * rolling back — re-rendering a form behind either invites a second
 * registration), then not-found, already-registered, refusal, the RSVP gate,
 * and finally the form.
 */
function EventRegistrationPanel({
	variant,
	eventId,
	paymentReturn,
	checkoutCancelled,
	className,
}: EventRegistrationPanelProps) {
	const location = useLocation()
	// The programs subpage enter/exit spring — back plays the exit first.
	const { style: transitionStyle, exit } = useSubpageTransition()
	const currentUser = useCurrentUser()
	const load = useEventRegistrationLoad(variant, eventId)
	const submit = useEventRegistrationSubmit()
	const decline = useDeclineEventRsvp()

	/**
	 * The member's profile, the exam form's identity seed — it answers on
	 * local dev too, where the admin-signed gateway makes the event load
	 * return no contact. Only fetched for a session with a contact, and a
	 * failure is not fatal: the form renders with empty identity fields.
	 */
	const contactId = currentUser.data?.contactId ?? ""
	const hasContact = Boolean(contactId)
	const profile = usePersonalInfoEditData(contactId, hasContact)

	/** Accept is client-side only — it reveals the form. */
	const [rsvpAccepted, setRsvpAccepted] = useState(false)
	const [declined, setDeclined] = useState(false)

	/**
	 * A cancelled checkout leaves a staged order AND a registration row that
	 * makes every later load report `alreadyRegistered` — rolled back exactly
	 * once (the ref survives StrictMode's double-invoke), never retried, and
	 * never on the success leg.
	 */
	const rolledBack = useRef(false)
	const cancelledOrderId = checkoutCancelled?.orderId ?? null
	useEffect(() => {
		if (!cancelledOrderId || rolledBack.current) return
		rolledBack.current = true
		rollbackEventRegistration(cancelledOrderId, "Checkout cancelled").catch(
			(error: unknown) => {
				notifyError(error, "Unable to release the registration")
			},
		)
	}, [cancelledOrderId])

	const isClientAuthenticated = Boolean(currentUser.data)

	const handleSubmit = (
		values: EventFormValues,
		selectedCountry: EventCountry | null,
	) => {
		if (!load.data?.event_x) return
		submit.mutate({
			variant,
			request: buildEventRegisterRequest(values, {
				variant,
				eventId,
				event: load.data.event_x,
				selectedCountry,
			}),
		})
	}

	const handleDecline = () => {
		// A guest at the gate has typed nothing yet, so an empty email is the
		// honest value — the server records the decline against the invitation.
		decline.mutate(
			{ eventId, userEmail: load.data?.contact?.email?.trim() ?? "" },
			{ onSuccess: () => setDeclined(true) },
		)
	}

	let body: React.ReactNode
	/** Form and skeleton carry their own bars; every other screen gets one. */
	let withChrome = true
	/** The status surfaces span the full width; dialogs-of-a-page stay columned. */
	let wideChrome = false
	const screenTitle =
		load.data?.event_x?.title?.trim() || EVENT_REGISTRATION_TITLES[variant]

	if (paymentReturn) {
		// Before anything is fetched — the order is already charged.
		body = (
			<RegistrationOutcome
				kind="paid"
				copy={EVENT_REGISTRATION_OUTCOMES.paid}
				orderNumber={paymentReturn.orderNumber}
				isAuthenticated={isClientAuthenticated}
			/>
		)
		wideChrome = true
	} else if (checkoutCancelled) {
		body = (
			<RegistrationOutcome
				kind="cancelled"
				copy={EVENT_REGISTRATION_OUTCOMES.cancelled}
				isAuthenticated={isClientAuthenticated}
				extraAction={
					/* Full reload on purpose: a fresh load after the rollback is the
					   only state worth starting from. */
					<Button asChild variant="outline">
						<a href={location.pathname}>Start again</a>
					</Button>
				}
			/>
		)
		wideChrome = true
	} else if (submit.data?.kind === "registered") {
		body = (
			<RegistrationOutcome
				kind="registered"
				copy={{
					title: EVENT_REGISTRATION_OUTCOMES.registered.title,
					message:
						submit.data.result.message?.trim() ||
						EVENT_REGISTRATION_OUTCOMES.registered.message,
				}}
				orderNumber={submit.data.result.registrationNumber}
				isAuthenticated={isClientAuthenticated}
			/>
		)
		wideChrome = true
	} else if (declined) {
		body = (
			<RegistrationOutcome
				kind="registered"
				copy={EVENT_REGISTRATION_OUTCOMES.declined}
				isAuthenticated={isClientAuthenticated}
			/>
		)
		wideChrome = true
	} else if (
		load.isPending ||
		currentUser.isPending ||
		// Waited on only when there is a contact to load — a disabled query
		// sits pending forever, which would strand a guest on this skeleton.
		(hasContact && profile.isPending)
	) {
		body = <EventRegistrationSkeleton />
		withChrome = false
	} else if (load.isError) {
		body = (
			<RegistrationStatusPanel
				icon={ShieldAlert}
				tone="error"
				title="We couldn't open this registration"
				message="Please try again in a moment."
			/>
		)
		wideChrome = true
	} else {
		const screen = resolveEventScreen(load.data, { rsvpAccepted })

		if (screen === "notFound") {
			body = (
				<RegistrationStatusPanel
					icon={CalendarX2}
					title="We couldn't find that event"
					message={
						load.data.eligibility.message ??
						"It may have been removed, or the link may be out of date."
					}
				/>
			)
			wideChrome = true
		} else if (screen === "alreadyRegistered") {
			body = (
				<RegistrationStatusPanel
					icon={CalendarCheck2}
					tone="success"
					title={EVENT_REGISTRATION_OUTCOMES.alreadyRegistered.title}
					message={EVENT_REGISTRATION_OUTCOMES.alreadyRegistered.message}
				/>
			)
			wideChrome = true
		} else if (screen === "notEligible") {
			const offerSignIn =
				load.data.eligibility.signInWouldHelp && !isClientAuthenticated
			body = (
				<RegistrationStatusPanel
					icon={ShieldAlert}
					tone="notice"
					title="Registration isn't available"
					message={
						load.data.eligibility.message ??
						"This registration is not open to you at the moment."
					}
					action={
						offerSignIn ? (
							<Button asChild className="gap-2">
								<Link
									to={LOGIN_PATH}
									search={{ startUrl: getReturnPath(location) }}
								>
									<LogIn className="size-4" />
									Sign In
								</Link>
							</Button>
						) : undefined
					}
				/>
			)
			wideChrome = true
		} else if (screen === "rsvpGate" && load.data.event_x) {
			body = (
				<RsvpGate
					event={load.data.event_x}
					onAccept={() => setRsvpAccepted(true)}
					onDecline={handleDecline}
					declining={decline.isPending}
					declineError={
						decline.isError
							? errorMessage(
									decline.error,
									"We could not record your reply. Please try again.",
								)
							: null
					}
				/>
			)
		} else if (load.data.event_x) {
			body = (
				<EventRegistrationForm
					variant={variant}
					load={load.data}
					event={load.data.event_x}
					profile={profile.data ?? null}
					isClientAuthenticated={isClientAuthenticated}
					onNavigateBack={exit}
					submitting={submit.isPending}
					submitError={
						submit.isError
							? errorMessage(
									submit.error,
									"Registration failed. Please try again.",
								)
							: null
					}
					onSubmit={handleSubmit}
				/>
			)
			withChrome = false
		}
	}

	return (
		<animated.div
			style={transitionStyle}
			className={cn(REGISTRATION_SHELL, className)}
		>
			<div className={REGISTRATION_SCROLL}>
				{withChrome ? (
					<ScreenChrome
						title={screenTitle}
						showBack={isClientAuthenticated}
						onNavigateBack={exit}
						wide={wideChrome}
					>
						{body}
					</ScreenChrome>
				) : (
					body
				)}
			</div>
		</animated.div>
	)
}

export { EventRegistrationPanel }
