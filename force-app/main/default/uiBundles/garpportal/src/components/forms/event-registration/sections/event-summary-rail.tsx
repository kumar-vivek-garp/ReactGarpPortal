import {
	CalendarDays,
	Clock,
	MapPin,
	MonitorSmartphone,
	ReceiptText,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"

import type { EventRates, EventView } from "@/api/registration/event-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Separator } from "@/components/atoms/separator"
import { calendarPlainText } from "@/lib/event-calendar"
import { eventWhenLabels } from "@/lib/event-registration-presentation"
import { formatMoney } from "@/lib/account-format"

function DetailRow({
	icon: Icon,
	children,
}: {
	icon: LucideIcon
	children: React.ReactNode
}) {
	return (
		<div className="flex items-start gap-3 text-sm text-foreground">
			<Icon className="mt-0.5 size-4 shrink-0 text-muted-foreground" aria-hidden />
			<span className="min-w-0">{children}</span>
		</div>
	)
}

type EventSummaryRailProps = {
	event: EventView
	rates: EventRates | null
}

/**
 * The pinned right column — the event's own facts and the money, always on
 * screen while the form scrolls. The exam form's rail carries a cart; this
 * one carries what a person double-checks before committing an evening to
 * something: when, where, how it's delivered, and what it costs.
 *
 * Scrolls internally rather than with the form, and deliberately without
 * `overscroll-contain`: when it bottoms out the wheel should keep scrolling
 * the page.
 */
function EventSummaryRail({ event, rates }: EventSummaryRailProps) {
	const { dateLabel, timeLabel } = eventWhenLabels(event)
	const where = [event.venue?.trim(), event.location?.trim()]
		.filter(Boolean)
		.join(" · ")
	// The description arrives as rich-text HTML; rendered as plain text only.
	const description = calendarPlainText(event.description)
	const amountDue = rates?.amountDue ?? 0

	return (
		<div className="flex max-h-[calc(100vh-13.5rem)] flex-col gap-4 overflow-y-auto scrollbar-none">
			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2 text-lg">
						<CalendarDays className="size-5 text-muted-foreground" aria-hidden />
						Event details
					</CardTitle>
				</CardHeader>
				<CardContent className="flex flex-col gap-3">
					{dateLabel ? (
						<DetailRow icon={CalendarDays}>{dateLabel}</DetailRow>
					) : null}
					{timeLabel ? <DetailRow icon={Clock}>{timeLabel}</DetailRow> : null}
					{where ? <DetailRow icon={MapPin}>{where}</DetailRow> : null}
					{event.deliveryMode?.trim() ? (
						<DetailRow icon={MonitorSmartphone}>
							{event.deliveryMode.trim()}
						</DetailRow>
					) : null}
					{description ? (
						<>
							<Separator />
							<p className="text-sm leading-relaxed whitespace-pre-line text-muted-foreground">
								{description}
							</p>
						</>
					) : null}
				</CardContent>
			</Card>

			<Card>
				<CardHeader>
					<CardTitle className="flex items-center gap-2 text-lg">
						<ReceiptText className="size-5 text-muted-foreground" aria-hidden />
						Summary
					</CardTitle>
				</CardHeader>
				<CardContent className="flex flex-col gap-3">
					<div className="flex items-center justify-between gap-4 text-sm">
						<span className="text-muted-foreground">Registration</span>
						<span className="font-medium tabular-nums">
							{amountDue > 0 ? formatMoney(amountDue, "USD") : "Free"}
						</span>
					</div>
					<Separator />
					<div className="flex items-center justify-between gap-4">
						<span className="text-sm font-semibold">Total</span>
						<span
							className={
								amountDue > 0
									? "text-lg font-semibold text-primary tabular-nums"
									: "text-lg font-semibold text-muted-foreground"
							}
						>
							{amountDue > 0 ? formatMoney(amountDue, "USD") : "Free"}
						</span>
					</div>
					{event.cancellationPolicy?.trim() ? (
						<p className="text-caption leading-relaxed whitespace-pre-line text-muted-foreground">
							{event.cancellationPolicy.trim()}
						</p>
					) : null}
					{event.paymentPolicy?.trim() && amountDue > 0 ? (
						<p className="text-caption leading-relaxed whitespace-pre-line text-muted-foreground">
							{event.paymentPolicy.trim()}
						</p>
					) : null}
				</CardContent>
			</Card>
		</div>
	)
}

export { EventSummaryRail }
