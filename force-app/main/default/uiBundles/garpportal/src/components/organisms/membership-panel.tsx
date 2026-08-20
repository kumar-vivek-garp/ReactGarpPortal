import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { BadgeCheck, CircleUser } from "lucide-react"

import type { MembershipView } from "@/api/membership/types"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Button } from "@/components/atoms/button"
import { Card, CardContent } from "@/components/atoms/card"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { BenefitCard } from "@/components/molecules/benefit-card"
import { DirectorySearch } from "@/components/molecules/directory-search"
import {
	MembershipBenefitsSkeleton,
	MembershipDirectorySkeleton,
	MembershipPendingShell,
} from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { StatusBadge } from "@/components/molecules/status-badge"
import { MEMBERSHIP_TAB_ITEMS, type MembershipTab } from "@/config/membership"
import { useMembership } from "@/hooks/use-membership"
import {
	buildMembershipHeroPresentation,
	buildMembershipIdentityPresentation,
	lockedBenefitsNotice,
} from "@/lib/membership-presentation"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

type MembershipPanelProps = {
	tab: MembershipTab
}

function MembershipHero({ data }: { data: MembershipView }) {
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
	const memberMeta = [me.memberSinceLabel, me.autoRenewLabel]
		.filter(Boolean)
		.join(" - ")

	return (
		<Card className="gap-0 bg-muted/40 py-5 shadow-none">
			<CardContent className="grid items-center gap-6 md:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]">
				<div className="flex items-start gap-4">
					<Avatar className="size-14 shrink-0 overflow-hidden rounded-full">
						<AvatarImage
							src={photoUrl}
							alt={identity.fullName ?? ""}
							className="size-full object-cover"
						/>
						<AvatarFallback className="bg-transparent p-0 text-muted-foreground">
							<CircleUser
								className="size-14"
								strokeWidth={1.25}
								absoluteStrokeWidth
								aria-hidden
							/>
						</AvatarFallback>
					</Avatar>
					<div className="min-w-0 text-sm">
						<p className="font-heading text-base font-semibold tracking-wide text-foreground">
							{identity.fullName ?? "—"}
						</p>
						<p className="mt-1 text-muted-foreground">
							<span className="font-semibold text-foreground">GARP ID:</span>{" "}
							{identity.garpId ?? "—"}
						</p>
						<p className="text-muted-foreground">
							<span className="font-semibold text-foreground">Member Type:</span>{" "}
							{identity.membershipType ?? "—"}
						</p>
						<div className="mt-2 flex flex-wrap items-center gap-2">
							{me.statusLabel && me.statusTone ? (
								<StatusBadge label={me.statusLabel} tone={me.statusTone} />
							) : null}
							{me.expiryLabel ? (
								me.expiryTone ? (
									<StatusBadge label={me.expiryLabel} tone={me.expiryTone} />
								) : (
									<span className="text-muted-foreground">{me.expiryLabel}</span>
								)
							) : null}
						</div>
						{memberMeta ? (
							<p className="mt-1 text-xs text-muted-foreground">{memberMeta}</p>
						) : null}
					</div>
				</div>

				{hasHeroCopy || lockedNotice ? (
					<div className="space-y-3 md:justify-self-end md:text-right">
						{hasHeroCopy ? (
							<>
								{heroContent.eyebrow || heroContent.badgeLabel ? (
									<div className="flex flex-wrap items-center gap-2 md:justify-end">
										{heroContent.eyebrow ? (
											<span className="text-xs font-bold tracking-wider uppercase text-muted-foreground">
												{heroContent.eyebrow}
											</span>
										) : null}
										{heroContent.badgeLabel ? (
											<StatusBadge
												label={heroContent.badgeLabel}
												tone="info"
											/>
										) : null}
									</div>
								) : null}

								{heroContent.body ? (
									<p className="text-sm text-muted-foreground">
										{heroContent.body}
									</p>
								) : null}

								{heroContent.bullets.length > 0 ? (
									<ul className="list-disc space-y-1 pl-5 text-left text-sm text-muted-foreground md:ml-auto md:inline-block">
										{heroContent.bullets.map((bullet) => (
											<li key={bullet}>{bullet}</li>
										))}
									</ul>
								) : null}

								{heroContent.cta ? (
									<Button asChild className="md:ml-auto">
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
											<Link to={heroContent.cta.url}>
												{heroContent.cta.label}
											</Link>
										)}
									</Button>
								) : null}
							</>
						) : null}

						{lockedNotice ? (
							<p className="text-sm text-muted-foreground">{lockedNotice}</p>
						) : null}
					</div>
				) : null}
			</CardContent>
		</Card>
	)
}

