import type { ReactNode } from "react"
import { useNavigate } from "@tanstack/react-router"
import { CalendarDays, Clock, MapPin, TriangleAlert } from "lucide-react"

import type { MemberEvent } from "@/api/events"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { AddToCalendarButton } from "@/components/molecules/add-to-calendar-button"
import { CardCta } from "@/components/molecules/card-cta"
import { EmptyState } from "@/components/molecules/empty-state"
import { EventCard } from "@/components/molecules/event-card"
import { EventsPendingShell } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	EVENT_TYPE_FILTER_ITEMS,
	EVENT_TYPE_META,
	type EventTypeFilter,
} from "@/config/events"
import { useEvents } from "@/hooks/use-events"
import {
	buildEventPresentation,
	eventKind,
	eventWeekday,
} from "@/lib/events-presentation"
import { cn } from "@/lib/utils"

type EventsPanelProps = {
	/** Type filter from `?type=`; absent means all types. */
	type: EventTypeFilter | undefined
}

/** Ascending by start date, undated last — the order a person plans in. */
function byStartDate(a: MemberEvent, b: MemberEvent): number {
	if (!a.eventStartDate) return b.eventStartDate ? 1 : 0
	if (!b.eventStartDate) return -1
	return a.eventStartDate.localeCompare(b.eventStartDate)
}

/** The grid has events, just none of the filtered type. */
function FilteredEmptyState({
	type,
	onClear,
}: {
	type: EventTypeFilter
	onClear: () => void
}) {
	const typeMeta = EVENT_TYPE_META[type]
	return (
		<EmptyState
			icon={typeMeta.icon}
			title={`No ${typeMeta.noun} here`}
			message={`There are no ${typeMeta.noun} coming up right now.`}
			action={
				<Button variant="outline" onClick={onClear}>
					Show all types
				</Button>
			}
		/>
	)
}

/**
 * The next event the member registered for, as a hero — same surface as the
 * membership and account heroes. Collapses entirely when nothing is booked.
 */
function UpNextHero({ event }: { event: MemberEvent }) {
	const item = buildEventPresentation(event, { isAttending: true })
	const typeMeta = EVENT_TYPE_META[item.kind]
	const TypeIcon = typeMeta.icon
	const weekday = eventWeekday(event.eventStartDate?.slice(0, 10))

	return (
		<section
			className="flex flex-col gap-6 rounded-xl border border-border bg-linear-to-br from-surface-gradient-start to-surface-gradient-end p-6 sm:flex-row sm:items-center sm:gap-8 sm:p-8 lg:gap-10"
			aria-label="Your next event"
		>
			<div className="flex min-w-0 flex-1 flex-col gap-3">
				<div className="flex flex-wrap items-center gap-3">
					<span className="text-xs font-extrabold tracking-[0.12em] text-primary uppercase">
						Up next — you&apos;re attending
					</span>
					<Badge
						variant="outline"
						className={cn("rounded-md font-semibold", typeMeta.chip)}
					>
						<TypeIcon className="size-3" aria-hidden />
						{item.typeLabel}
					</Badge>
				</div>

				<h2 className="font-heading text-2xl leading-tight font-semibold tracking-wide text-foreground sm:text-3xl">
					{item.title}
				</h2>

				{item.description ? (
					<p className="line-clamp-2 max-w-2xl text-sm leading-relaxed text-muted-foreground">
						{item.description}
					</p>
				) : null}

				<div className="flex flex-wrap items-center gap-x-5 gap-y-1 text-sm text-muted-foreground">
					{item.metaLines.map((line) => (
						<span key={line.text} className="inline-flex items-center gap-2">
							{line.icon === "location" ? (
								<MapPin className="size-4 shrink-0" aria-hidden />
							) : (
								<Clock className="size-4 shrink-0" aria-hidden />
							)}
							{line.text}
						</span>
					))}
				</div>

				<div className="mt-2 flex flex-wrap items-center gap-5">
					{item.hasCalendar ? <AddToCalendarButton event={event} /> : null}
					<CardCta
						label="View event details"
						url={item.eventUrl}
						isExternal
						newWindow
					/>
				</div>
			</div>

			{item.dateBadge ? (
				<div
					className="flex shrink-0 flex-col items-center gap-1 self-start rounded-xl border border-border bg-card px-8 py-6 sm:self-center"
					aria-hidden
				>
					<span className="text-sm font-extrabold tracking-[0.2em] text-primary uppercase">
						{item.dateBadge.month}
					</span>
					<span className="font-heading text-6xl leading-none font-semibold text-foreground">
						{item.dateBadge.day}
					</span>
					{weekday ? (
						<span className="text-sm font-semibold text-muted-foreground">
							{weekday}
						</span>
					) : null}
				</div>
			) : null}
		</section>
	)
}

