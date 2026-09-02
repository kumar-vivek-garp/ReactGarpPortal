import { CircleCheck } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
import { LOGIN_PATH } from "@/auth/constants"
import {
	AFFILIATE_REGISTRATION_OUTCOME,
	PUBLIC_REGISTRATION_EXIT,
} from "@/config/registration"

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
 * Shaped to match `exam-registration/sections/registration-outcome` rather
 * than sharing it: that one is keyed by `EXAM_REGISTRATION_OUTCOMES` and
 * carries an order number and a total, none of which a free membership has.
 * Both render on the shared full-width status surface.
 */
function AffiliateOutcome({ className }: { className?: string }) {
	return (
		<RegistrationStatusPanel
			icon={CircleCheck}
			tone="success"
			title={AFFILIATE_REGISTRATION_OUTCOME.title}
			message={AFFILIATE_REGISTRATION_OUTCOME.message}
			action={
				<div className="flex flex-wrap items-center justify-center gap-3">
					<Button asChild variant="outline">
						<a href={PUBLIC_REGISTRATION_EXIT.href}>
							Back to {PUBLIC_REGISTRATION_EXIT.label}
						</a>
					</Button>
					<Button asChild>
						<Link to={LOGIN_PATH}>Sign in</Link>
					</Button>
				</div>
			}
			className={className}
		/>
	)
}

export { AffiliateOutcome }
