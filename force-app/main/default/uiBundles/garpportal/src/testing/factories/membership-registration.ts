/**
 * Typed fixtures for the MEMBERSHIP programme on the exam-registration
 * contract: `GET examreg/info?type=mem` and the cart `POST examreg/fees`
 * prices for it. Typed against the api types so a contract drift breaks
 * compilation, not just runtime.
 */

import type {
	ExamRegistrationLoad,
	FeeLine,
	FeesResult,
	RegistrationCountry,
} from "@/api/registration/exam-types"

/** MEMI / MEMC in the org's own pricebook; MEMR is 8.35 a month. */
export const MEMBERSHIP_PRICE = 195
export const MEMBERSHIP_CERTIFIED_PRICE = 150
/** A plain 12 months of Risk.net is a flat 100; 24 months is 24 × 8.35. */
export const RISK_NET_PRICE = 100
export const PROCESSING_FEE = 50

/** Card, wire and ACH all permitted, with the province/postal rules a US address needs. */
export function membershipCountry(): RegistrationCountry {
	return {
		id: "cc-us",
		name: "United States",
		countryCode: "United States",
		phoneCode: "1",
		creditCardAllowed: true,
		wireAllowed: true,
		achAllowed: true,
		provinces: [{ name: "NJ" }, { name: "NY" }],
		provinceRequired: true,
		postalCodeRequired: true,
	}
}

/**
 * The membership load: no exam selection, no study materials, the Risk.net
 * add-on priced for a plain year. Guest by default; pass `contact` and
 * `isAuthenticated` for a member.
 */
export function membershipLoad(
	overrides: Partial<ExamRegistrationLoad> = {},
): ExamRegistrationLoad {
	return {
		program: {
			type: "mem",
			kind: "membership",
			formName: "membership-individual",
			allowMemberPublicRegistration: false,
		},
		isAuthenticated: false,
		contact: null,
		eligibility: { isEligible: true },
		examSelection: null,
		studyMaterials: [],
		countries: [membershipCountry()],
		stripe: { useStripe: true },
		riskNetOffer: { productCode: "MEMR", amount: RISK_NET_PRICE, months: 12 },
		...overrides,
	}
}

type MembershipFeesOptions = {
	/** The Risk.net line is in the cart. */
	riskNet?: boolean
	/** Wire/ACH: Apex adds the PRFEE line. */
	offline?: boolean
	/** A certified holder is quoted MEMC rather than MEMI. */
	certified?: boolean
}

/**
 * The priced membership cart, line for line as `GARP_ExamReg_PricingService`
 * builds it: the membership as the MAIN product (not an upsell), then the
 * add-on, then the offline processing fee.
 */
export function membershipFeesResult({
	riskNet = false,
	offline = false,
	certified = false,
}: MembershipFeesOptions = {}): FeesResult {
	const lines: FeeLine[] = [
		certified
			? {
					productCode: "MEMC",
					name: "Individual Membership (Certified)",
					amount: MEMBERSHIP_CERTIFIED_PRICE,
					quantity: 1,
				}
			: {
					productCode: "MEMI",
					name: "Individual Membership",
					amount: MEMBERSHIP_PRICE,
					quantity: 1,
				},
	]
	if (riskNet) {
		lines.push({
			productCode: "MEMR",
			name: "Risk.net Membership",
			amount: RISK_NET_PRICE,
			quantity: 1,
		})
	}
	if (offline) {
		lines.push({
			productCode: "PRFEE",
			name: "Processing Fee",
			amount: PROCESSING_FEE,
			quantity: 1,
		})
	}
	const total = lines.reduce((sum, line) => sum + (line.amount ?? 0), 0)
	return {
		lines,
		subTotal: total,
		total,
		currencyCode: "USD",
		hasBilling: total > 0,
	}
}
