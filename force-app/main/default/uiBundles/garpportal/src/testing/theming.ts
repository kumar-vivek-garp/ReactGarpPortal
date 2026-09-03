/**
 * Matches Tailwind's stock palette utilities (`bg-blue-500`, `text-red-600`, …),
 * which `theming.md` bans in favour of token-backed classes. Assert that a
 * component's `className` does NOT match this.
 */
export const STOCK_PALETTE =
	/\b(?:text|bg|border)-(?:slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|sky|blue|indigo|violet|purple|fuchsia|rose)-\d{2,3}\b/
