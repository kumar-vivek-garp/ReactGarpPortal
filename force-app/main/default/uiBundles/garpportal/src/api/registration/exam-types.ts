/**
 * The exam / course side of the registration contract (`GARP_ExamReg_Dto`).
 *
 * One shape serves every non-membership programme — frm, scr, riskai, raij
 * (`kind: "exam"`) and frr, frr25, ffr, micro (`kind: "course"`). The affiliate
 * membership slice lives in `./types` and shares the country, contact and
 * verify shapes with this file.
 */

import type {
	RegistrationContact,
	RegistrationCountry,
	VerifyCustomerResult,
} from "@/api/registration/types"

export type { RegistrationContact, RegistrationCountry, VerifyCustomerResult }

/** `program.kind` — decides which sections the form renders. */
export type ProgramKind = "exam" | "course" | "membership"

export type ExamProgramView = {
	type: string
	kind?: ProgramKind | null
	courseCode?: string | null
	formName?: string | null
	contractRecordType?: string | null
	allowMemberPublicRegistration?: boolean | null
	/** When true, `verifyAddress` is skipped before `register`. */
	addressVerificationDisabled?: boolean | null
	/**
	 * Decorative. Part activity is derived from the `partsAvailable` STRINGS,
	 * not from this flag — see `lib/registration-presentation`. Kept because
	 * the payload sends it and dropping it would hide that.
	 */
	isTwoPart?: boolean | null
}

/** An exam site. `isOSTA` is what makes the China identity block appear. */
export type ExamSiteView = {
	id: string
	name: string
	/** China test centres (provider ATA). */
	isOSTA?: boolean | null
	isVAT?: boolean | null
	provider?: string | null
}

/** One `Exam_Rate__c` row: a sitting at a price resolved for THIS customer. */
export type ExamAdminView = {
	/** `Exam_Rate__c` Id — echoed back as the part's `rateId`. */
	id: string
	adminId?: string | null
	name?: string | null
	amount?: number | null
	/** `Early` | `Standard`. */
	priceWindow?: string | null
	/** Display string, e.g. "November 14 - 20, 2026". */
	examDates?: string | null
	/** Drives the "Part II cannot be taken before Part I" rule. */
	examStartEpoch?: number | null
	sites: ExamSiteView[]
}

export type ExamPartView = {
	key: "part1" | "part2"
	title?: string | null
	admins: ExamAdminView[]
}

export type ExamSelectionView = {
	/** e.g. ["FRM Exam Part I", "FRM Exam Part I and FRM Exam Part II"]. */
	partsAvailable: string[]
	parts: ExamPartView[]
}

export type StudyMaterialView = {
	productCode: string
	title?: string | null
	description?: string | null
	imageUrl?: string | null
	price?: number | null
	/** Included with registration — added server-side, never sent. */
	isComp?: boolean | null
	/** Included but the candidate must ADD it (they still pay shipping). */
	isCompSelectable?: boolean | null
	isOwned?: boolean | null
	isAvailable?: boolean | null
	isShippable?: boolean | null
	isDigital?: boolean | null
	/** `Part 1` | `Part 2` | null — filtered against the active parts. */
	relatedPart?: string | null
}

/** `GET examreg/info?type=&regCode=&courseCode=`. */
export type ExamRegistrationLoad = {
	program: ExamProgramView
	isAuthenticated: boolean
	contact: RegistrationContact | null
	/**
	 * An unusable reg code answers HTTP 200 with `isEligible: false` and no
	 * `examSelection` — render the message, do not treat it as an error.
	 */
	eligibility: { isEligible: boolean; message?: string | null }
	/** null for course and membership programmes. */
	examSelection: ExamSelectionView | null
	studyMaterials: StudyMaterialView[]
	countries: RegistrationCountry[]
	stripe?: { useStripe?: boolean | null } | null
	membershipOffer?: { productCode?: string; amount?: number } | null
	/**
	 * The Risk.net (MEMR) add-on — membership programmes only. Priced
	 * server-side by `GARP_ExamReg_PricingService.riskNetAmount`: `months` is
	 * the membership months left plus the 12 being bought, and `amount` is a
	 * flat 100 for a plain 12 months or `months × unit price` otherwise.
	 */
	riskNetOffer?: {
		productCode?: string
		amount?: number
		months?: number
	} | null
	affiliateCode?: string | null
	/** Typeahead suggestions for the OSTA company/school fields. */
	companies?: string[] | null
	schools?: string[] | null
}

/* ===================== fees ===================== */

/**
 * One part's choice. Sent as `null` — never `{rateId: "", siteId: ""}` — when
 * the part is not selected: Apex casts these to Ids and answers
 * `500 "Invalid id: "` on empty strings.
 */
export type PartChoice = {
	rateId: string
	siteId: string | null
}

