import { type ClassValue, clsx } from "clsx"
import { extendTailwindMerge } from "tailwind-merge"

/**
 * tailwind-merge cannot tell that our semantic type roles (`--text-*` in
 * `styles/theme.css`) are font sizes — by default it classifies `text-body`
 * as a text *color* and silently drops a real color (e.g. a button variant's
 * `text-primary-foreground`) when the two meet in one class list. Registering
 * them on the `text` theme scale keeps font-size and text-color independent.
 * Keep this list in sync with the `--text-*` tokens in `styles/theme.css`.
 */
const twMerge = extendTailwindMerge({
	extend: {
		theme: {
			text: ["caption", "body", "nav", "section", "title"],
		},
	},
})

export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs))
}
