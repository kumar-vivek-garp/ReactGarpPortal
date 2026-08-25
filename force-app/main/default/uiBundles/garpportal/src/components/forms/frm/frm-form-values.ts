import type { PersonalInfoEditData } from "@/api/personal-info/types"
import type { RegistrationCountry } from "@/api/registration/exam-types"
import {
	emptyAddress,
	toRegistrationAddress,
	toRegistrationPhoneCode,
	type RegistrationAddress,
} from "@/lib/registration-payloads"

/** The China identity block. Only collected when an OSTA centre is chosen. */
export type FrmOstaValues = {
	idType: string
	idLocation: string
	idNumber: string
	/** Client-side only — never sent, it exists to catch a typo. */
	confirmIdNumber: string
	nameOnId: string
	/** `yyyy-MM-dd` from the date input. */
	idExpireDate: string
	dateOfBirth: string
	gender: string
	fullNameInChinese: string
	phone: string
	workStatus: string
	company: string
	studentStatus: string
	schoolName: string
	degreeName: string
	ostaConsent: boolean
}

/** The typed fields react-hook-form owns on the FRM registration form. */
export type FrmFormValues = {
	firstName: string
	lastName: string
	email: string
	/** `"<countryCode> (+<phoneCode>)"` — Apex reads the digits back out. */
	mobilePhoneCode: string
	mobilePhone: string
	smsPromotionalUpdates: boolean

	/**
	 * Billing country, shown as "Location" when the address cards are hidden.
	 *
	 * Kept alongside `billing.country` rather than derived from it because a
	 * card order never shows an address card at all, and something still has to
	 * establish the country — it decides tax, shipping and which payment types
	 * are even offered.
	 */
	country: string

	paymentType: string
	billing: RegistrationAddress
	shipping: RegistrationAddress
	billingAndShippingSame: boolean
	autoRenew: boolean

	/** Both required by Apex, collapsed into one `consent.examPolicy`. */
	candidateResponsibility: boolean
	examPolicy: boolean

	/** Only asked for in GDPR/CASL countries; collapse into `privacyPolicy`. */
	attestPrivacyNotice: boolean
	attestLimitationOfLiability: boolean
	attestReleaseAndWaiver: boolean

	osta: FrmOstaValues
}

export const EMPTY_FRM_OSTA_VALUES: FrmOstaValues = {
	idType: "Passport",
	idLocation: "",
	idNumber: "",
	confirmIdNumber: "",
	nameOnId: "",
	idExpireDate: "",
	dateOfBirth: "",
	gender: "",
	fullNameInChinese: "",
	phone: "",
	workStatus: "Working",
	company: "",
	studentStatus: "Not In School",
	schoolName: "",
	degreeName: "",
	ostaConsent: false,
}

export const EMPTY_FRM_FORM_VALUES: FrmFormValues = {
	firstName: "",
	lastName: "",
	email: "",
	mobilePhoneCode: "",
	mobilePhone: "",
	smsPromotionalUpdates: false,
	country: "",
	paymentType: "",
	billing: emptyAddress(),
	shipping: emptyAddress(),
	billingAndShippingSame: true,
	autoRenew: false,
	candidateResponsibility: false,
	examPolicy: false,
	attestPrivacyNotice: false,
	attestLimitationOfLiability: false,
	attestReleaseAndWaiver: false,
	osta: EMPTY_FRM_OSTA_VALUES,
}

/**
 * Seed the form from the member's own record.
 *
 * Taken from `personal-info` rather than the registration payload's own
 * `contact`, because it is the portal's canonical member data, it already
 * carries a billing address, and it resolves on local dev — the registration
 * endpoint sees a non-community user there and returns `contact: null`.
 *
 * Two translations are unavoidable. The address field names differ between the
 * two systems (`address1` vs `street1`, `state` vs `province`), and the phone
 * code is stored bare (`"+1"`) where the registration payload wants the
 * composite `"United States (+1)"` — Apex reads a country out of that field,
 * not just digits.
 *
 * Every consent starts unticked. A tick recorded against a policy the
 * candidate did not read this time is worthless.
 */
export function toFrmFormValues(
	data: PersonalInfoEditData | null,
	countries: RegistrationCountry[],
): FrmFormValues {
	if (!data) return EMPTY_FRM_FORM_VALUES

	const billing = toRegistrationAddress(data.billing)

	return {
		...EMPTY_FRM_FORM_VALUES,
		firstName: data.firstName ?? "",
		lastName: data.lastName ?? "",
		email: data.email ?? "",
		mobilePhoneCode: toRegistrationPhoneCode(
			data.mobilePhoneCode,
			data.billing?.country,
			countries,
		),
		mobilePhone: data.mobilePhone ?? "",
		country: billing.country,
		billing,
		shipping: data.sameAsBilling
			? billing
			: toRegistrationAddress(data.mailing),
		billingAndShippingSame: data.sameAsBilling !== false,
	}
}