export type SelectionInput = {
	partSelected: string | null
	part1: PartChoice | null
	part2: PartChoice | null
}

export type AddressInput = {
	company: string
	street1: string
	street2: string
	street3: string
	city: string
	province: string
	postalCode: string
	/** `RegistrationCountry.countryCode`, which is the country NAME. */
	country: string
	phone: string
}

export type FeesRequest = {
	type: string
	courseCode?: string | null
	regCode?: string | null
	membershipSelected: boolean
	riskNetSelected: boolean
	contactId?: string | null
	selection: SelectionInput
	/** Product codes of SELECTED materials only — comp items are server-added. */
	materials: string[]
	paymentType: string | null
	billingAddress: AddressInput
	shippingAddress: AddressInput
	billingAndShippingSame: boolean
	autoRenew: boolean
}

export type FeeLine = {
	productCode?: string | null
	name?: string | null
	amount?: number | null
	quantity?: number | null
	isComp?: boolean | null
	isEnrollment?: boolean | null
	isShipping?: boolean | null
	isTax?: boolean | null
}

export type FeesResult = {
	lines: FeeLine[]
	subTotal?: number | null
	vatAmount?: number | null
	vatLabel?: string | null
	njSalesTax?: number | null
	total?: number | null
	currencyCode?: string | null
	/** False means nothing to pay — the submit button becomes "Register". */
	hasBilling?: boolean | null
	needsShipping?: boolean | null
	hasCompMembership?: boolean | null
	compMembershipTermMonths?: number | null
}

/** `GET examreg/options` — company/school typeaheads, fetched lazily. */
export type RegistrationOptions = {
	companies: string[]
	schools: string[]
}

/* ===================== verify / register ===================== */

/** UTM attribution, read once from the landing URL and carried to the order. */
export type RegistrationTracking = {
	utmCampaign?: string | null
	utmContent?: string | null
	utmMedium?: string | null
	utmSource?: string | null
	utmTerm?: string | null
	trackCta?: string | null
}

export type ExamVerifyCustomerRequest = {
	type: string
	courseCode?: string | null
	email: string
	firstName: string
	lastName: string
	tracking?: RegistrationTracking
}

export type CustomerInput = {
	contactId?: string | null
	accountId?: string | null
	leadId?: string | null
	firstName: string
	lastName: string
	email: string
	title: string
	company: string
}

/**
 * The China identity block, sent only when a chosen exam centre is an OSTA
 * site.
 *
 * Apex applies NO validation to any of this — it writes the fields to the
 * Contact whenever `idNumber` is present. Every rule that protects this data
 * is client-side, which is why `idFormatError` is ported exactly rather than
 * approximated.
 */
export type PersonalInput = {
	gender: string
	idType: string
	idLocation: string
	idNumber: string
	/** Lower `d` — the Apex field really is `nameOnId`. */
	nameOnId: string
	ostaConsent: boolean
	fullNameInChinese: string
	/** `yyyy-MM-dd`, or null. */
	dateOfBirth: string | null
	idExpireDate: string | null
	phone: string
	workStatus: string
	companyName: string
	schoolName: string
	studentStatus: string
	degreeName: string
	businessEmail: string
	professionalLevel: string
	jobFunction: string
	riskSpecialty: string
}

/**
 * Consent, stored by Apex as timestamps on the Exam_Attempt__c.
 *
 * `privacyPolicy` carries the policy attestation (privacy notice, code of
 * conduct, limitation of liability, waiver and release, refunds) — one tick
 * since the 2027 designs, where it was previously three, and only in a
 * GDPR/CASL country. `examPolicy` is the exam-policy AND
 * candidate-responsibility acknowledgements together — Apex refuses the
 * registration outright unless it is true.
 *
 * `marketingEmails` and `examPrepProviders` are the two opt-INS the designs
 * added. **Both are provisional names**: `GARP_ExamReg_Dto.ConsentInput` has
 * no member for either, and `JSON.deserialize` drops unknown members silently,
 * so today they travel and are discarded. They are sent anyway so the wire
 * shape is right the moment the backend adds them — and so nobody later
 * concludes the answer was never collected. Confirm the names with the backend
 * team before treating either as stored.
 */
export type ConsentInput = {
	privacyPolicy: boolean
	examPolicy: boolean
	osta: boolean
	releaseExamResults: boolean
	marketingEmails?: boolean
	examPrepProviders?: boolean
}

