import type { PortalAddress } from "@/api/account/types"

/**
 * Formats an ISO date (yyyy-MM-dd) as a long local date.
 * Parsed as local on purpose — `new Date("2026-09-24")` is UTC and can shift a day.
 */
export function formatLongDate(iso: string | null | undefined): string | null {
	if (!iso) return null
	const [year, month, day] = iso.split("-").map(Number)
	if (!year || !month || !day) return null
	return new Date(year, month - 1, day).toLocaleDateString(undefined, {
		year: "numeric",
		month: "long",
		day: "numeric",
	})
}

/** Formats an ISO datetime (from Apex) as a readable local date and time. */
export function formatDateTime(iso: string | null | undefined): string | null {
	if (!iso) return null
	const parsed = new Date(iso)
	if (Number.isNaN(parsed.getTime())) return null
	return parsed.toLocaleString(undefined, {
		year: "numeric",
		month: "long",
		day: "numeric",
		hour: "numeric",
		minute: "2-digit",
	})
}

/**
 * Formats a currency amount. Falls back to a plain number when the ISO code is
 * missing or not one the runtime recognises, rather than throwing.
 */
export function formatMoney(
	amount: number | null | undefined,
	currencyCode: string | null | undefined,
): string | null {
	if (amount === null || amount === undefined) return null
	if (currencyCode) {
		try {
			return new Intl.NumberFormat(undefined, {
				style: "currency",
				currency: currencyCode,
			}).format(amount)
		} catch {
			// Unrecognised currency code — fall through.
		}
	}
	return amount.toLocaleString(undefined, { minimumFractionDigits: 2 })
}

/** Address as display lines, skipping blank parts. */
export function addressLines(address: PortalAddress | null | undefined): string[] {
	if (!address || address.isEmpty) return []
	const cityLine = [address.city, address.state].filter(Boolean).join(", ")
	return [
		address.street,
		[cityLine, address.postalCode].filter(Boolean).join(" "),
		address.country,
	]
		.map((line) => (line ?? "").trim())
		.filter((line) => line.length > 0)
}
