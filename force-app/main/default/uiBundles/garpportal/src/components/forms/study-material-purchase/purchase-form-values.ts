import type { MaterialQuote, MaterialShipTo } from "@/api/study-materials/types"

/** Every field a string: react-hook-form inputs never carry null. */
export type PurchaseFormValues = {
	company: string
	street: string
	street2: string
	city: string
	state: string
	postalCode: string
	country: string
	phone: string
}

function field(value: string | null | undefined): string {
	return value?.trim() ?? ""
}

/**
 * Seeds the address ONCE from the quote — react-hook-form reads
 * `defaultValues` at mount, which is why the form mounts only after the quote
 * has resolved.
 *
 * A country on record that GARP will not post to is blanked so the picker
 * shows its placeholder and Pay waits for a real choice; with no list at all
 * there is no picker to restrict, so the record's value stands.
 */
export function toPurchaseFormValues(
	quote: Pick<MaterialQuote, "shipTo" | "shippableCountries">,
): PurchaseFormValues {
	const shipTo = quote.shipTo
	const country = field(shipTo?.country)
	const countries = quote.shippableCountries
	const countryAllowed =
		countries.length === 0 ||
		countries.some((name) => name.trim().toLowerCase() === country.toLowerCase())

	return {
		company: field(shipTo?.company),
		street: field(shipTo?.street),
		street2: field(shipTo?.street2),
		city: field(shipTo?.city),
		state: field(shipTo?.state),
		postalCode: field(shipTo?.postalCode),
		country: countryAllowed ? country : "",
		phone: field(shipTo?.phone),
	}
}

/** What travels. Blank stays blank — Apex `String.isBlank` treats "" as absent. */
export function toShipTo(values: PurchaseFormValues): MaterialShipTo {
	return {
		company: values.company.trim(),
		street: values.street.trim(),
		street2: values.street2.trim(),
		city: values.city.trim(),
		state: values.state.trim(),
		postalCode: values.postalCode.trim(),
		country: values.country.trim(),
		phone: values.phone.trim(),
	}
}
