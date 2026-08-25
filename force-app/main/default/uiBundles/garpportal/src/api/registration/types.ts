/**
 * The affiliate slice of the standalone registration module's contract
 * (`GARP_ExamReg_*`, served at `/services/apexrest/examreg/*`).
 *
 * Only the parts an Affiliate membership sign-up touches are modelled here.
 * The same endpoint serves the exam and course programmes, whose payloads
 * carry exam selection, study materials, pricing and payment — none of which
 * an affiliate registration has: its program is `kind: "membership"` with
 * `isAffiliate: true`, priced at a single AFREE line for USD 0.
 */

/** `program` block of the load payload. */
export type AffiliateProgramView = {
	type: string
	/** Always `"membership"` for affiliate — never `"exam"` or `"course"`. */
	kind?: string | null
	formName?: string | null
	contractRecordType?: string | null
	allowMemberPublicRegistration?: boolean | null
	addressVerificationDisabled?: boolean | null
	isTwoPart?: boolean | null
}

/** A country option, with the rules that drive validation on this form. */
export type RegistrationCountry = {
	id: string
	name: string
	/** `Country_Code__c.Country__c` — the value echoed back on the address. */
	countryCode: string
	phoneCode?: string | null
	billingAllowed?: boolean | null
	/**
	 * `Country_Code__c.Compliance__c` is a *tag* ("GDPR", "CASL"), not a
	 * checkbox — Apex reduces any non-blank value to this boolean. When true
	 * the explicit policy checkboxes are required instead of the implicit
	 * "by registering you agree…" notice.
	 */
	compliance?: boolean | null
}

/** Prefilled contact, present only when a session is already signed in. */
export type RegistrationContact = {
	id: string
	firstName?: string | null
	lastName?: string | null
	email?: string | null
	isMember?: boolean | null
}

/** `GET examreg/info?type=affiliate`. */
export type AffiliateRegistrationLoad = {
	program: AffiliateProgramView
	isAuthenticated: boolean
	contact: RegistrationContact | null
	eligibility: { isEligible: boolean; message?: string | null }
	countries: RegistrationCountry[]
}

/** `POST examreg/verifyCustomer` request. */
export type VerifyCustomerRequest = {
	type: string
	email: string
	firstName: string
	lastName: string
}

/** `POST examreg/verifyCustomer` response. */
export type VerifyCustomerResult = {
	isExistingCustomer?: boolean | null
	/**
	 * The email already belongs to a member and this programme does not allow
	 * public registration, so the account cannot be created from here. The
	 * affiliate programme never sets `allowMemberPublicRegistration`, so this
	 * is the expected answer for anyone who already has a GARP login.
	 */
	mustSignIn?: boolean | null
	/** `Form_Data__c` id the register call must quote back. */
	sessionId?: string | null
	contactId?: string | null
	accountId?: string | null
	leadId?: string | null
}

/** `POST examreg/register` request — the affiliate-shaped subset. */
export type AffiliateRegisterRequest = {
	type: string
	sessionId?: string | null
	customer: {
		contactId?: string | null
		accountId?: string | null
		leadId?: string | null
		firstName: string
		lastName: string
		email: string
		/**
		 * Not a bare dial code — the format GarpAppv1 sends is
		 * `"<countryCode> (+<phoneCode>)"`, e.g. `"United States (+1)"`.
		 * Apex reads the digits out of it (they are a VAT-country signal), so
		 * sending only "+1" loses the country half.
		 */
		mobilePhoneCode: string
		mobilePhone: string
		smsPromotionalUpdates: boolean
	}
	billingAddress: { country: string }
	billingAndShippingSame: boolean
	consent: {
		/** Privacy notice + limitation of liability + waiver, combined. */
		privacyPolicy: boolean
	}
}

/** `POST examreg/register` response. */
export type RegisterResult = {
	orderId?: string | null
	orderNumber?: string | null
	contactId?: string | null
	accountId?: string | null
	/** Always 0 for affiliate — the AFREE line is a zero-price product. */
	total?: number | null
	/** Always false for affiliate — there is nothing to pay. */
	hasBilling?: boolean | null
}
