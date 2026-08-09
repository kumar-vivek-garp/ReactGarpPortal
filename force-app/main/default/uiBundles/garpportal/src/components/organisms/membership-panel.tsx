import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import { CircleUser } from "lucide-react"

import type { MembershipView } from "@/api/membership/types"
import { Button } from "@/components/atoms/button"
import { Card, CardContent } from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs, TabsList, TabsTrigger } from "@/components/atoms/tabs"
import { BenefitCard } from "@/components/molecules/benefit-card"
import { DirectorySearch } from "@/components/molecules/directory-search"
import type { MembershipTab } from "@/config/membership"
import { useMembership } from "@/hooks/use-membership"
import { formatLongDate } from "@/lib/account-format"
import { cn } from "@/lib/utils"

const TAB_SPRING = { mass: 0.9, tension: 320, friction: 26 }

const TAB_ITEMS: Array<{ value: MembershipTab; label: string }> = [
	{ value: "benefits", label: "Member Benefits" },
	{ value: "directory", label: "Member Directory" },
]

const pillTriggerClassName = cn(
	"h-auto flex-none shrink-0 cursor-pointer rounded-full border-0 px-5 py-2 text-sm font-semibold shadow-none",
	"bg-muted text-foreground hover:bg-muted/80 hover:text-foreground",
	"data-[state=active]:bg-deep-purple data-[state=active]:text-deep-purple-foreground",
	"data-[state=active]:hover:bg-deep-purple data-[state=active]:hover:text-deep-purple-foreground",
	"after:hidden",
)

type MembershipPanelProps = {
	tab: MembershipTab
}

function MembershipBenefitsSkeleton() {
	return (
		<div className="space-y-8" aria-busy aria-label="Loading membership benefits">
			<Skeleton className="h-36 w-full rounded-xl" />
			<div className="space-y-4">
				<Skeleton className="h-7 w-48 rounded-sm" />
				<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
					{[0, 1, 2, 3].map((key) => (
						<Skeleton key={key} className="h-[28rem] w-full rounded-xl" />
					))}
				</div>
			</div>
		</div>
	)
}

function MembershipHero({ data }: { data: MembershipView }) {
	const { identity, hero, lockedCount } = data
	const expiry = formatLongDate(identity.membershipExpiration)

	return (
		<Card className="border-border shadow-none">
			<CardContent className="grid gap-6 py-2 md:grid-cols-[minmax(0,18rem)_1fr]">
				<div className="flex items-start gap-3">
					<span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-muted text-muted-foreground">
						<CircleUser className="size-6" />
					</span>
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
						<div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
							{section.benefits.map((benefit) => (
								<BenefitCard key={benefit.id} benefit={benefit} />
							))}
						</div>
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
		return (
			<div
				className="flex min-h-0 flex-1 flex-col gap-3"
				aria-busy
				aria-label="Loading member directory"
			>
				<Skeleton className="h-10 w-full rounded-md" />
				<Skeleton className="h-40 w-full rounded-md" />
			</div>
		)
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

	const tabTransitions = useTransition(tab, {
		from: { opacity: 0, transform: "translateY(10px)" },
		enter: { opacity: 1, transform: "translateY(0px)" },
		leave: { opacity: 0, transform: "translateY(-8px)" },
		config: TAB_SPRING,
		exitBeforeEnter: true,
	})

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
