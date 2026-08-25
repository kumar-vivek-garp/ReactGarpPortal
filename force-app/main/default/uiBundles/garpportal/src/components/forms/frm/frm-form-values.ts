import type { PersonalInfoEditData } from "@/api/personal-info/types"

/** The typed fields react-hook-form owns on the FRM registration form. */
export type FrmFormValues = {
	firstName: string
	lastName: string
	email: string
	/** `"<countryCode> (+<phoneCode>)"` — Apex reads the digits back out. */
	mobilePhoneCode: string
	mobilePhone: string
	/** Billing country. Decides tax, shipping and payment options. */
	country: string
}

export const EMPTY_FRM_FORM_VALUES: FrmFormValues = {
	firstName: "",
	lastName: "",
	email: "",
	mobilePhoneCode: "",
	mobilePhone: "",
	country: "",
}

/**
 * Seed the form from the member's own record.
 *
 * Taken from `personal-info` rather than from the registration payload's own
 * `contact`, for three reasons: it is the portal's canonical member data, it
 * already carries `mobilePhoneCode` in the composite format the registration
 * request wants, and it resolves on local dev — the registration endpoint sees
 * a non-community user there and returns `contact: null`.
 *
 * The billing country comes from the member's billing address, which is what
 * their fees were last calculated against.
 */
export function toFrmFormValues(data: PersonalInfoEditData): FrmFormValues {
	return {
		firstName: data.firstName ?? "",
		lastName: data.lastName ?? "",
		email: data.email ?? "",
		mobilePhoneCode: data.mobilePhoneCode ?? "",
		mobilePhone: data.mobilePhone ?? "",
		country: data.billing?.country ?? "",
	}
}
