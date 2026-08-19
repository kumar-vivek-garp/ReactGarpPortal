import type { MemberPortalEnvelope } from "@/api/account/types"

/** Mirrors `GARP_Portal_CasesService.CaseSummary`. */
export type CaseSummary = {
	id: string | null
	caseNumber: string | null
	subject: string | null
	status: string | null
	/** ISO datetime from Apex Datetime JSON. */
	createdDate: string | null
}

export type SubmitCaseInput = {
	subject: string
	description: string
}

export type { MemberPortalEnvelope }
