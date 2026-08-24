import { createDataSDK } from "@salesforce/platform-sdk"

import {
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CvDocumentRequirement,
	MemberPortalEnvelope,
} from "@/api/work-experience/types"

const CV_DOCUMENT_REQUIREMENT_PATH =
	"/services/apexrest/memberportal/cvDocumentRequirement"

/** The five keys Apex reads off `formData`. Anything else is ignored. */
export type CvDocumentRequirementForm = {
	jobFunction?: string | null
	riskSpecialty?: string | null
	educationalRole?: string | null
	jobType?: string | null
	company?: string | null
}

/**
 * Whether the role being described will need supporting documents
 * (`cvDocumentRequirement`), asked while the member is still filling the form.
 *
 * Deliberately sends only the form values and **never** an `experienceId`.
 * Apex scopes a supplied id to the signed-in member — but when it finds
 * nothing it does not refuse; it falls through and scores the rest of
 * `formData` as an unsaved draft, returning a confident answer about a record
 * it never read. Passing the id therefore buys nothing and can only mislead.
 *
 * `DocumentRequirement` carries no `statusCode`, so the router always answers
 * HTTP 200 — there is no refusal branch to handle here.
 *
 * `requiredDocuments` can be null while `required` is true (the EPP and
 * risk-management branches set a message and no list), so never map it
 * unguarded.
 */
export async function fetchCvDocumentRequirement(
	form: CvDocumentRequirementForm,
	institutionType?: string | null,
): Promise<CvDocumentRequirement> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(CV_DOCUMENT_REQUIREMENT_PATH, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify({
			formData: {
				jobFunction: form.jobFunction ?? null,
				riskSpecialty: form.riskSpecialty ?? null,
				educationalRole: form.educationalRole ?? null,
				jobType: form.jobType ?? null,
				company: form.company ?? null,
			},
			...(institutionType?.trim()
				? { institutionType: institutionType.trim() }
				: {}),
		}),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CvDocumentRequirement>
	>(response, {
		unreachableMessage: "Unable to reach the work experience service.",
		fallbackErrorMessage: "Unable to check the document requirement.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to check the document requirement.",
		missingDataMessage: "No document requirement was returned.",
		status: result.status,
	})

	return {
		...data,
		required: data.required === true,
		requiredDocuments: Array.isArray(data.requiredDocuments)
			? data.requiredDocuments
			: null,
	}
}
