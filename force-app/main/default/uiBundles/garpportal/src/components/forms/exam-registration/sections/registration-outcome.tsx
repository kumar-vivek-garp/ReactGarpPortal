import type { ReactNode } from "react"
import type { LucideIcon } from "lucide-react"
import { CircleAlert, CircleCheck, Clock } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
import {
	EXAM_REGISTRATION_OUTCOMES,
	PUBLIC_REGISTRATION_EXIT,
	type RegistrationOutcomeTone,
} from "@/config/registration"
import { LOGIN_PATH } from "@/auth/constants"
import { formatMoney } from "@/lib/account-format"
import { cn } from "@/lib/utils"

export type RegistrationOutcomeKind = keyof typeof EXAM_REGISTRATION_OUTCOMES

const ICONS: Record<RegistrationOutcomeTone, LucideIcon> = {
	success: CircleCheck,
	error: CircleAlert,
	notice: Clock,
	muted: CircleCheck,
}

/** The same tone colours `RegistrationStatusPanel` uses, for the compact header. */
const TONE_TEXT: Record<RegistrationOutcomeTone, string> = {
	muted: "text-muted-foreground",
	notice: "text-garp-saffron",
	error: "text-destructive",
	success: "text-success-green",
}

type RegistrationOutcomeProps = {
	kind: RegistrationOutcomeKind
	/**
	 * Overrides the exam copy table — the event forms reuse this screen with
	 * their own wording while keeping the layout and button logic. A tone may
	 * come with it; without one the kind's own tone applies.
	 */
	copy?: { title: string; message: string; tone?: RegistrationOutcomeTone }
	orderNumber?: string | null
	/** "Order" for an order number; "Reference" for a REG- number. */
	referenceLabel?: string
	total?: number | null
	currency?: string | null
	/**
	 * Whether this browser has a session — which decides where the buttons can
	 * point. Deliberately the client session rather than the load payload's
	 * `isAuthenticated`: the question here is "will this link resolve for this
	 * visitor", which is a routing question, not a server one.
	 */
	isAuthenticated?: boolean
	/** An extra button beside the standard pair — a cancelled checkout's
	 * "Start again". */
	extraAction?: ReactNode
	/**
	 * No way forward yet: a screen that is still confirming, or one carrying
	 * the survey (which has its own Skip and Submit). The standard pair comes
	 * back once the step is over.
	 */
	hideActions?: boolean
	/** Still waiting on the server — announced to assistive tech. */
	busy?: boolean
	/** Content between the facts and the actions — the survey's slot. */
	children?: ReactNode
	className?: string
}

/**
 * What happened, once the form is done.
 *
 * Replaces the form rather than sitting above it — leaving a filled-in
 * registration on screen behind a success message invites someone to submit it
 * again.
 *
 * Rendered on the shared full-width status surface: this screen IS the page,
 * the same way a refusal or a not-found is, so it fills the slot the form
 * would have taken rather than floating as a small centred card.
 *
 * The order number is given prominence because it is the one thing a candidate
 * needs if anything goes wrong afterwards, and the one thing they will be
 * asked for.
 */
function RegistrationOutcome({
	kind,
	copy: copyOverride,
	orderNumber,
	referenceLabel = "Order",
	total,
	currency,
	isAuthenticated = true,
	extraAction,
	hideActions = false,
	busy = false,
	children,
	className,
}: RegistrationOutcomeProps) {
	const copy = copyOverride ?? EXAM_REGISTRATION_OUTCOMES[kind]
	const tone = copyOverride?.tone ?? EXAM_REGISTRATION_OUTCOMES[kind].tone
	const Icon = ICONS[tone]

	const reference = orderNumber ? (
		<dl className="flex flex-col items-center gap-1 rounded-xl bg-muted px-6 py-4">
			<dt className="text-caption text-muted-foreground">{referenceLabel}</dt>
			<dd className="text-lg font-semibold tabular-nums">{orderNumber}</dd>
			{total != null ? (
				<dd className="text-body text-muted-foreground tabular-nums">
					{formatMoney(total, currency || "USD")}
				</dd>
			) : null}
		</dl>
	) : null

	const actions = hideActions ? null : (
		/*
		 * A guest has neither of these pages — both are behind the session
		 * guard, so offering them would end a successful registration by
		 * bouncing the candidate to a login wall. They are sent back to the
		 * public site, and invited to sign in to the account this
		 * registration has just created for them.
		 */
		<div className="flex flex-wrap items-center justify-center gap-3">
			{isAuthenticated ? (
				<>
					<Button asChild variant="outline">
						<Link to="/programs">Back to programmes</Link>
					</Button>
					<Button asChild>
						<Link to="/dashboard">Go to dashboard</Link>
					</Button>
				</>
			) : (
				<>
					<Button asChild variant="outline">
						<a href={PUBLIC_REGISTRATION_EXIT.href}>
							Back to {PUBLIC_REGISTRATION_EXIT.label}
						</a>
					</Button>
					<Button asChild>
						<Link to={LOGIN_PATH}>Sign in</Link>
					</Button>
				</>
			)}
			{extraAction}
		</div>
	)

	/*
	 * With content to carry (the survey), the screen is a PAGE, not a
	 * statement: a compact confirmation header — icon, title, one line, the
	 * reference beside it — and the content below at a readable width. The
	 * centred full-height panel is for the outcome that ends the journey.
	 */
	if (children) {
		return (
			<div className={cn("flex flex-col gap-6", className)}>
				<Card
					className="mx-auto flex w-full max-w-3xl flex-col gap-3 bg-linear-to-br from-surface-gradient-start to-surface-gradient-end px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
					aria-live="polite"
					aria-busy={busy || undefined}
				>
					<div className="flex items-center gap-3">
						<Icon className={cn("size-7 shrink-0", TONE_TEXT[tone])} aria-hidden />
						<div className="flex flex-col">
							<h2 className="font-heading text-xl font-semibold tracking-wide text-heading">
								{copy.title}
							</h2>
							<p className="text-caption leading-relaxed text-muted-foreground">
								{copy.message}
							</p>
						</div>
					</div>
					{orderNumber ? (
						<dl className="flex shrink-0 items-baseline gap-2 rounded-lg bg-muted px-3 py-1.5">
							<dt className="text-caption text-muted-foreground">{referenceLabel}</dt>
							<dd className="text-sm font-semibold tabular-nums">{orderNumber}</dd>
						</dl>
					) : null}
				</Card>
				<div className="mx-auto w-full max-w-3xl">{children}</div>
				{actions ? <div className="mx-auto w-full max-w-3xl">{actions}</div> : null}
			</div>
		)
	}

	return (
		<RegistrationStatusPanel
			icon={Icon}
			tone={tone}
			title={copy.title}
			message={copy.message}
			detail={
				<div
					className="flex w-full flex-col items-center gap-6"
					aria-busy={busy || undefined}
					aria-live="polite"
				>
					{reference}
				</div>
			}
			action={actions}
			className={className}
		/>
	)
}

export { RegistrationOutcome }
