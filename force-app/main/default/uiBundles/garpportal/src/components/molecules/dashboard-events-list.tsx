import type { DashboardEventPreview } from "@/api/dashboard"
import { formatLongDate } from "@/lib/account-format"
import { cn } from "@/lib/utils"

type DashboardEventsListProps = {
	events: DashboardEventPreview[]
	className?: string
}

function DashboardEventsList({ events, className }: DashboardEventsListProps) {
	if (events.length === 0) return null

	return (
		<ul className={cn("space-y-4", className)}>
			{events.map((event) => {
				const date = formatLongDate(event.eventStartDate?.slice(0, 10))
				return (
					<li key={event.eventId} className="space-y-1.5">
						<div className="flex flex-wrap items-center gap-2">
							<span className="rounded-sm bg-accent px-2 py-0.5 text-[11px] font-semibold tracking-wide text-primary uppercase">
								{event.eventType}
							</span>
							{date ? (
								<span className="text-sm text-muted-foreground">{date}</span>
							) : null}
						</div>
						{event.eventUrl ? (
							<a
								href={event.eventUrl}
								target="_blank"
								rel="noreferrer noopener"
								className="block text-sm font-semibold text-primary hover:text-primary/80"
							>
								{event.eventName}
							</a>
						) : (
							<p className="text-sm font-semibold text-foreground">
								{event.eventName}
							</p>
						)}
					</li>
				)
			})}
		</ul>
	)
}

export { DashboardEventsList }
