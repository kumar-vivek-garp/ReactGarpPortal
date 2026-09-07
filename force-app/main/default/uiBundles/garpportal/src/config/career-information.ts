/**
 * The career-information vocabulary shared by the My Account career form and
 * the post-registration survey — both write the same Contact fields.
 */

/**
 * The professional designations the org tracks, one `Professional_Designation_
 * <code>__c` checkbox each. "Other" is deliberately not in this list: it is a
 * separate flag that gates the free-text `Other_Qualifications__c`.
 */
export const DESIGNATION_CODES = [
	"ACCA",
	"CA",
	"CAIA",
	"CFA",
	"CFP",
	"CIA",
	"CMA",
	"CMT",
	"CPA",
	"CQF",
	"PMP",
] as const

export type DesignationCode = (typeof DESIGNATION_CODES)[number]

/** The one job function that makes `Risk_Specialty__c` a question at all. */
export const RISK_JOB_FUNCTION = "Risk Management"
