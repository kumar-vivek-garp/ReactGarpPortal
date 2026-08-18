/**
 * Calendar-day arithmetic for Apex ISO dates.
 *
 * Parsed as local on purpose — `new Date("2026-09-24")` is UTC and can shift a
 * day either side of the date line. Mirrors `formatLongDate` in `account-format`.
 */

/** Parses `yyyy-MM-dd` (or an ISO datetime) as a local calendar date. */
export function parseIsoDate(value: string | null | undefined): Date | null {
	if (!value?.trim()) return null
	const [year, month, day] = value.slice(0, 10).split("-").map(Number)
	if (!year || !month || !day) return null
	return new Date(year, month - 1, day)
}

/**
 * Whole days from today to `iso` — negative when the date has passed, `null`
 * when unparseable. Both sides are floored to midnight so partial days never
 * skew the count.
 */
export function daysUntil(iso: string | null | undefined): number | null {
	const date = parseIsoDate(iso)
	if (!date) return null
	const today = new Date()
	today.setHours(0, 0, 0, 0)
	return Math.ceil((date.getTime() - today.getTime()) / 86_400_000)
}
