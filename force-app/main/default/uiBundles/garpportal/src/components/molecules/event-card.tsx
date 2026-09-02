import type { MemberEvent } from "@/api/events"
import { Badge } from "@/components/atoms/badge"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { AddToCalendarButton } from "@/components/molecules/add-to-calendar-button"
import { CardCta } from "@/components/molecules/card-cta"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { EVENT_TYPE_META } from "@/config/events"
import { buildEventPresentation } from "@/lib/events-presentation"
import { cn } from "@/lib/utils"

type EventCardProps = {
	event: MemberEvent
	/** Set for events in the Attending bucket — surfaces a registered badge. */
	isAttending?: boolean
	className?: string
}

function EventCard({ event, isAttending = false, className }: EventCardProps) {
	const item = buildEventPresentation(event, { isAttending })
	const typeMeta = EVENT_TYPE_META[item.kind]
	const KindIcon = typeMeta.icon
	const showFooter = Boolean(
		item.registerUrl || item.eventUrl || item.attendanceUrl || item.hasCalendar,
	)

	return (
		<Card
			className={cn("h-full gap-4 py-5 shadow-none", className)}
		>
			<CardHeader className="gap-3 px-5">
				<div className="flex items-start gap-4">
					{item.dateBadge ? (
						<div
							className="flex size-16 shrink-0 flex-col items-center justify-center rounded-xl bg-primary/10 text-primary"
							aria-hidden
						>
							<span className="text-[11px] font-extrabold tracking-wider uppercase">
								{item.dateBadge.month}
							</span>
							<span className="font-heading text-2xl leading-none font-semibold">
								{item.dateBadge.day}
							</span>
						</div>
					) : (
						<div
							className="flex size-16 shrink-0 items-center justify-center rounded-xl bg-muted text-muted-foreground"
							aria-hidden
						>
							<KindIcon className="size-7" />
						</div>
					)}

					<div className="min-w-0 space-y-2">
						<div className="flex flex-wrap items-center gap-2">
							{/* border-transparent in the chip suppresses the outline border,
							    matching the program code chips' tinted look. */}
							<Badge
								variant="outline"
								className={cn("rounded-md font-semibold", typeMeta.chip)}
							>
								<KindIcon className="size-3" aria-hidden />
								{item.typeLabel}
							</Badge>
							{item.statusLabel && item.statusTone ? (
								<StatusBadge
									label={item.statusLabel}
									tone={item.statusTone}
								/>
							) : null}
							{item.timingLabel && item.timingTone ? (
								<StatusBadge
									label={item.timingLabel}
									tone={item.timingTone}
								/>
							) : null}
						</div>
						<CardTitle className="font-heading text-lg leading-snug tracking-wide text-foreground">
							{item.title}
						</CardTitle>
					</div>
				</div>
			</CardHeader>

			<CardContent className="flex-1 space-y-3 px-5">
				{item.description ? (
					<p className="line-clamp-2 text-sm text-muted-foreground">
						{item.description}
					</p>
				) : null}
				{item.metaLines.length > 0 ? (
					<MetaLines lines={item.metaLines} />
				) : !item.description ? (
					<p className="text-sm text-muted-foreground">
						Details will be available closer to the date.
					</p>
				) : null}
			</CardContent>

			{showFooter ? (
				<CardFooter className="mt-auto flex flex-wrap items-center justify-between gap-3 px-5">
					<div className="flex flex-wrap items-center gap-4">
						<CardCta
							label="Register"
							url={item.registerUrl}
							isExternal={false}
						/>
						<CardCta
							label="View event"
							url={item.eventUrl}
							isExternal
							newWindow
						/>
						<CardCta
							label="Manage Attendance"
							url={item.attendanceUrl}
							isExternal
						/>
					</div>
					{item.hasCalendar ? (
						<AddToCalendarButton event={event} className="ms-auto" />
					) : null}
				</CardFooter>
			) : null}
		</Card>
	)
}

export { EventCard }
