import type { ReactNode } from "react"
import { animated, useTransition } from "@react-spring/web"
import { Link, useNavigate } from "@tanstack/react-router"
import {
	CalendarCheck,
	CalendarDays,
	ExternalLink,
	MapPin,
	Sparkles,
	Users,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"

import type { MemberEvent } from "@/api/events"
import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs, TabsList, TabsTrigger } from "@/components/atoms/tabs"
import { EventCard } from "@/components/molecules/event-card"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { SEE_ALL_EVENTS_URL, type EventsTab } from "@/config/events"
import { useEvents } from "@/hooks/use-events"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

const pillTriggerClassName = cn(
	"h-auto flex-none shrink-0 cursor-pointer items-center gap-1.5 rounded-xl border-0 px-5 py-2 text-sm font-semibold shadow-none",
	"bg-muted text-foreground hover:bg-muted/80 hover:text-foreground",
	"data-[state=active]:bg-deep-purple data-[state=active]:text-deep-purple-foreground",
	"data-[state=active]:hover:bg-deep-purple data-[state=active]:hover:text-deep-purple-foreground",
	"after:hidden",
)

const TAB_ITEMS: Array<{ value: EventsTab; label: string; icon: LucideIcon }> =
	[
		{ value: "all", label: "All", icon: CalendarDays },
		{ value: "attending", label: "Attending", icon: CalendarCheck },
		{ value: "chapter-meetings", label: "Chapter Meetings", icon: Users },
		{ value: "featured", label: "Featured Events", icon: Sparkles },
	]

type EventsPanelProps = {
	tab: EventsTab
}

function SeeAllEventsButton({ className }: { className?: string }) {
	return (
		<Button asChild size="sm" className={className}>
			<a
				href={SEE_ALL_EVENTS_URL}
				target="_blank"
				rel="noreferrer noopener"
			>
				See all events
				<ExternalLink />
			</a>
		</Button>
	)
}

function SetChapterButton() {
	return (
		<Button asChild size="sm" variant="outline">
			<Link to="/my-account" search={{ tab: "account-information" }}>
				<MapPin />
				Set/Change My Chapter
			</Link>
		</Button>
	)
}

function EventsEmptyState({
	icon: Icon,
	title,
	message,
}: {
	icon: LucideIcon
	title: string
	message: string
}) {
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">{message}</p>
			<SeeAllEventsButton className="mt-5" />
		</div>
	)
}

function EventCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border py-5">
			<div className="flex gap-4 px-5">
				<Skeleton className="size-16 shrink-0 rounded-xl" />
				<div className="min-w-0 flex-1 space-y-2">
					<Skeleton className="h-5 w-28 rounded-xl" />
					<Skeleton className="h-5 w-4/5" />
					<Skeleton className="h-5 w-3/5" />
				</div>
			</div>
			<div className="mt-auto flex items-center justify-between gap-3 px-5">
				<Skeleton className="h-4 w-28" />
				<Skeleton className="h-8 w-36 rounded-xl" />
			</div>
		</Skeleton>
	)
}

function EventsContentSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading events"
		>
			{[0, 1, 2, 3, 4, 5].map((key) => (
				<EventCardSkeleton key={key} />
			))}
		</div>
	)
}

function EventGrid({ children }: { children: ReactNode }) {
	return (
		<StaggerReveal
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			itemClassName="h-full"
		>
			{children}
		</StaggerReveal>
	)
}

function emptyForTab(tab: Exclude<EventsTab, "all">) {
	if (tab === "attending") {
		return {
			icon: CalendarCheck,
			title: "You're not attending anything yet",
			message:
				"Events you register for will show up here so you can keep track of what's next.",
		}
	}
	if (tab === "chapter-meetings") {
		return {
			icon: Users,
			title: "No upcoming chapter meetings",
			message:
				"Meetings from your chapters will appear here when they are scheduled.",
		}
	}
	return {
		icon: Sparkles,
		title: "No featured events right now",
		message:
			"Browse the full GARP calendar for conferences, webcasts, and more.",
	}
}

