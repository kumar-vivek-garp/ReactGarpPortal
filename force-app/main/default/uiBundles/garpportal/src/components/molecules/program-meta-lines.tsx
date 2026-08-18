import { Award, CalendarClock, CircleCheck, Clock, Sparkles } from "lucide-react"
import type { LucideIcon } from "lucide-react"

import type {
	ProgramMetaIcon,
	ProgramMetaLine,
} from "@/lib/program-listing-presentation"
import { cn } from "@/lib/utils"

/** Keeps the icon vocabulary in one place so grid and list cannot drift. */
const META_ICON: Record<ProgramMetaIcon, LucideIcon> = {
	administration: CalendarClock,
	registrationOpen: CircleCheck,
	opensLater: Clock,
	microCourse: Sparkles,
	certified: Award,
}

type ProgramMetaLinesProps = {
	lines: ProgramMetaLine[]
	className?: string
}

/** Icon-prefixed metadata rows shared by the program card and the list row. */
function ProgramMetaLines({ lines, className }: ProgramMetaLinesProps) {
	if (lines.length === 0) return null

	return (
		<ul className={cn("space-y-1.5", className)}>
			{lines.map((line) => {
				const Icon = META_ICON[line.icon]
				return (
					<li
						key={`${line.icon}-${line.text}`}
						className="flex items-start gap-2 text-sm text-muted-foreground"
					>
						<Icon
							className="mt-0.5 size-4 shrink-0 text-primary"
							aria-hidden
						/>
						<span className="min-w-0">{line.text}</span>
					</li>
				)
			})}
		</ul>
	)
}

export { ProgramMetaLines }
