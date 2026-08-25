import { CircleCheck } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { Card, CardContent } from "@/components/atoms/card"
import { LOGIN_PATH } from "@/auth/constants"
import {
	AFFILIATE_REGISTRATION_OUTCOME,
	PUBLIC_REGISTRATION_EXIT,
} from "@/config/registration"
import { cn } from "@/lib/utils"

/**
 * What happened, once the membership exists.
 *
 * Replaces the form rather than sitting above it — leaving a filled-in
 * registration on screen behind a success message invites a second submit, and
 * the second one comes back `mustSignIn` because the first one just created the
 * account.
 *
 * Both destinations are outside the session guard for a reason: this page is
 * only ever reached by someone who did not have an account a moment ago, so
 * `/dashboard` and `/programs` would bounce them straight to Login. Signing in
 * is offered instead, because the account they need for it now exists.
 *
 * Shaped to match `frm/sections/registration-outcome` rather than sharing it:
 * that one is keyed by `EXAM_REGISTRATION_OUTCOMES` and carries an order number
 * and a total, none of which a free membership has.
 */
function AffiliateOutcome({ className }: { className?: string }) {
	return (
		<Card className={cn("mx-auto w-full max-w-2xl", className)}>
			<CardContent className="flex flex-col items-center gap-4 px-6 py-12 text-center">
				<CircleCheck className="size-10 text-success-green" aria-hidden />
				<h2 className="font-heading text-2xl font-semibold">
					{AFFILIATE_REGISTRATION_OUTCOME.title}
				</h2>
				<p className="max-w-md text-body text-muted-foreground">
					{AFFILIATE_REGISTRATION_OUTCOME.message}
				</p>

				<div className="mt-2 flex flex-wrap items-center justify-center gap-3">
					<Button asChild variant="outline">
						<a href={PUBLIC_REGISTRATION_EXIT.href}>
							Back to {PUBLIC_REGISTRATION_EXIT.label}
						</a>
					</Button>
					<Button asChild>
						<Link to={LOGIN_PATH}>Sign in</Link>
					</Button>
				</div>
			</CardContent>
		</Card>
	)
}

export { AffiliateOutcome }
