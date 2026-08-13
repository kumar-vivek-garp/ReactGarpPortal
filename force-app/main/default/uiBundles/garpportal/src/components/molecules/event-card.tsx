import { CalendarDays, MonitorPlay, Users } from "lucide-react"

import type { MemberEvent } from "@/api/events"
import {
	Card,
	CardContent,
	CardFooter,
	CardTitle,
} from "@/components/atoms/card"
import { AddToCalendarButton } from "@/components/molecules/add-to-calendar-button"
import { CardCta } from "@/components/molecules/card-cta"
import { manageAttendanceHref } from "@/config/events"
import { formatLongDate } from "@/lib/account-format"
import { hasCalendarPayload } from "@/lib/event-calendar"
import { cn } from "@/lib/utils"

type EventCardProps = {
	event: MemberEvent
	className?: string
}

function isSafeHttpUrl(url: string | null | undefined): url is string {
	if (!url?.trim()) return false
	try {
		const parsed = new URL(url.trim())
		return parsed.protocol === "http:" || parsed.protocol === "https:"
	} catch {
		return false
	}
}

/** Drop base catalogue paths with no vanity slug (`/event/`). */
function eventPageUrl(url: string | null | undefined): string | null {
	if (!isSafeHttpUrl(url)) return null
	const path = new URL(url.trim()).pathname.replace(/\/+$/, "")
	return path.split("/").filter(Boolean).length >= 2 ? url.trim() : null
}

function eventDateParts(iso: string | null | undefined): {
	month: string
	day: string
	label: string
} | null {
	if (!iso) return null
	const [year, month, day] = iso.split("-").map(Number)
	if (!year || !month || !day) return null
	const label = formatLongDate(iso.slice(0, 10))
	if (!label) return null
	return {
		month: new Date(year, month - 1, day).toLocaleDateString(undefined, {
			month: "short",
		}),
		day: String(day),
		label,
	}
}

function EventTypeGlyph({
	type,
	className,
}: {
	type: string | null | undefined
	className?: string
}) {
	const normalized = type?.toLowerCase() ?? ""
	if (normalized.includes("chapter")) {
		return <Users className={className} />
	}
	if (normalized.includes("webcast")) {
		return <MonitorPlay className={className} />
	}
	return <CalendarDays className={className} />
}

function EventCard({ event, className }: EventCardProps) {
	const name = event.eventName?.trim() || "Event"
	const parts = eventDateParts(event.eventStartDate)
	const typeLabel = event.eventType?.trim() || null
	const href = eventPageUrl(event.eventURL)
	const attendanceHref = event.canManageAttendance
		? manageAttendanceHref(event.eventId)
		: null
	const showCalendar = hasCalendarPayload(event)
	const showFooter = Boolean(href || attendanceHref || showCalendar)

	return (
		<Card
			className={cn(
				"h-full gap-4 border-border py-5 shadow-none",
				className,
			)}
		>
				<div className="flex items-start gap-4 px-5">
					{parts ? (
						<div
							className="flex size-16 shrink-0 flex-col items-center justify-center rounded-xl bg-primary/10 text-primary"
							aria-hidden
						>
							<span className="text-[11px] font-extrabold tracking-wider uppercase">
								{parts.month}
							</span>
							<span className="font-heading text-2xl leading-none font-semibold">
								{parts.day}
							</span>
						</div>
					) : (
						<div
							className="flex size-16 shrink-0 items-center justify-center rounded-xl bg-muted text-muted-foreground"
							aria-hidden
						>
							<EventTypeGlyph type={event.eventType} className="size-7" />
						</div>
					)}
					<div className="min-w-0 space-y-2">
						<div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
							<span className="inline-flex items-center gap-1.5 font-medium">
								<EventTypeGlyph
									type={event.eventType}
									className="size-3.5"
								/>
								{typeLabel || "Event"}
							</span>
							{parts ? <span>{parts.label}</span> : null}
						</div>
						<CardTitle className="font-heading text-lg leading-snug tracking-wide text-foreground">
							{name}
						</CardTitle>
					</div>
				</div>

				{!parts && !typeLabel ? (
					<CardContent className="flex-1 px-5">
						<p className="text-sm text-muted-foreground">
							Details will be available closer to the date.
						</p>
					</CardContent>
				) : null}

				{showFooter ? (
					<CardFooter className="mt-auto flex flex-wrap items-center justify-between gap-3 px-5">
						<div className="flex flex-wrap items-center gap-4">
							<CardCta
								label="View event"
								url={href}
								isExternal
								newWindow
							/>
							<CardCta
								label="Manage Attendance"
								url={attendanceHref}
								isExternal
							/>
						</div>
						{showCalendar ? (
							<AddToCalendarButton event={event} className="ms-auto" />
						) : null}
					</CardFooter>
				) : null}
		</Card>
	)
}

export { EventCard }
