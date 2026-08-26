import { CircleAlert, CircleCheck } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { Card, CardContent } from "@/components/atoms/card"
import {
	EXAM_REGISTRATION_OUTCOMES,
	PUBLIC_REGISTRATION_EXIT,
} from "@/config/registration"
import { LOGIN_PATH } from "@/auth/constants"
import { formatMoney } from "@/lib/account-format"
import { cn } from "@/lib/utils"

export type RegistrationOutcomeKind = keyof typeof EXAM_REGISTRATION_OUTCOMES

type RegistrationOutcomeProps = {
	kind: RegistrationOutcomeKind
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
	className?: string
}

/**
 * What happened, once the form is done.
 *
 * Replaces the form rather than sitting above it — leaving a filled-in
 * registration on screen behind a success message invites someone to submit it
 * again.
 *
 * The order number is given prominence because it is the one thing a candidate
 * needs if anything goes wrong afterwards, and the one thing they will be
 * asked for.
 */
function RegistrationOutcome({
	kind,
	orderNumber,
	total,
	currency,
	isAuthenticated = true,
	className,
}: RegistrationOutcomeProps) {
	const copy = EXAM_REGISTRATION_OUTCOMES[kind]
	const failed = kind === "cancelled"
	const Icon = failed ? CircleAlert : CircleCheck

	return (
		<Card className={cn("mx-auto w-full max-w-2xl", className)}>
			<CardContent className="flex flex-col items-center gap-4 px-6 py-12 text-center">
				<Icon
					className={cn(
						"size-10",
						failed ? "text-destructive" : "text-success-green",
					)}
					aria-hidden
				/>
				<h2 className="font-heading text-2xl font-semibold">{copy.title}</h2>
				<p className="max-w-md text-body text-muted-foreground">
					{copy.message}
				</p>

				{orderNumber ? (
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
				) : null}

				{/*
				 * A guest has neither of these pages — both are behind the session
				 * guard, so offering them would end a successful registration by
				 * bouncing the candidate to a login wall. They are sent back to the
				 * public site, and invited to sign in to the account this
				 * registration has just created for them.
				 */}
				<div className="mt-2 flex flex-wrap items-center justify-center gap-3">
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
				</div>
			</CardContent>
		</Card>
	)
}

export { RegistrationOutcome }