function EventsTabBody({
	tab,
	attending,
	chapterMeetings,
	featured,
}: {
	tab: EventsTab
	attending: MemberEvent[]
	chapterMeetings: MemberEvent[]
	featured: MemberEvent[]
}) {
	if (tab === "attending") {
		if (attending.length === 0) {
			return <EventsEmptyState {...emptyForTab(tab)} />
		}
		return (
			<EventGrid>
				{attending.map((event) => (
					<EventCard key={event.eventId} event={event} />
				))}
			</EventGrid>
		)
	}

	if (tab === "chapter-meetings") {
		if (chapterMeetings.length === 0) {
			return <EventsEmptyState {...emptyForTab(tab)} />
		}
		return (
			<EventGrid>
				{chapterMeetings.map((event) => (
					<EventCard key={event.eventId} event={event} />
				))}
			</EventGrid>
		)
	}

	if (tab === "featured") {
		if (featured.length === 0) {
			return <EventsEmptyState {...emptyForTab(tab)} />
		}
		return (
			<EventGrid>
				{featured.map((event) => (
					<EventCard key={event.eventId} event={event} />
				))}
			</EventGrid>
		)
	}

	const isEmpty =
		attending.length === 0 &&
		chapterMeetings.length === 0 &&
		featured.length === 0

	if (isEmpty) {
		return (
			<EventsEmptyState
				icon={CalendarDays}
				title="No events to show"
				message="Your registrations and upcoming GARP events will appear here."
			/>
		)
	}

	return (
		<div className="space-y-8">
			{attending.length > 0 ? (
				<section className="space-y-4">
					<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
						<CalendarCheck className="size-5 text-muted-foreground" aria-hidden />
						Attending
						<span className="text-base font-normal text-muted-foreground">
							({attending.length})
						</span>
					</h2>
					<EventGrid>
						{attending.map((event) => (
							<EventCard key={event.eventId} event={event} />
						))}
					</EventGrid>
				</section>
			) : null}

			{chapterMeetings.length > 0 ? (
				<section className="space-y-4">
					<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
						<Users className="size-5 text-muted-foreground" aria-hidden />
						Upcoming Chapter Meetings
						<span className="text-base font-normal text-muted-foreground">
							({chapterMeetings.length})
						</span>
					</h2>
					<EventGrid>
						{chapterMeetings.map((event) => (
							<EventCard key={event.eventId} event={event} />
						))}
					</EventGrid>
				</section>
			) : null}

			{featured.length > 0 ? (
				<section className="space-y-4">
					<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
						<Sparkles className="size-5 text-muted-foreground" aria-hidden />
						Featured Events
						<span className="text-base font-normal text-muted-foreground">
							({featured.length})
						</span>
					</h2>
					<EventGrid>
						{featured.map((event) => (
							<EventCard key={event.eventId} event={event} />
						))}
					</EventGrid>
				</section>
			) : null}
		</div>
	)
}

function tabCount(
	tab: EventsTab,
	attending: number,
	chapterMeetings: number,
	featured: number,
): number {
	if (tab === "attending") return attending
	if (tab === "chapter-meetings") return chapterMeetings
	if (tab === "featured") return featured
	return attending + chapterMeetings + featured
}

function EventsPanel({ tab }: EventsPanelProps) {
	const navigate = useNavigate({ from: "/events/" })
	const { data, isLoading, isError } = useEvents()
	const attending = data?.registeredEvents ?? []
	const chapterMeetings = data?.upcomingChapterMeetings ?? []
	const featured = data?.upcomingOtherEvents ?? []
	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: { tab: value as EventsTab },
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<div className="space-y-3">
					<div>
						<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
							My Events
						</h1>
						<p className="mt-1 text-sm text-muted-foreground">
							Your registrations, chapter meetings, and featured GARP events.
						</p>
					</div>
					<div className="flex flex-wrap items-center gap-3">
						<SetChapterButton />
						<SeeAllEventsButton />
					</div>
				</div>

				<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
					<TabsList className="h-auto w-max gap-3 bg-transparent p-0">
						{TAB_ITEMS.map((item) => {
							const Icon = item.icon
							const count = tabCount(
								item.value,
								attending.length,
								chapterMeetings.length,
								featured.length,
							)
							return (
								<TabsTrigger
									key={item.value}
									value={item.value}
									className={pillTriggerClassName}
								>
									<Icon className="size-4" aria-hidden />
									{item.label}
									{!isLoading ? (
										<span className="ml-0.5 font-normal opacity-70">
											({count})
										</span>
									) : null}
								</TabsTrigger>
							)
						})}
					</TabsList>
				</div>
			</header>

			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <EventsContentSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your events. Please try again later.
					</p>
				) : null}

				{!isLoading && !isError
					? tabTransitions((style, currentTab) => (
							<animated.div
								key={currentTab}
								role="tabpanel"
								style={style}
								className="pb-2"
							>
								<EventsTabBody
									tab={currentTab}
									attending={attending}
									chapterMeetings={chapterMeetings}
									featured={featured}
								/>
							</animated.div>
						))
					: null}
			</div>
		</Tabs>
	)
}

export { EventsPanel }
