/**
 * Typed fixtures for the affiliate slice of the registration contract
 * (`api/registration/types.ts`). Typed against the api types so a contract
 * drift breaks compilation, not just runtime.
 */

import type {
	AffiliateRegistrationLoad,
	RegisterResult,
	RegistrationCountry,
} from "@/api/registration"

export function registrationCountry(
	overrides: Partial<RegistrationCountry> = {},
): RegistrationCountry {
	return {
		id: "cc-us",
		name: "United States",
		countryCode: "United States",
		phoneCode: "1",
		compliance: false,
		...overrides,
	}
}

/**
 * Three countries exercising every rule the form branches on: a plain one, a
 * compliance-tagged one (GDPR → explicit policy ticks), and one with no dial
 * code (must not appear among the phone-code options).
 */
export function affiliateCountries(): RegistrationCountry[] {
	return [
		registrationCountry(),
		registrationCountry({
			id: "cc-de",
			name: "Germany",
			countryCode: "Germany",
			phoneCode: "49",
			compliance: true,
		}),
		registrationCountry({
			id: "cc-xx",
			name: "Atlantis",
			countryCode: "Atlantis",
			phoneCode: null,
		}),
	]
}

export function affiliateLoad(
	overrides: Partial<AffiliateRegistrationLoad> = {},
): AffiliateRegistrationLoad {
	return {
		program: { type: "affiliate", kind: "membership" },
		isAuthenticated: false,
		contact: null,
		eligibility: { isEligible: true },
		countries: affiliateCountries(),
		...overrides,
	}
}

export function affiliateRegisterResult(
	overrides: Partial<RegisterResult> = {},
): RegisterResult {
	return {
		orderId: "801-aff",
		orderNumber: "A-1001",
		contactId: "003-aff",
		accountId: "001-aff",
		total: 0,
		hasBilling: false,
		...overrides,
	}
}
