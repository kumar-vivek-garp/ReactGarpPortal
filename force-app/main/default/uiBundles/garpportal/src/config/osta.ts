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
