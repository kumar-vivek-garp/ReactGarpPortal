import { cn } from "@/lib/utils"

/**
 * Material Symbols Outlined ligature icon — matches live Angular `mat-icon`
 * glyphs on the side nav. Uses the self-hosted 7-glyph subset font
 * (`src/assets/fonts/material-symbols-outlined-subset.woff2`).
 *
 * Pass the Material Symbols name without the legacy `_outline` suffix
 * (e.g. `home`, not `home_outline`). Only names in the subset will render.
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
