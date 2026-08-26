import { animated, useSpring } from "@react-spring/web"
import { Link } from "@tanstack/react-router"
import { CircleUser, Lock } from "lucide-react"

import type { MembershipView } from "@/api/membership/types"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import { GarpIdChip } from "@/components/molecules/garp-id-chip"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import {
	buildMembershipHeroPresentation,
	buildMembershipIdentityPresentation,
	lockedBenefitsNotice,
} from "@/lib/membership-presentation"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

/** The app's panel/detail-enter feel — same as `AccountIdentityHero`. */
const HERO_SPRING = { mass: 0.9, tension: 320, friction: 26 }

type MembershipHeroProps = {
	data: MembershipView
	className?: string
}

/**
 * Identity band above the benefits list — same visual grammar as the account
 * page's `AccountIdentityHero`, so the two "who am I" surfaces read as one
 * family: gradient band, large avatar, name, chip row, icon meta lines.
 *
 * The right zone is optional by design. It renders the Apex `hero` PortalCard
 * when an org supplies one, falls back to a compact locked-benefits callout
 * when benefits are gated, and otherwise disappears — the flex row simply
 * collapses, so there is never an empty column.
 */
function MembershipHero({ data, className }: MembershipHeroProps) {
	const { identity, hero, lockedCount } = data
	const photoUrl = resolvePortalAssetUrl(identity.photoUrl)
	const heroContent = buildMembershipHeroPresentation(hero)
	const me = buildMembershipIdentityPresentation(identity)
	const lockedNotice = lockedBenefitsNotice(lockedCount)
	const hasHeroCopy =
		Boolean(heroContent.eyebrow) ||
		Boolean(heroContent.badgeLabel) ||
		Boolean(heroContent.body) ||
		heroContent.bullets.length > 0 ||
		Boolean(heroContent.cta)

	const enter = useSpring({
		from: { opacity: 0, transform: "translateY(10px)" },
		to: { opacity: 1, transform: "translateY(0px)" },
		config: HERO_SPRING,
	})

	return (
		<animated.section
			style={enter}
			className={cn(
				"rounded-xl border border-border bg-linear-to-br from-surface-gradient-start to-surface-gradient-end p-5 sm:p-6",
				className,
			)}
			aria-label="Your membership"
		>
			<div className="flex flex-col gap-5 app:flex-row app:items-start app:gap-6">
				<Avatar className="size-22 shrink-0 app:size-28">
					<AvatarImage src={photoUrl} alt="" className="object-cover" />
					<AvatarFallback className="bg-transparent p-0 text-muted-foreground">
						<CircleUser
							className="size-full"
							strokeWidth={1.25}
							absoluteStrokeWidth
							aria-hidden
						/>
					</AvatarFallback>
				</Avatar>

				<div className="min-w-0 flex-1 space-y-2.5">
					<h2 className="font-heading text-2xl font-semibold tracking-wide break-words text-foreground sm:text-3xl">
						{identity.fullName ?? "Your membership"}
					</h2>

					<div className="flex flex-wrap items-center gap-2">
						{identity.garpId ? <GarpIdChip garpId={identity.garpId} /> : null}
						{identity.membershipType ? (
							<Badge className="bg-accent px-3 py-1 font-semibold tracking-wide text-accent-foreground">
								{identity.membershipType}
							</Badge>
						) : null}
						{me.statusLabel && me.statusTone ? (
							<StatusBadge label={me.statusLabel} tone={me.statusTone} />
						) : null}
						{me.expiryLabel && me.expiryTone ? (
							<StatusBadge label={me.expiryLabel} tone={me.expiryTone} />
						) : null}
						{me.autoRenewLabel ? (
							<Badge className="bg-success-green/15 px-3 py-1 font-semibold tracking-wide text-success-green">
								{me.autoRenewLabel}
							</Badge>
						) : null}
					</div>

					{/* Wrapping row rather than the default stack — same override as the
					    account hero, so the band stays shorter than the cards below. */}
					<MetaLines
						lines={me.metaLines}
						className="flex flex-wrap gap-x-5 gap-y-1 space-y-0"
					/>
				</div>

				{hasHeroCopy ? (
					<div className="w-full space-y-3 app:max-w-sm app:shrink-0">
						{heroContent.eyebrow || heroContent.badgeLabel ? (
							<div className="flex flex-wrap items-center gap-2">
								{heroContent.eyebrow ? (
									<span className="text-xs font-bold tracking-wider uppercase text-muted-foreground">
										{heroContent.eyebrow}
									</span>
								) : null}
								{heroContent.badgeLabel ? (
									<StatusBadge label={heroContent.badgeLabel} tone="info" />
								) : null}
							</div>
						) : null}

						{heroContent.body ? (
							<p className="text-sm text-muted-foreground">{heroContent.body}</p>
						) : null}

						{heroContent.bullets.length > 0 ? (
							<ul className="list-disc space-y-1 pl-5 text-sm text-muted-foreground">
								{heroContent.bullets.map((bullet) => (
									<li key={bullet}>{bullet}</li>
								))}
							</ul>
						) : null}

						{heroContent.cta ? (
							<Button asChild>
								{heroContent.cta.isExternal ? (
									<a
										href={heroContent.cta.url}
										{...(heroContent.cta.newWindow
											? {
													target: "_blank",
													rel: "noreferrer noopener",
												}
											: {})}
									>
										{heroContent.cta.label}
									</a>
								) : (
									<Link to={heroContent.cta.url}>{heroContent.cta.label}</Link>
								)}
							</Button>
						) : null}
					</div>
				) : lockedNotice ? (
					<div className="flex w-full items-start gap-3 rounded-lg border border-border bg-card/70 p-3 text-sm app:max-w-sm app:shrink-0">
						<Lock className="mt-0.5 size-4 shrink-0 text-primary" aria-hidden />
						<div className="min-w-0 space-y-0.5">
							<p className="font-heading font-semibold text-foreground">
								Members-only benefits
							</p>
							<p className="text-muted-foreground">{lockedNotice}</p>
						</div>
					</div>
				) : null}
			</div>
		</animated.section>
	)
}

export { MembershipHero }
