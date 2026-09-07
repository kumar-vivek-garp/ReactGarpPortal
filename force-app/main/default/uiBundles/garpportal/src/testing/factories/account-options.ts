/**
 * `GET /memberportal/options` fixtures (`GARP_Portal_OptionsService`). The
 * address and phone-code selects hydrate from here, so the defaults carry one
 * usable country and the legacy-formatted phone-code string the org stores.
 */

import type {
	AccountOptionsView,
	PortalCountryOption,
} from "@/api/account/types"

export function portalCountryOption(
	overrides: Partial<PortalCountryOption> = {},
): PortalCountryOption {
	return {
		name: "United States",
		code: "US",
		phoneCode: "1",
		postalCodeRequired: true,
		provinceRequired: true,
		provinces: [],
		...overrides,
	}
}

export function accountOptionsView(
	overrides: Partial<AccountOptionsView> = {},
): AccountOptionsView {
	return {
		picklists: {},
		chapters: [],
		mobilePhoneLocations: ["United States (+1)", "United Kingdom (+44)"],
		countries: [
			portalCountryOption(),
			portalCountryOption({ name: "United Kingdom", code: "GB", phoneCode: "44" }),
		],
		schools: [],
		organizations: [],
		workingYears: [],
		graduationYears: [],
		...overrides,
	}
}
