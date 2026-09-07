/**
 * Static config for OSTA identity details.
 *
 * The ID types are a fixed list, not an org picklist: `ID_Type__c` is written
 * as free text by the service and the legacy offered these four. If GARP ever
 * makes it a real picklist this should move to `GET options`.
 */
export const OSTA_ID_TYPES = [
	"Passport",
	"Driver's License",
	"National ID",
	"Other Government ID",
] as const

export const OSTA_ID_TITLE = "Identity details"

/**
 * The two documents an exam centre accepts as photo ID.
 *
 * Deliberately narrower than `OSTA_ID_TYPES` above: a National ID is fine for
 * an identity record but will not get a candidate into an exam hall, so the
 * exam-facing forms must not offer it.
 */
export const OSTA_PHOTO_ID_TYPES = ["Passport", "Driver's License"] as const

export const OSTA_ID_LOCATIONS = ["China", "Non-China"] as const

export const OSTA_GENDERS = ["Male", "Female", "Other"] as const

export const OSTA_WORKING_STATUSES = ["Working", "Not Working"] as const

export const OSTA_SCHOOL_STATUSES = ["In School", "Not In School"] as const
