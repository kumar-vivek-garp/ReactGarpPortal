import { useState, type ComponentType, type SVGProps } from "react"
import { animated, useSpring } from "@react-spring/web"
import { Apple, CalendarPlus, ChevronDown, Download } from "lucide-react"

import type { MemberEvent } from "@/api/events"
import { Button } from "@/components/atoms/button"
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuTrigger,
} from "@/components/atoms/dropdown-menu"
import {
	calendarEventFromMember,
	openCalendar,
	type CalendarProvider,
} from "@/lib/event-calendar"

const CHEVRON_SPRING = { mass: 0.9, tension: 320, friction: 26 }

type ProviderIcon = ComponentType<SVGProps<SVGSVGElement>>

function GoogleMark(props: SVGProps<SVGSVGElement>) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden {...props}>
			<path
				fill="#4285F4"
				d="M21.6 12.23c0-.74-.07-1.45-.2-2.13H12v4.03h5.38a4.6 4.6 0 0 1-2 3.02v2.51h3.24c1.9-1.75 2.98-4.33 2.98-7.43Z"
			/>
			<path
				fill="#34A853"
				d="M12 22c2.7 0 4.96-.9 6.62-2.34l-3.24-2.51c-.9.6-2.05.96-3.38.96-2.6 0-4.8-1.76-5.59-4.12H3.07v2.59A10 10 0 0 0 12 22Z"
			/>
			<path
				fill="#FBBC05"
				d="M6.41 13.99A6 6 0 0 1 6.1 12c0-.69.12-1.36.31-1.99V7.42H3.07A10 10 0 0 0 2 12c0 1.61.39 3.14 1.07 4.58z"
			/>
			<path
				fill="#EA4335"
				d="M12 5.96c1.47 0 2.79.5 3.82 1.5l2.87-2.87C16.95 2.97 14.7 2 12 2A10 10 0 0 0 3.07 7.42l3.34 2.59C7.2 7.72 9.4 5.96 12 5.96Z"
			/>
		</svg>
	)
}

function MicrosoftMark(props: SVGProps<SVGSVGElement>) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden {...props}>
			<path fill="#F25022" d="M3 3h8.4v8.4H3z" />
			<path fill="#7FBA00" d="M12.6 3H21v8.4h-8.4z" />
			<path fill="#00A4EF" d="M3 12.6h8.4V21H3z" />
			<path fill="#FFB900" d="M12.6 12.6H21V21h-8.4z" />
		</svg>
	)
}

const PROVIDERS: { id: CalendarProvider; label: string; icon: ProviderIcon }[] =
	[
		{ id: "google", label: "Google Calendar", icon: GoogleMark },
		{ id: "apple", label: "Apple Calendar", icon: Apple },
		{ id: "microsoft365", label: "Microsoft 365 / Outlook", icon: MicrosoftMark },
		{ id: "ics", label: "Download .ics", icon: Download },
	]

export function AddToCalendarButton({
	event,
	className,
}: {
	event: MemberEvent
	className?: string
}) {
	const payload = calendarEventFromMember(event)
	const [open, setOpen] = useState(false)
	const chevronSpring = useSpring({
		rotate: open ? 180 : 0,
		config: CHEVRON_SPRING,
	})

	if (!payload) return null

	return (
		<DropdownMenu open={open} onOpenChange={setOpen}>
			<DropdownMenuTrigger asChild>
				<Button type="button" size="sm" className={className}>
					<CalendarPlus />
					Add to Calendar
					<animated.span
						className="inline-flex"
						style={{
							transform: chevronSpring.rotate.to(
								(rotate) => `rotate(${rotate}deg)`,
							),
						}}
					>
						<ChevronDown className="size-3.5" aria-hidden />
					</animated.span>
				</Button>
			</DropdownMenuTrigger>
			<DropdownMenuContent align="end" className="min-w-56 rounded-xl">
				{PROVIDERS.map((provider) => {
					const Icon = provider.icon
					return (
						<DropdownMenuItem
							key={provider.id}
							className="cursor-pointer"
							onSelect={() => openCalendar(provider.id, payload)}
						>
							<Icon className="size-4" />
							{provider.label}
						</DropdownMenuItem>
					)
				})}
			</DropdownMenuContent>
		</DropdownMenu>
	)
}
