import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring `GARP_Portal_CvService` — the "Certification CV" actions,
 * which are the Work Experience flow.
 *
 * Verified against the class deployed to devjuly25a (it matches the GarpAppv1
 * copy, not MyGarp's older one — the difference matters for the blank
 * `experienceId` Add form, which only the deployed version supports).
 */

/** Only FRM and ERP have a CV requirement. Apex maps anything else to ERP. */
export type CvProgramType = "FRM" | "ERP"

/**
 * Where a member's CV stands.
 *
 * `null` is NOT an error — it is what an approved (or otherwise terminal) CV
 * reports, because `statusFor()` only names the four in-flight states. A union
 * without `null` breaks for every certified member.
 */
export type CvStatus =
	| "New"
	| "In Progress"
	| "Submitted"
	| "Failed Review"
	| null

/** Attached to a row whose dates overlap another. Informational only. */
export type CvOverlapWarning = {
	message: string | null
	/** Comma-joined names of the clashing companies. */
	company: string | null
}

/** One logged role (`Experience__c`). */
export type WorkExperience = {
	id: string | null
	/** The Candidate_Requirement__c id. Read-only — never send it back. */
	programRequirement: string | null
	/** `MM/dd/yyyy`, not ISO. */
	startDate: string | null
	endDate: string | null
	isCurrentPosition: boolean | null
	company: string | null
	title: string | null
	type: string | null
	description: string | null
	manager: string | null
	jobFunction: string | null
	riskSpecialty: string | null
	jobType: string | null
	educationalRole: string | null
	/** Whole months this row contributes. 0 for part-time, which is still valid. */
	timeAllotted: number | null
	/** Empty string is as common as null — both mean "nothing to say". */
	validationMessage: string | null
	isValidExperience: boolean | null
	/**
	 * Only populated on `GET cv`. The `cvExperience` path never calls
	 * `applyAttachmentCounts`, so it reads 0 there even when files exist —
	 * use `hasAttachments` when the row came from the form endpoint.
	 */
	attachmentCount: number
	hasAttachments: boolean
	isExperienceAttachmentRequired: boolean
	documentMessage: string | null
	/** Can be null while `isExperienceAttachmentRequired` is true. */
	requiredDocuments: string[] | null
	overlapWarning: CvOverlapWarning | null
}

/**
 * `GARP_Portal_Core.Address` as this service populates it.
 *
 * `street1` / `street2` / `street3` are declared on the Apex class but this
 * service never assigns them — always null here, even though other services
 * do fill them. Split `street` client-side if you need lines.
 */
export type CvAddress = {
	street: string | null
	city: string | null
	state: string | null
	postalCode: string | null
	country: string | null
	isEmpty: boolean | null
}

/** `GET cv` — the whole page. */
export type CvView = {
	statusMessage: string | null
	statusCode: number
	status: CvStatus
	workExperiences: WorkExperience[]
	totalTimeAllotted: number
	/** Hard-coded 24 in Apex, same for FRM and ERP. */
	timeRequired: number
	isValidExperienceSubmission: boolean
	submissionMessage: string | null
	isOSTA: boolean
	address: CvAddress | null
	/** OSTA candidates only; `postalCode` is never set and `country` is "China". */
	ostaAddress: CvAddress | null
	ostaDistrict: string | null
	ostaTown: string | null
	ostaPhone: string | null
	ostaRecipient: string | null
}

/** `GET cvExperience` — one row plus the picklists the form needs. */
export type ExperienceFormView = {
	statusMessage: string | null
	statusCode: number
	/** Blank (all-null) when no `experienceId` was supplied — the Add form. */
	workExperience: WorkExperience | null
	jobFunctions: string[]
	riskSpecialties: string[]
	jobTypes: string[]
	educationalRoles: string[]
}

/**
 * What may be sent on `POST cvExperience`.
 *
 * Apex deserializes this with a TYPED `JSON.deserialize`, so any key it does
 * not declare throws and the whole request is lost as an opaque HTTP 500.
 * Build it with `toExperienceInput()` — never spread a `WorkExperience`.
 *
 * Dates go as month/year integers. The `startDate`/`endDate` strings are
 * parsed with locale-dependent `Date.parse`, and the end-date branch keys off
 * `startDate`, so mixing the two modes throws.
 */
export type CvExperienceInput = {
	/** Omit or blank to create. */
	id?: string | null
	startDate?: string | null
	endDate?: string | null
	startDateMonth: number | null
	startDateYear: number | null
	endDateMonth: number | null
	endDateYear: number | null
	isCurrentPosition: boolean
	company: string | null
	title: string | null
	type?: string | null
	description: string | null
	manager: string | null
	jobFunction: string | null
	riskSpecialty: string | null
	jobType: string | null
	educationalRole: string | null
}

/** Shared result of `cvExperience`, `cvExperienceDelete`, `cvAddress`, `cvSubmit`. */
export type CvExperienceResult = {
	statusMessage: string | null
	statusCode: number
	/** Set on create only — null on update, delete, address and submit. */
	newExperienceId: string | null
}

export type CvAddressInput = {
	company?: string | null
	street: string | null
	city: string | null
	state: string | null
	postalCode: string | null
	country: string | null
	phone?: string | null
	/** OSTA only. */
	district?: string | null
	town?: string | null
}

export type CvAddressPayload = {
	mailingAddress: CvAddressInput
	ostaAddress?: CvAddressInput | null
	ostaRecipient?: string | null
}

/** One uploaded file. */
export type CvAttachmentInfo = {
	id: string | null
	name: string | null
	/** Relative `/servlet/servlet.FileDownload?file=…`. Link it, don't fetch it. */
	url: string | null
	/** Null on the upload response — only populated by list and download. */
	size: number | null
}

/**
 * Result of every attachment action.
 *
 * Note `message`, not `statusMessage` — the router only lifts a field named
 * `statusMessage`, so the envelope's `errorMessage` is null on an attachment
 * failure and the real text lives here.
 */
export type CvAttachmentResult = {
	status: string | null
	message: string | null
	statusCode: number
	attachments: CvAttachmentInfo[]
}

/** `POST cvDocumentRequirement` — for an unsaved form only. Never carries a statusCode. */
export type CvDocumentRequirement = {
	required: boolean
	hasAttachments: boolean
	isValidExperience: boolean
	validationMessage: string | null
	documentMessage: string | null
	requiredDocuments: string[] | null
}

export type { MemberPortalEnvelope }
