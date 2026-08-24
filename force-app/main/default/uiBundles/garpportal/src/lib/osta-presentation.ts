/**
 * `yyyy-MM-dd` (what `<input type="date">` speaks) to `MM/dd/yyyy` (what Apex
 * parses).
 *
 * Converted by hand rather than through `Date`: constructing a Date from the
 * ISO form reads it as UTC and can shift the day backwards for anyone west of
 * Greenwich, which on an expiry date is the difference between a valid ID and
 * an expired one.
 *
 * Anything that is not a plain ISO date is passed through untouched, so a
 * value already in `MM/dd/yyyy` survives and Apex's own parse error surfaces
 * for genuine rubbish.
 */
export function toUsDateString(value: string): string {
	const match = value.trim().match(/^(\d{4})-(\d{2})-(\d{2})$/)
	if (!match) return value.trim()
	const [, year, month, day] = match
	return `${month}/${day}/${year}`
}

/**
 * `MM/dd/yyyy` (what `GET osta` returns) to `yyyy-MM-dd` (what
 * `<input type="date">` binds to).
 *
 * The inverse of `toUsDateString`, and split apart by hand for the same
 * reason: a round trip through `Date` re-reads the value in UTC and can move
 * an expiry date a day earlier for anyone west of Greenwich.
 */
export function toDateInputValue(value: string | null | undefined): string {
	const match = value?.trim().match(/^(\d{2})\/(\d{2})\/(\d{4})$/)
	if (!match) return ""
	const [, month, day, year] = match
	return `${year}-${month}-${day}`
}
