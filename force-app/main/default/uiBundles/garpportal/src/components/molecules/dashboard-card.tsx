import { BookOpen, CalendarDays, CircleUser, Users, X } from "lucide-react"

import {
	asDashboardCardMeta,
	type PortalCard,
} from "@/api/dashboard"
import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { MetaLines } from "@/components/molecules/meta-lines"
import { DashboardEnrolledList } from "@/components/molecules/dashboard-enrolled-list"
import { DashboardEventsList } from "@/components/molecules/dashboard-events-list"
import { DirectorySearch } from "@/components/molecules/directory-search"
import { ProfileCompletenessMeter } from "@/components/molecules/profile-completeness-meter"
import { StatusBadge } from "@/components/molecules/status-badge"
import { DASHBOARD_PROVIDER } from "@/lib/compose-dashboard-cards"
import { buildDashboardCardPresentation } from "@/lib/dashboard-card-presentation"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

type DashboardCardProps = {
	card: PortalCard
	onDismiss?: (key: string) => void
	className?: string
}

function ProviderIcon({
	provider,
}: {
	provider: PortalCard["provider"]
}) {
	const className = "size-5"
	switch (provider) {
		case DASHBOARD_PROVIDER.profile:
			return <CircleUser className={className} aria-hidden />
		case DASHBOARD_PROVIDER.directory:
			return <Users className={className} aria-hidden />
		case DASHBOARD_PROVIDER.enrolled:
			return <BookOpen className={className} aria-hidden />
		case DASHBOARD_PROVIDER.events:
			return <CalendarDays className={className} aria-hidden />
		default:
			return null
	}
}

function hasProviderIcon(provider: PortalCard["provider"]): boolean {
	return (
		provider === DASHBOARD_PROVIDER.profile ||
		provider === DASHBOARD_PROVIDER.directory ||
		provider === DASHBOARD_PROVIDER.enrolled ||
		provider === DASHBOARD_PROVIDER.events
	)
}

/**
 * One dashboard card. Provider chooses widgets; copy/CTA/order come from
 * Apex or client composition (`composeDashboardCards`).
 */
function DashboardCard({ card, onDismiss, className }: DashboardCardProps) {
	const isProfile = card.provider === DASHBOARD_PROVIDER.profile
	const isExam = card.provider === DASHBOARD_PROVIDER.exam
	const isDirectory = card.provider === DASHBOARD_PROVIDER.directory
	const isEnrolled = card.provider === DASHBOARD_PROVIDER.enrolled
	const isEvents = card.provider === DASHBOARD_PROVIDER.events
	const meta = asDashboardCardMeta(card.meta)
	const imageUrl = resolvePortalAssetUrl(card.imageUrl) ?? card.imageUrl
	const percent =
		typeof meta.percentComplete === "number"
			? meta.percentComplete
			: undefined
	const showProviderIcon = !imageUrl && hasProviderIcon(card.provider)
	const presentation = buildDashboardCardPresentation(card)

	return (
		<Card
			className={cn(
				"h-full gap-0 overflow-hidden border-border bg-muted/40 py-0 shadow-none",
				className,
			)}
		>
			{imageUrl ? (
				<div className="relative aspect-[16/9] overflow-hidden bg-muted">
					<img
						src={imageUrl}
						alt=""
						className="absolute inset-0 size-full object-cover"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
					<div
						className="pointer-events-none absolute inset-0 bg-gradient-to-t from-background/50 via-transparent to-transparent"
						aria-hidden
					/>
				</div>
			) : null}

			<CardHeader className="gap-3 px-5 pt-5 pb-2">
				<div className="flex items-start gap-3">
					{showProviderIcon ? (
						<span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-accent text-primary">
							<ProviderIcon provider={card.provider} />
						</span>
					) : null}
					<div className="min-w-0 flex-1">
						{card.eyebrow ? (
							<p className="mb-1 text-xs font-semibold tracking-wider text-primary uppercase">
								{card.eyebrow}
							</p>
						) : null}
						<div className="flex flex-wrap items-center gap-2">
							<CardTitle className="font-heading text-lg tracking-wide text-foreground">
								{card.title}
							</CardTitle>
							{presentation.badgeLabel && presentation.badgeTone ? (
								<StatusBadge
									label={presentation.badgeLabel}
									tone={presentation.badgeTone}
								/>
							) : null}
						</div>
					</div>
					{card.dismissible && onDismiss ? (
						<Button
							type="button"
							variant="ghost"
							size="icon-sm"
							aria-label="Dismiss this card"
							onClick={() => onDismiss(card.key)}
							className="-mr-1 -mt-1 rounded-full text-muted-foreground hover:text-foreground"
						>
							<X className="size-4" />
						</Button>
					) : null}
				</div>
			</CardHeader>

			<CardContent className="flex-1 space-y-3 px-5 pb-4">
				{isProfile && percent != null ? (
					<div className="rounded-xl border border-border/60 bg-background/50 p-3">
						<ProfileCompletenessMeter
							percent={percent}
							missing={meta.missing}
						/>
					</div>
				) : null}

				{card.body ? (
					<p className="text-sm text-muted-foreground">{card.body}</p>
				) : null}

				<MetaLines lines={presentation.metaLines} />

				{card.bullets && card.bullets.length > 0 ? (
					<ul className="list-disc space-y-1 pl-5 text-sm text-muted-foreground">
						{card.bullets.map((bullet) => (
							<li key={bullet}>{bullet}</li>
						))}
					</ul>
				) : null}

				{isEnrolled ? (
					(meta.enrolledPrograms ?? []).length > 0 ? (
						<DashboardEnrolledList programs={meta.enrolledPrograms ?? []} />
					) : (
						<p className="text-sm text-muted-foreground">
							Programs you enroll in will show up here.
						</p>
					)
				) : null}

				{isEvents ? (
					(meta.upcomingEvents ?? []).length > 0 ? (
						<div className="rounded-xl border border-border/60 bg-background/50 p-3">
							<DashboardEventsList events={meta.upcomingEvents ?? []} />
						</div>
					) : (
						<p className="text-sm text-muted-foreground">
							Events you register for will show up here.
						</p>
					)
				) : null}

				{isDirectory && meta.searchEnabled ? (
					<div className="rounded-xl border border-border/60 bg-background/50 p-3">
						<DirectorySearch className="min-h-40" />
					</div>
				) : null}
			</CardContent>

			<CardFooter className="mt-auto border-t border-border/60 bg-transparent px-5 py-4">
				<CardCta
					label={card.ctaLabel}
					url={card.ctaUrl}
					isExternal={card.ctaIsExternal}
					locked={card.locked}
					disabled={isExam}
				/>
			</CardFooter>
		</Card>
	)
}

export { DashboardCard }
