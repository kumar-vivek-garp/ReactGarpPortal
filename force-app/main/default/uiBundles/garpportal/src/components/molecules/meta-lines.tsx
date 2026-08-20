import {
	Award,
	BookOpen,
	CalendarClock,
	CalendarSync,
	CircleCheck,
	Clock,
	CreditCard,
	Hash,
	History,
	Mail,
	MapPin,
	Phone,
	Sparkles,
	Tag,
	TriangleAlert,
	UserRoundCheck,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"

import type { MetaIcon, MetaLine } from "@/lib/meta-line"
import type { StatusTone } from "@/lib/status-tone"
import { cn } from "@/lib/utils"

/** One icon vocabulary for the whole app, so modules cannot drift apart. */
const META_ICON: Record<MetaIcon, LucideIcon> = {
	administration: CalendarClock,
	registrationOpen: CircleCheck,
	opensLater: Clock,
	microCourse: Sparkles,
	certified: Award,
	when: CalendarClock,
	location: MapPin,
	eventType: BookOpen,
	accessUntil: Clock,
	expiringSoon: TriangleAlert,
	lastOpened: History,
	unavailable: TriangleAlert,
	price: Tag,
	materialType: BookOpen,
	email: Mail,
	phone: Phone,
	memberSince: UserRoundCheck,
	renews: CalendarSync,
	invoice: Hash,
	paymentMethod: CreditCard,
}

/** Icons that should read as a warning rather than neutral information. */
const TONED_ICON: Partial<Record<MetaIcon, StatusTone>> = {
	expiringSoon: "warning",
	unavailable: "warning",
}

const ICON_TONE_CLASS: Record<StatusTone, string> = {
	neutral: "text-primary",
	info: "text-primary",
	success: "text-success-green",
	warning: "text-light-yellow-foreground",
	danger: "text-pink-foreground",
}

type MetaLinesProps = {
	lines: MetaLine[]
	className?: string
}

/**
 * Icon-prefixed metadata rows shared by program cards/rows, event cards and
 * study-material cards, so a date or a location looks the same everywhere.
 */
function MetaLines({ lines, className }: MetaLinesProps) {
	if (lines.length === 0) return null

	return (
		<ul className={cn("space-y-1.5", className)}>
			{lines.map((line) => {
				const Icon = META_ICON[line.icon]
				const tone = TONED_ICON[line.icon] ?? "neutral"
				return (
					<li
						key={`${line.icon}-${line.text}`}
						className="flex items-start gap-2 text-sm text-muted-foreground"
					>
						<Icon
							className={cn("mt-0.5 size-4 shrink-0", ICON_TONE_CLASS[tone])}
							aria-hidden
						/>
						<span className="min-w-0">{line.text}</span>
					</li>
				)
			})}
		</ul>
	)
}

export { MetaLines }
