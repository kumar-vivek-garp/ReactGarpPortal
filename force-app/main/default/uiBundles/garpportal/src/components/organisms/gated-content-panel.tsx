import { useState } from "react"
import { Link } from "@tanstack/react-router"
import { ArrowRight, CheckCircle2, ExternalLink } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import {
	GATED_COOKIE_DOMAIN,
	GATED_CONTENT_COPY,
	GATED_CONTENT_TITLE,
	GATED_URL_COOKIE,
} from "@/config/gated-content"
import { useMembership } from "@/hooks/use-membership"
import { clearCookie } from "@/lib/cookies"
import { gatedUpsellHref, readGatedUrl } from "@/lib/gated-content"
import { cn } from "@/lib/utils"

function ExpiredLink() {
	const copy = GATED_CONTENT_COPY.expired
	const Icon = copy.icon
	return (
		<div className="space-y-4">
			<div className="flex items-start gap-3">
				<Icon className="mt-0.5 size-5 shrink-0 text-muted-foreground" aria-hidden />
				<div className="space-y-1">
					<p className="font-heading text-lg font-semibold tracking-wide text-foreground">
						{copy.title}
					</p>
					<p className="text-sm text-muted-foreground">{copy.body}</p>
				</div>
			</div>
			<Button asChild variant="outline">
				<a href={copy.href}>
					{copy.cta}
					<ExternalLink className="size-4" aria-hidden />
				</a>
			</Button>
		</div>
	)
}

type GatedContentPanelProps = { className?: string }

/**
 * The members-only content paywall.
 *
 * A route rather than the legacy's app-shell hijack, which suppressed the nav
 * and the router outlet whenever the cookie was present — making the state
 * unlinkable, unrefreshable, and something any page could silently become.
 *
 * **No automatic redirect.** The legacy forwards after exactly two seconds and
 * GarpAppv1 reproduces it; here the member clicks. A page that navigates itself
 * is hostile to anyone reading slowly or using a screen reader, and the link is
 * right there.
 *
 * The destination is validated before use — see `isAllowedGatedUrl`. Without
 * that this is an open redirect, at the one moment a member is expecting to be
 * sent somewhere.
 */
function GatedContentPanel({ className }: GatedContentPanelProps) {
	/*
	 * Read once. The cookie is cleared the moment it is used, so re-reading
	 * after a click would make a successful hand-off look like an expired link.
	 */
	const [gatedUrl] = useState(readGatedUrl)
	const { data, isLoading, isError } = useMembership()

	const identity = data?.identity
	const allowed = identity?.isMemberInGoodStanding === true

	const goToContent = () => {
		if (!gatedUrl) return
		clearCookie(GATED_URL_COOKIE, GATED_COOKIE_DOMAIN)
		window.location.href = gatedUrl
	}

	return (
		<div className={cn("max-w-2xl space-y-6", className)}>
			<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
				{GATED_CONTENT_TITLE}
			</h1>

			{isLoading ? (
				<div className="space-y-3" aria-busy>
					<Skeleton className="h-5 w-3/4" />
					<Skeleton className="h-10 w-52 rounded-xl" />
				</div>
			) : null}

			{/*
			 * A membership read that fails tells us nothing about standing, and
			 * guessing would either strand a member or let a lapsed one through.
			 * The expired-link state is the honest answer: they can go back and
			 * try again.
			 */}
			{!isLoading && (isError || !identity) ? <ExpiredLink /> : null}

			{!isLoading && !isError && identity ? (
				!gatedUrl ? (
					<ExpiredLink />
				) : allowed ? (
					<div className="space-y-4">
						<p className="flex items-start gap-3 text-sm text-foreground">
							<CheckCircle2
								className="mt-0.5 size-5 shrink-0 text-success-green"
								aria-hidden
							/>
							{GATED_CONTENT_COPY.allowed.body}
						</p>
						<Button type="button" onClick={goToContent}>
							{GATED_CONTENT_COPY.allowed.cta}
							<ArrowRight className="size-4" aria-hidden />
						</Button>
					</div>
				) : (
					<div className="space-y-4">
						<p className="text-sm text-foreground">
							{GATED_CONTENT_COPY.refused.body} Check your status on{" "}
							<Link
								to="/my-account"
								search={{ tab: "account-information" }}
								className="font-semibold text-primary hover:underline"
							>
								My Account
							</Link>
							, or {identity.isIndividualMember ? "renew" : "upgrade"} below.
						</p>
						<Button asChild>
							{/* The article travels with them, so checkout can return
							    them to what they were after. */}
							<a href={gatedUpsellHref(gatedUrl)}>
								{identity.isIndividualMember
									? GATED_CONTENT_COPY.refused.renew
									: GATED_CONTENT_COPY.refused.upgrade}
							</a>
						</Button>
					</div>
				)
			) : null}
		</div>
	)
}

export { GatedContentPanel }
