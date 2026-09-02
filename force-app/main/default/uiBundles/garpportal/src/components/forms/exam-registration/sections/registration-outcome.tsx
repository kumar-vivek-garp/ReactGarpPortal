import type { ReactNode } from "react"
import { CircleAlert, CircleCheck } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
import {
	EXAM_REGISTRATION_OUTCOMES,
	PUBLIC_REGISTRATION_EXIT,
} from "@/config/registration"
import { LOGIN_PATH } from "@/auth/constants"
import { formatMoney } from "@/lib/account-format"

export type RegistrationOutcomeKind = keyof typeof EXAM_REGISTRATION_OUTCOMES

type RegistrationOutcomeProps = {
	kind: RegistrationOutcomeKind
	/**
	 * Overrides the exam copy table — the event forms reuse this screen with
	 * their own wording while keeping the layout and button logic.
	 */
	copy?: { title: string; message: string }
	orderNumber?: string | null
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
	total,
	currency,
	isAuthenticated = true,
	extraAction,
	className,
}: RegistrationOutcomeProps) {
	const copy = copyOverride ?? EXAM_REGISTRATION_OUTCOMES[kind]
	const failed = kind === "cancelled"

	return (
		<RegistrationStatusPanel
			icon={failed ? CircleAlert : CircleCheck}
			tone={failed ? "error" : "success"}
			title={copy.title}
			message={copy.message}
			detail={
				orderNumber ? (
					<dl className="flex flex-col items-center gap-1 rounded-xl bg-muted px-6 py-4">
						<dt className="text-caption text-muted-foreground">Order</dt>
						<dd className="text-lg font-semibold tabular-nums">
							{orderNumber}
						</dd>
						{total != null ? (
							<dd className="text-body text-muted-foreground tabular-nums">
								{formatMoney(total, currency || "USD")}
							</dd>
						) : null}
					</dl>
				) : undefined
			}
			action={
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
			}
			className={className}
		/>
	)
}

export { RegistrationOutcome }
