/**
 * The Affiliate form's react-hook-form values.
 *
 * Kept beside the form rather than in `lib/` because nothing else builds this
 * shape: the request builder in `hooks/use-affiliate-registration.ts` takes
 * these fields one by one, so this type is the form's own vocabulary.
 */
export type AffiliateFormValues = {
	email: string
	firstName: string
	lastName: string
	/** `"<countryCode> (+<phoneCode>)"` — GarpAppv1's own option value format. */
	mobilePhoneCode: string
	mobilePhone: string
	smsPromotionalUpdates: boolean
	/** `RegistrationCountry.countryCode`, not the display name. */
	country: string
	attestPrivacyNotice: boolean
	attestLimitationOfLiability: boolean
	attestReleaseAndWaiver: boolean
}

/**
 * Everything empty, always.
 *
 * There is no seed function and no prefill here, unlike `toFrmFormValues`.
 * This route is guest-only by construction — `redirectMemberToDashboard` sends
 * anyone with a session away before the form mounts — so there is never a
 * contact record to seed from, and the whole point of the form is to create
 * the one that does not exist yet.
 *
 * Every consent starts unticked. A tick carried over from a previous attempt
 * is a tick against a policy nobody read this time, which is worth nothing.
 */
export const EMPTY_AFFILIATE_VALUES: AffiliateFormValues = {
	email: "",
	firstName: "",
	lastName: "",
	mobilePhoneCode: "",
	mobilePhone: "",
	smsPromotionalUpdates: false,
	country: "",
	attestPrivacyNotice: false,
	attestLimitationOfLiability: false,
	attestReleaseAndWaiver: false,
}
