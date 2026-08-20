import type { ReactNode } from "react"
import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"

import type { MemberEvent } from "@/api/events"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { EventCard } from "@/components/molecules/event-card"
import { EventsPendingShell } from "@/components/molecules/page-pending"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	EVENT_BUCKET_META,
	EVENT_TAB_ITEMS,
	type EventsTab,
} from "@/config/events"
import { useEvents } from "@/hooks/use-events"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"

type EventsPanelProps = {
	tab: EventsTab
}

function EventsEmptyState({ tab }: { tab: EventsTab }) {
	const { icon: Icon, emptyTitle, emptyMessage } = EVENT_BUCKET_META[tab]
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{emptyTitle}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{emptyMessage}
			</p>
		</div>
	)
}

function EventGrid({ children }: { children: ReactNode }) {
	return (
		<StaggerReveal
			className="grid gap-6 sm:grid-cols-2"
			itemClassName="h-full"
		>
			{children}
		</StaggerReveal>
	)
}


function EventsSection({
	tab,
	count,
	children,
}: {
	tab: Exclude<EventsTab, "all">
	count: number
	children: ReactNode
}) {
	const { icon: Icon, heading } = EVENT_BUCKET_META[tab]
	return (
		<section className="space-y-4">
			<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
				<Icon className="size-5 shrink-0 text-primary" aria-hidden />
				{heading}
				<span className="text-base font-normal text-muted-foreground">
					({count})
				</span>
			</h2>
			{children}
		</section>
	)
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
			return <EventsEmptyState tab={tab} />
		}
		return (
			<EventGrid>
				{attending.map((event) => (
					<EventCard key={event.eventId} event={event} isAttending />
				))}
			</EventGrid>
		)
	}

	if (tab === "chapter-meetings") {
		if (chapterMeetings.length === 0) {
			return <EventsEmptyState tab={tab} />
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
			return <EventsEmptyState tab={tab} />
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
			<EventsEmptyState tab="all" />
		)
	}

	return (
		<div className="space-y-8">
			{attending.length > 0 ? (
				<EventsSection tab="attending" count={attending.length}>
					<EventGrid>
						{attending.map((event) => (
							<EventCard key={event.eventId} event={event} isAttending />
						))}
					</EventGrid>
				</EventsSection>
			) : null}

			{chapterMeetings.length > 0 ? (
				<EventsSection tab="chapter-meetings" count={chapterMeetings.length}>
					<EventGrid>
						{chapterMeetings.map((event) => (
							<EventCard key={event.eventId} event={event} />
						))}
					</EventGrid>
				</EventsSection>
			) : null}

			{featured.length > 0 ? (
				<EventsSection tab="featured" count={featured.length}>
					<EventGrid>
						{featured.map((event) => (
							<EventCard key={event.eventId} event={event} />
						))}
					</EventGrid>
				</EventsSection>
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

	if (isLoading) {
		return <EventsPendingShell tab={tab} />
	}

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
				<div>
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						My Events
					</h1>
					<p className="mt-1 text-sm text-muted-foreground">
						Your registrations, chapter meetings, and featured GARP events.
					</p>
				</div>

				<PillTabs
					items={EVENT_TAB_ITEMS.map((item) => ({
						...item,
						count: tabCount(
							item.value,
							attending.length,
							chapterMeetings.length,
							featured.length,
						),
					}))}
					value={tab}
				/>
			</header>

			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your events. Please try again later.
					</p>
				) : null}

				{!isError
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
