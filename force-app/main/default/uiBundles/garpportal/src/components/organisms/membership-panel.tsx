import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { CircleUser } from "lucide-react"

import type { MembershipView } from "@/api/membership/types"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Button } from "@/components/atoms/button"
import { Card, CardContent } from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs, TabsList, TabsTrigger } from "@/components/atoms/tabs"
import { BenefitCard } from "@/components/molecules/benefit-card"
import { DirectorySearch } from "@/components/molecules/directory-search"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import type { MembershipTab } from "@/config/membership"
import { useMembership } from "@/hooks/use-membership"
import { formatLongDate } from "@/lib/account-format"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

const TAB_ITEMS: Array<{ value: MembershipTab; label: string }> = [
	{ value: "benefits", label: "Member Benefits" },
	{ value: "directory", label: "Member Directory" },
]

const pillTriggerClassName = cn(
	"h-auto flex-none shrink-0 cursor-pointer rounded-xl border-0 px-5 py-2 text-sm font-semibold shadow-none",
	"bg-muted text-foreground hover:bg-muted/80 hover:text-foreground",
	"data-[state=active]:bg-deep-purple data-[state=active]:text-deep-purple-foreground",
	"data-[state=active]:hover:bg-deep-purple data-[state=active]:hover:text-deep-purple-foreground",
	"after:hidden",
)

type MembershipPanelProps = {
	tab: MembershipTab
}

function MembershipHeroSkeleton() {
	return (
		<Skeleton className="rounded-xl border border-border px-6 py-6">
			<div className="grid gap-6 md:grid-cols-[minmax(0,18rem)_1fr]">
				<div className="flex items-start gap-3">
					<Skeleton className="size-14 shrink-0 rounded-full" />
					<div className="min-w-0 flex-1 space-y-2">
						<Skeleton className="h-4 w-40" />
						<Skeleton className="h-3.5 w-36" />
						<Skeleton className="h-3.5 w-44" />
						<Skeleton className="h-3.5 w-48" />
					</div>
				</div>
				<div className="space-y-3">
					<Skeleton className="h-3.5 w-full" />
					<Skeleton className="h-3.5 w-5/6" />
					<Skeleton className="h-3.5 w-4/5" />
					<Skeleton className="h-9 w-44 rounded-xl" />
				</div>
			</div>
		</Skeleton>
	)
}

function BenefitCardSkeleton({ withImage = true }: { withImage?: boolean }) {
	return (
		<Skeleton className="flex h-[28rem] flex-col overflow-hidden rounded-xl border border-border">
			{withImage ? (
				<Skeleton className="h-32 w-full shrink-0 rounded-none" />
			) : null}
			<div className="shrink-0 space-y-2 px-5 pt-4 pb-2">
				<Skeleton className="h-4 w-3/5" />
			</div>
			<div className="min-h-0 flex-1 space-y-2 overflow-hidden px-5">
				<Skeleton className="h-3 w-full" />
				<Skeleton className="h-3 w-full" />
				<Skeleton className="h-3 w-4/5" />
				<Skeleton className="h-3 w-2/3" />
			</div>
			<div className="mt-auto shrink-0 border-t border-border/60 px-5 py-4">
				<Skeleton className="h-5 w-32" />
			</div>
		</Skeleton>
	)
}

function MembershipBenefitsSkeleton() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading membership benefits">
			<MembershipHeroSkeleton />
			<section className="space-y-4">
				<Skeleton className="h-6 w-48" />
				<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
					{[0, 1, 2, 3].map((key) => (
						<BenefitCardSkeleton key={key} withImage={key !== 1} />
					))}
				</div>
			</section>
		</div>
	)
}

function MembershipDirectorySkeleton() {
	return (
		<div
			className="flex min-h-0 flex-1 flex-col gap-3"
			aria-busy
			aria-label="Loading member directory"
		>
			<Skeleton className="h-3.5 w-full max-w-xl" />
			<Skeleton className="h-10 w-full rounded-xl" />
			<div className="space-y-2 pt-2">
				{[0, 1, 2].map((key) => (
					<Skeleton
						key={key}
						className="rounded-xl border border-border bg-muted/20 px-4 py-3"
					>
						<Skeleton className="h-4 w-48" />
						<Skeleton className="mt-2 h-3 w-72 max-w-full" />
					</Skeleton>
				))}
			</div>
		</div>
	)
}

function MembershipHero({ data }: { data: MembershipView }) {
	const { identity, hero, lockedCount } = data
	const expiry = formatLongDate(identity.membershipExpiration)
	const photoUrl = resolvePortalAssetUrl(identity.photoUrl)

	return (
		<Card className="border-border shadow-none">
			<CardContent className="grid gap-6 py-2 md:grid-cols-[minmax(0,18rem)_1fr]">
				<div className="flex items-start gap-3">
					<Avatar className="size-14 shrink-0 self-start overflow-hidden rounded-full">
						<AvatarImage
							src={photoUrl}
							alt={identity.fullName ?? ""}
							className="size-full object-cover"
						/>
						<AvatarFallback className="bg-muted text-muted-foreground">
							<CircleUser className="size-8" aria-hidden />
						</AvatarFallback>
					</Avatar>
					<div className="text-sm">
						<p className="font-semibold uppercase text-foreground">
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
						<p className="text-muted-foreground">
							<span className="font-semibold text-foreground">Member Status:</span>{" "}
							{identity.membershipStatus ?? "—"}
							{expiry ? ` (until ${expiry})` : null}
						</p>
					</div>
				</div>

				<div className="space-y-3">
					{hero?.body ? (
						<p className="text-sm text-muted-foreground">{hero.body}</p>
					) : null}
					{hero?.ctaLabel && hero.ctaUrl ? (
						<Button asChild>
							{hero.ctaIsExternal ? (
								<a href={hero.ctaUrl} target="_blank" rel="noreferrer noopener">
									{hero.ctaLabel}
								</a>
							) : (
								<Link to={hero.ctaUrl}>{hero.ctaLabel}</Link>
							)}
						</Button>
					) : null}
					{lockedCount > 0 ? (
						<p className="text-xs text-muted-foreground">
							{lockedCount} of the benefits below unlock with Individual Membership.
						</p>
					) : null}
				</div>
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
						<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
							{section.name}
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

				<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
					<TabsList className="h-auto w-max gap-3 bg-transparent p-0">
						{TAB_ITEMS.map((item) => (
							<TabsTrigger
								key={item.value}
								value={item.value}
								className={pillTriggerClassName}
							>
								{item.label}
							</TabsTrigger>
						))}
					</TabsList>
				</div>
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
								isLoading={isLoading}
								isError={isError}
							/>
						) : null}
						{currentTab === "directory" ? (
							<DirectoryTabBody data={data} isLoading={isLoading} />
						) : null}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export { MembershipPanel }
