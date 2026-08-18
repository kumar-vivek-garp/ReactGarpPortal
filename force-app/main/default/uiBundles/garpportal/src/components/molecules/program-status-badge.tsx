import { cn } from "@/lib/utils"
import type { ProgramStatusTone } from "@/lib/program-detail-presentation"

const TONE_CLASS: Record<ProgramStatusTone, string> = {
	neutral: "bg-muted text-muted-foreground",
	info: "bg-accent text-accent-foreground",
	success: "bg-success-green/15 text-success-green",
	warning: "bg-light-yellow text-light-yellow-foreground",
	danger: "bg-pink text-pink-foreground",
}

type ProgramStatusBadgeProps = {
	label: string
	tone: ProgramStatusTone
	className?: string
}

function ProgramStatusBadge({
	label,
	tone,
	className,
}: ProgramStatusBadgeProps) {
	return (
		<span
			className={cn(
				"inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold tracking-wide",
				TONE_CLASS[tone],
				className,
			)}
		>
			{label}
		</span>
	)
}

export { ProgramStatusBadge }
