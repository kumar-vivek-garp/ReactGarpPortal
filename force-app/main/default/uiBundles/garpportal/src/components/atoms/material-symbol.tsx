import { cn } from "@/lib/utils"

/**
 * Material Symbols Outlined ligature icon — matches live Angular `mat-icon`
 * glyphs on the side nav. Deliberate exception to the Lucide-only convention
 * (same rationale as footer brand marks in `social-icons.tsx`).
 *
 * Pass the Material Symbols name without the legacy `_outline` suffix when
 * using the Outlined font (e.g. `home`, not `home_outline`).
 */
type MaterialSymbolProps = {
	name: string
	className?: string
}

function MaterialSymbol({ name, className }: MaterialSymbolProps) {
	return (
		<span className={cn("material-symbols-outlined", className)} aria-hidden="true">
			{name}
		</span>
	)
}

export { MaterialSymbol }