/** The body for BOTH `verifyAddress` and `register` — they are identical. */
export type ExamRegisterRequest = {
	type: string
	courseCode?: string | null
	regCode?: string | null
	membershipSelected: boolean
	riskNetSelected: boolean
	/** `Form_Data__c` id from `verifyCustomer`. */
	sessionId?: string | null
	/**
	 * Deferred flow only: the `Order_History__c` row this submission retries,
	 * set when the form was rebuilt from a `resume`. The server reuses that row
	 * (same REG- number, its old Stripe session retired) instead of stranding
	 * it at Awaiting Payment with a session nobody will pay. Ignored unless it
	 * points at a still-payable row with no order behind it.
	 */
	resumeStagedId?: string | null
	customer: CustomerInput
	personal: PersonalInput | null
	selection: SelectionInput
	materials: string[]
	paymentType: string | null
	billingAddress: AddressInput
	shippingAddress: AddressInput
	billingAndShippingSame: boolean
	autoRenew: boolean
	consent: ConsentInput
}

/**
 * `Order_History__c.Status__c` under the deferred flow, as `paymentStatus`
 * reports it while the browser polls on a staged id.
 */
export type StagedRegistrationStatus =
	| "Awaiting Payment"
	| "Paid"
	| "Payment Failed"
	| "Failed"
	| "Materialized"
	| "Abandoned"

/**
 * Two shapes, decided server-side by `Stripe_Auth_Configuration__mdt`
 * `.Is_Stripe_Order_History__c`:
 *
 * - Immediate (flag off, and always for Wire/ACH/free): the order exists —
 *   `orderId` / `orderNumber` are set.
 * - Deferred (flag on, card payments): nothing but an `Order_History__c` row
 *   holding the payload was written — `stagedId` / `registrationRef` are set
 *   and `orderId` / `orderNumber` are null. The order is written by the
 *   Stripe webhook once payment lands. `checkout` and `paymentStatus` take
 *   either id and route on its type.
 */
export type ExamRegisterResult = {
	orderId?: string | null
	orderNumber?: string | null
	/** Deferred flow: the staged row's id — goes to `checkout` in place of `orderId`. */
	stagedId?: string | null
	/** Deferred flow: the REG- auto-number shown to the candidate. */
	registrationRef?: string | null
	/** First Exam_Attempt__c id. */
	registrationId?: string | null
	contractId?: string | null
	contactId?: string | null
	accountId?: string | null
	total?: number | null
	/** False means nothing to pay — no checkout, no payOrder. */
	hasBilling?: boolean | null
}

/**
 * `verifyAddress` checks the COUNTRY only — that it is present, known, and
 * permits billing / shipping. Street, city and postal code are never seen by
 * the server, so their rules live entirely in the form.
 */
export type AddressCheckResult = {
	billingValid?: boolean | null
	billingAllowed?: boolean | null
	shippingValid?: boolean | null
	shippingAllowed?: boolean | null
	message?: string | null
}

/** `POST checkout` — a Stripe-HOSTED session, not the Experience Cloud page. */
export type CheckoutResult = {
	checkoutUrl?: string | null
	orderNumber?: string | null
	orderId?: string | null
	orderName?: string | null
	accountId?: string | null
	/** Deferred flow: echoed back for a staged checkout. */
	stagedId?: string | null
	registrationRef?: string | null
	isError?: boolean | null
	msg?: string | null
}

export type PaymentStatusResult = {
	isOrderFound?: boolean | null
	isPaymentFound?: boolean | null
	isPaymentSuccess?: boolean | null
	/** The order was cancelled — the registration did not survive. */
	isOrderRolledback?: boolean | null
	paymentType?: string | null
	/**
	 * Deferred flow only — the browser is polling on a staged id. `Paid` and
	 * `Materialized` are both success; `Payment Failed` is retryable (the row
	 * is still payable); `Failed` means paid but the records could not be
	 * written, which needs a human.
	 */
	registrationStatus?: StagedRegistrationStatus | string | null
	registrationRef?: string | null
	/** The order exists AND has closed — the point of being genuinely registered. */
	isComplete?: boolean | null
	orderId?: string | null
	orderNumber?: string | null
	/** `Order_History__c.Error__c` on a Payment Failed / Failed row. */
	errorMessage?: string | null
}

/** `GET resume?stagedId=` — the payload a staged registration was created from. */
export type ResumeResult = {
	resumable: boolean
	payload: ExamRegisterRequest | null
	registrationRef: string | null
	stagedId?: string | null
	/** Epoch ms when the Stripe session lapses; not resumable after. */
	expiresAt?: number | null
}

/** `GET demographics` — picklists for the post-registration survey. */
export type DemographicsOptions = {
	picklists: Record<string, Array<{ label: string; value: string }>>
	workingYears: string[]
	graduationYears: string[]
}

/**
 * `POST demographics` — `key` is the staged or order id the caller's own
 * registration returned; the server resolves the contact from that record.
 */
export type DemographicsSaveRequest = {
	key: string
	values: Record<string, string | boolean | null>
}

export type DemographicsSaveResult = {
	saved: boolean
	rejected: string[]
}
