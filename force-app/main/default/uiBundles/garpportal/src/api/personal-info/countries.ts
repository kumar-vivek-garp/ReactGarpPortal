import type { AccountOptionsView } from "@/api/account/types"
import type { CountryOption, PhoneCodeOption } from "@/api/personal-info/types"

/**
 * Country choices for the address selects, from `GET /memberportal/options`.
 * Server order is kept (Apex orders by country name); duplicate names are
 * dropped so Radix never sees two items with one value.
 */
export function toCountryOptions(options: AccountOptionsView): CountryOption[] {
	const seen = new Set<string>()
	const result: CountryOption[] = []
	for (const country of options.countries) {
		const value = country.name?.trim() ?? ""
		if (!value || seen.has(value)) continue
		seen.add(value)
		result.push({
			label: value,
			value,
			phoneCode: country.phoneCode?.trim() || null,
		})
	}
	return result
}

/**
 * Phone-code choices, verbatim from `mobilePhoneLocations` — the exact
 * `"United States (+1)"` strings the org stores in `Mobile_Phone_Code__c`,
 * so a stored value always matches an option.
 */
export function toPhoneCodeOptions(options: AccountOptionsView): PhoneCodeOption[] {
	const seen = new Set<string>()
	const result: PhoneCodeOption[] = []
	for (const location of options.mobilePhoneLocations) {
		const value = location.trim()
		if (!value || seen.has(value)) continue
		seen.add(value)
		result.push({ label: value, value })
	}
	return result
}