function BenefitsTabBody({
	data,
	isLoading,
	isError,
}: {
	data: MembershipView | undefined
	isLoading: boolean
	isError: boolean
}) {
	if (isLoading) {
		return <MembershipBenefitsSkeleton />
	}

	if (isError || !data) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your membership benefits. Please try again later.
			</p>
		)
	}

	const { sections } = data

	return (
		<div className="space-y-8">
			<MembershipHero data={data} />

			{sections.length === 0 ? (
				<p className="text-sm text-muted-foreground">No benefits are published yet.</p>
			) : (
				sections.map((section) => (
					<section key={section.name} className="space-y-4">
						{/*
						 * Section names come from Apex and are dynamic, so one shared
						 * icon rather than a per-name map — it carries the same visual
						 * rhythm as the Programs / Study Materials / Events headings
						 * without pretending to classify a name we have not seen.
						 */}
						<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
							<BadgeCheck className="size-5 shrink-0 text-primary" aria-hidden />
							{section.name}
							<span className="text-base font-normal text-muted-foreground">
								({section.benefits.length})
							</span>
						</h2>
						<StaggerReveal
							className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
							itemClassName="h-full"
						>
							{section.benefits.map((benefit) => (
								<BenefitCard key={benefit.id} benefit={benefit} />
							))}
						</StaggerReveal>
					</section>
				))
			)}
		</div>
	)
}

function DirectoryTabBody({
	data,
	isLoading,
}: {
	data: MembershipView | undefined
	isLoading: boolean
}) {
	if (isLoading) {
		return <MembershipDirectorySkeleton />
	}

	const identity = data?.identity
	const showAccessNote = Boolean(identity && !identity.isIndividualMember)

	return (
		<div className="flex min-h-0 flex-1 flex-col gap-3">
			<p className="shrink-0 text-sm text-muted-foreground">
				Find and connect with opted-in members of the global risk community.
			</p>

			{showAccessNote ? (
				<p className="shrink-0 rounded-md border border-border bg-muted/40 px-3 py-2 text-xs text-muted-foreground">
					Full directory access is an Individual Membership benefit. You can still
					search; results are limited to members who opted in.
				</p>
			) : null}

			<DirectorySearch />
		</div>
	)
}

function MembershipPanel({ tab }: MembershipPanelProps) {
	const navigate = useNavigate({ from: "/membership/" })
	const { data, isLoading, isError } = useMembership()

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	if (isLoading) {
		return <MembershipPendingShell tab={tab} />
	}

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: { tab: value as MembershipTab },
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Membership Benefits
				</h1>

				<PillTabs items={MEMBERSHIP_TAB_ITEMS} value={tab} />
			</header>

			<div className="mt-6 flex min-h-0 flex-1 flex-col overflow-hidden">
				{tabTransitions((style, currentTab) => (
					<animated.div
						key={currentTab}
						role="tabpanel"
						style={style}
						className={cn(
							"flex min-h-0 flex-1 flex-col",
							currentTab === "benefits" &&
								"overflow-y-auto overscroll-contain pb-2 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
							currentTab === "directory" && "overflow-hidden pb-2",
						)}
					>
						{currentTab === "benefits" ? (
							<BenefitsTabBody
								data={data}
								isLoading={false}
								isError={isError}
							/>
						) : null}
						{currentTab === "directory" ? (
							<DirectoryTabBody data={data} isLoading={false} />
						) : null}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export { MembershipPanel }