function EventGrid({
	revealKey,
	children,
}: {
	/**
	 * Changes when the visible list changes, remounting the trail so the
	 * cascade replays — `useTrail` will not re-run on its own because the `to`
	 * values are unchanged.
	 */
	revealKey: string
	children: ReactNode
}) {
	return (
		<StaggerReveal
			key={revealKey}
			className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3"
			itemClassName="h-full"
		>
			{children}
		</StaggerReveal>
	)
}

function EventsPanel({ type }: EventsPanelProps) {
	const navigate = useNavigate({ from: "/events/" })
	const { data, isLoading, isError } = useEvents()

	const attending = data?.registeredEvents ?? []
	const chapterMeetings = data?.upcomingChapterMeetings ?? []
	const featured = data?.upcomingOtherEvents ?? []

	// The soonest registered event carries the hero; everything else — the
	// rest of the registrations included — flows into one dated grid.
	const upNext = [...attending].sort(byStartDate)[0]
	const attendingIds = new Set(attending.map((event) => event.eventId))
	const rest = [...attending, ...chapterMeetings, ...featured]
		.filter((event) => event.eventId !== upNext?.eventId)
		.sort(byStartDate)

	const typeCounts = { all: rest.length, event: 0, webcast: 0, chapter: 0 }
	for (const event of rest) {
		typeCounts[eventKind(event.eventType)] += 1
	}
	const visible = type
		? rest.filter((event) => eventKind(event.eventType) === type)
		: rest

	const setTypeFilter = (next: EventTypeFilter | undefined) => {
		void navigate({
			search: (prev) => ({ ...prev, type: next }),
			replace: true,
		})
	}

	if (isLoading) {
		return <EventsPendingShell />
	}

	return (
		<div className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]">
			<header className="shrink-0">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					My Events
				</h1>
				<p className="mt-1 text-sm text-muted-foreground">
					Your next commitment up top, everything else below.
				</p>
			</header>

			<div className="mt-6 min-h-0 flex-1 space-y-8 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isError ? (
					<EmptyState
						icon={TriangleAlert}
						tone="error"
						title="We couldn't load your events"
						message="Please try again later."
					/>
				) : null}

				{!isError && !upNext && rest.length === 0 ? (
					<EmptyState
						icon={CalendarDays}
						title="No events to show"
						message="Your registrations and upcoming GARP events will appear here."
					/>
				) : null}

				{!isError && upNext ? <UpNextHero event={upNext} /> : null}

				{!isError && rest.length > 0 ? (
					<section className="space-y-5 pb-2">
						<div className="flex flex-wrap items-center justify-between gap-3">
							<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
								{upNext ? "Also happening" : "Upcoming events"}
							</h2>
							{/* `value ?? ""` never reaches Radix — "all" is the bar-only
							    sentinel, absent from the URL. */}
							<Select
								value={type ?? "all"}
								onValueChange={(value) => {
									setTypeFilter(
										value === "all"
											? undefined
											: (value as EventTypeFilter),
									)
								}}
							>
								<SelectTrigger
									className="w-56"
									aria-label="Filter events by type"
								>
									<span className="text-muted-foreground">Show:</span>
									<SelectValue />
								</SelectTrigger>
								<SelectContent align="end">
									<SelectItem value="all">
										All types ({typeCounts.all})
									</SelectItem>
									{EVENT_TYPE_FILTER_ITEMS.map((item) => (
										<SelectItem key={item.value} value={item.value}>
											<item.icon
												className="size-4 text-muted-foreground"
												aria-hidden
											/>
											{item.label} ({typeCounts[item.value]})
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						</div>

						{visible.length === 0 && type ? (
							<FilteredEmptyState
								type={type}
								onClear={() => setTypeFilter(undefined)}
							/>
						) : (
							<EventGrid revealKey={type ?? "all"}>
								{visible.map((event) => (
									<EventCard
										key={event.eventId}
										event={event}
										isAttending={attendingIds.has(event.eventId)}
									/>
								))}
							</EventGrid>
						)}
					</section>
				) : null}
			</div>
		</div>
	)
}

export { EventsPanel }
