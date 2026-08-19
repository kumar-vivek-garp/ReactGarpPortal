import { Badge } from "@/components/atoms/badge"
import type { StatusTone } from "@/lib/status-tone"
import { cn } from "@/lib/utils"

/**
 * Every tone resolves through a `--color-*` token from `theme.css`, and each
 * brand hue is paired with its declared `-foreground` partner rather than an
 * assumed white/black.
 *
 * shadcn's own badge variants (`default`, `secondary`, `destructive`, …) don't
 * carry semantic status meaning, so tones layer on top of the atom instead of
 * replacing it.
 */
const TONE_CLASS: Record<StatusTone, string> = {
	neutral: "bg-muted text-muted-foreground",
	info: "bg-accent text-accent-foreground",
	success: "bg-success-green/15 text-success-green",
	warning: "bg-light-yellow text-light-yellow-foreground",
	danger: "bg-pink text-pink-foreground",
}

type StatusBadgeProps = {
	label: string
	tone: StatusTone
	className?: string
}

/** Semantic status pill — the single status affordance across every module. */
function StatusBadge({ label, tone, className }: StatusBadgeProps) {
	return (
		<Badge
			className={cn("px-3 py-1 font-semibold tracking-wide", TONE_CLASS[tone], className)}
		>
			{label}
		</Badge>
	)
}

export { StatusBadge }
