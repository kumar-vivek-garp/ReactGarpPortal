import { Badge } from "@/components/atoms/badge"
import { cn } from "@/lib/utils"

type ValueChipProps = {
	children: React.ReactNode
	className?: string
}

/**
 * The one actionable value on a tile — an exam sitting, a renewal date, a
 * credit count — lifted onto the accent swatch so it is the first thing read.
 *
 * Deliberately NOT a `StatusBadge`: that pill carries a *tone* (success,
 * warning …); this carries no judgement, only emphasis, so it always uses the
 * accent pairing and keeps the value's own case and size. Square corners
 * (`rounded-sm` resolves to 0 in this theme) match the events list's type tag,
 * so the two chip shapes in the app share one silhouette.
 *
 * One per tile. A chip on every line is no emphasis at all — that was the
 * tradeoff recorded when this direction was chosen (light-theme redesign,
 * Sep 2026).
 */
function ValueChip({ children, className }: ValueChipProps) {
	return (
		<Badge
			className={cn(
				"rounded-sm bg-accent px-2 py-0.5 text-xs font-bold text-accent-foreground tabular-nums",
				className,
			)}
		>
			{children}
		</Badge>
	)
}

export { ValueChip }
