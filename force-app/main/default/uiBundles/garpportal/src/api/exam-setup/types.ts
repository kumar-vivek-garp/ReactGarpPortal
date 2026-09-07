import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring `GARP_Portal_ExamSetupService` — the wizard that answers
 * "when and where will you sit this exam?" and, when the answer moves the
 * sitting to a different administration, defers it.
 *
 * There is no separate deferral feature: choosing a different administration
 * IS the deferral. Apex prices it as a "Standard exam administration change
 * fee" and stamps `Deferral_Subtype__c = 'Deferral Standard'` on the
 * modification it raises.
 */

/** Accepted by Apex `normalise` — the same set as `programDetail`. */
export type ExamSetupProgramType =
	| "frm"
	| "erp"
	| "scr"
	| "raij"
	| "rai"
	| "riskai"

/** A site the member can pick for a given administration. */
export type ExamSite = {
	id: string | null
	name: string | null
	/** True on the site the member currently sits at. */
	isSelected: boolean
}

/** One administration option, with the sites open under it. */
export type ExamAdmin = {
	id: string | null
	name: string | null
	/** True on the administration the member is currently in. */
	isSelected: boolean
	examSites: ExamSite[] | null
}

/**
 * Step two's form and its current values, returned alongside step one so the
 * wizard advances without a second round trip — nothing on step two depends on
 * what was chosen on step one.
 *
 * **Dates here are ISO `yyyy-MM-dd`** (what `<input type="date">` binds to).
 * The WRITE shape below wants `MM/dd/yyyy`. See `ExamSetupIdInput`.
 */
export type ExamSetupIdInfo = {
	/** Turns on the mainland-China block. */
	isOSTA: boolean | null
	/** FRM sites demand a government ID; the form marks those fields required. */
	isIDRequired: boolean | null
	idName: string | null
	/**
	 * On read this is the **full** number for an OSTA sitting
	 * (`OSTA_Full_ID__c`) and the **last five characters** otherwise
	 * (`ID_Number__c`). Apex picks which by `isOSTA`.
	 */
	idNumber: string | null
	/**
	 * Apex reads `Driver's License` out as `Driver License`. Normalise before
	 * binding it to a select whose options carry the apostrophe.
	 */
	idType: string | null
	/** ISO `yyyy-MM-dd`. */
	idExpireDate: string | null
	mobilePhoneLocation: string | null
	mobilePhoneNumber: string | null

	/* --- OSTA (mainland-China sites) --- */
	ostaIDLocation: string | null
	ostaGender: string | null
	ostaFullNameInChinese: string | null
	/** ISO `yyyy-MM-dd`. */
	ostaDateOfBirth: string | null
	ostaPhoneNumber: string | null
	ostaCurrentWorkingStatus: string | null
	ostaCompany: string | null
	ostaCurrentSchoolStatus: string | null
	ostaSchool: string | null
	ostaDegreeProgramName: string | null

	/** Picklist values of `Contact.Mobile_Phone_Code__c`, e.g. "United States (+1)". */
	mobilePhoneLocations: string[] | null
}

/**
 * `GET examSetup?programType=`.
 *
 * `allowAdminModPart1/2` false means the administration is fixed for that part
 * — the site may still be changeable, so the select is rendered read-only
 * rather than the whole section being hidden.
 */
export type ExamSetupView = {
	statusMessage: string | null
	statusCode: number
	allowAdminModPart1: boolean | null
	allowAdminModPart2: boolean | null
	examPart1SelectionInfo: ExamAdmin[] | null
	examPart2SelectionInfo: ExamAdmin[] | null
	idInfo: ExamSetupIdInfo | null
}

/**
 * The ID half of `POST examSetupId`.
 *
 * **Dates are `MM/dd/yyyy` here**, unlike the ISO values `ExamSetupIdInfo`
 * returns. Convert with `toUsDateString` on the way out.
 *
 * **Which keys travel depends on the programme**, not on what the member typed
 * — see `toIdInput`. The name and mobile always go; the government-ID trio only
 * for FRM; the OSTA block only for an FRM candidate at a mainland-China centre.
 * Apex guards every write with `!= null`, so the five free-text OSTA fields are
 * sent as `null` when blank rather than as `""`, which would overwrite the
 * Contact with an empty value.
 *
 * There is deliberately no `ostaConsent` here: the form requires the tick, but
 * Apex has no field for it on this action.
 */
export type ExamSetupIdInput = {
	idName?: string
	idNumber?: string
	idType?: string
	/** `MM/dd/yyyy`. */
	idExpireDate?: string
	mobilePhoneLocation?: string
	mobilePhoneNumber?: string

	ostaIDLocation?: string
	ostaGender?: string
	ostaFullNameInChinese?: string
	/** `MM/dd/yyyy`. */
	ostaDateOfBirth?: string
	ostaPhoneNumber?: string
	/* Optional free text — `null`, never `""`, when the member left it blank. */
	ostaCurrentWorkingStatus?: string | null
	ostaCompany?: string | null
	ostaCurrentSchoolStatus?: string | null
	ostaSchool?: string | null
	ostaDegreeProgramName?: string | null
}

/** The selection half of `POST examSetupId`. Ids, or null for an absent part. */
export type ExamSetupSelectionInput = {
	selectedAdminPart1: string | null
	selectedSitePart1: string | null
	selectedAdminPart2: string | null
	selectedSitePart2: string | null
}

/** Where Apex sends the member next; the outcome step branches on it. */
export type ExamSetupNextScreen =
	| "Setup Complete"
	| "Pay Fees"
	| "Check Authorization"

/** `POST examSetupId`. */
export type ExamSetupIdSaveResult = {
	statusMessage: string | null
	statusCode: number
	nextScreen: string | null
	paymentRequired: boolean | null
	schedulingRequired: boolean | null
	/** Set when the selection changed and a modification was raised. */
	examModificationId: string | null
}

/** One priced line from `POST examSetupFees`. */
export type ExamSetupFee = {
	name: string | null
	/** `'fee' | 'refund'`. */
	type: string | null
	amount: number | null
	description: string | null
	productCode: string | null
	glCode: string | null
	accountingCode: string | null
	examRegId: string | null
	examSiteId: string | null
}

/**
 * `POST examSetupFees`.
 *
 * Carries no `orderId` and no checkout URL — pricing only. The charge is taken
 * at the legacy checkout, which the outcome step links to.
 */
export type ExamSetupFeesView = {
	statusMessage: string | null
	statusCode: number
	examType: string | null
	fees: ExamSetupFee[] | null
	examEmailParts: string | null
	deferralSubType: string | null
	transactionType: string | null
}

/**
 * `POST examSetupAuthorize`.
 *
 * The provider push. `isAuthorized` false with `schedulingRequired` true means
 * the provider answered "unprocessed" and the call should be retried with
 * `isRetry: true`.
 */
export type ExamSetupAuthorizeResult = {
	statusMessage: string | null
	statusCode: number
	schedulingRequired: boolean | null
	isAuthorized: boolean | null
	examScheduleExamURLPart1: string | null
	examScheduleExamURLPart2: string | null
}

export type { MemberPortalEnvelope }
