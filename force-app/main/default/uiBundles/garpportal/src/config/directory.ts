import { Users } from "lucide-react"
import { z } from "zod"

/**
 * Static config for the Member Directory.
 *
 * The four multi-select filters map onto Contact picklists the account
 * options endpoint already serves, so their values are not listed here — only
 * which picklist backs which control.
 */
export const MEMBER_DIRECTORY_TITLE = "Member Directory"

export const DIRECTORY_PAGE_SIZE = 10

/** Certification tick-boxes. Each maps to its own `*Only` flag on the wire. */
export const DIRECTORY_CERTIFICATIONS = ["FRM", "ERP", "SCR", "RAI"] as const

/** Advanced filters, and the picklist each one draws from. */
export const DIRECTORY_FILTERS = [
	{ key: "industries", label: "Industry", picklist: "Area_of_Concentration__c" },
	{ key: "jobFunctions", label: "Job function", picklist: "Job_Function__c" },
	{
		key: "riskSpecialties",
		label: "Risk specialty",
		picklist: "Risk_Specialty__c",
	},
	{
		key: "corporateTitles",
		label: "Professional level",
		picklist: "Corporate_Title__c",
	},
] as const

export type DirectoryFilterKey = (typeof DIRECTORY_FILTERS)[number]["key"]

export const DIRECTORY_ZERO_STATE = {
	icon: Users,
	title: "No members found",
	message:
		"Try a different name, company or country — or clear a filter to widen the search.",
} as const

export const DIRECTORY_NO_ACCESS = {
	icon: Users,
	title: "The directory is not available on your membership",
	message:
		"The GARP Member Directory is a benefit of individual membership. Upgrade or renew to search it.",
} as const

/** `?q=` is the only search param; filters live in component state. */
export const directorySearchSchema = z.object({
	q: z.string().optional().catch(undefined),
})
