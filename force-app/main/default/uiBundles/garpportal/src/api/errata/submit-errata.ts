import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ErrataAttachResult,
	ErrataSubmission,
	ErrataSubmitResult,
	MemberPortalEnvelope,
} from "@/api/errata/types"
import { readFileAsBase64 } from "@/lib/read-file-base64"

const SUBMIT_ERRATA_PATH = "/services/apexrest/memberportal/submitErrata"
const ATTACH_ERRATA_PATH = "/services/apexrest/memberportal/attachErrataFile"

async function postErrata<
	T extends { statusCode: number; statusMessage: string | null },
>(path: string, body: unknown, fallback: string): Promise<T> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, {
		method: "POST",
		headers: { "Content-Type": "application/json", Accept: "application/json" },
		body: JSON.stringify(body),
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<T>>(response, {
		unreachableMessage: "Unable to reach the errata service.",
		fallbackErrorMessage: fallback,
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: fallback,
		missingDataMessage: "No response was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || fallback],
			status: data.statusCode,
		})
	}

	return data
}

/**
 * Files an erratum (`submitErrata`).
 *
 * `input` MUST come from `toErrataSubmission()` — `studyMaterial` and `book`
 * are inverted relative to their names and reports are triaged on those two
 * fields, so hand-assembling the body files every report against the wrong
 * one, silently and with a 200.
 *
 * Apex answers a single 501 "Required information missing" for any of the five
 * required fields, so the caller validates first to name the field.
 */
export async function submitErrata(
	input: ErrataSubmission,
): Promise<ErrataSubmitResult> {
	return postErrata<ErrataSubmitResult>(
		SUBMIT_ERRATA_PATH,
		input,
		"Your report could not be submitted.",
	)
}

/**
 * Attaches a file to a report that has already been filed
 * (`attachErrataFile`).
 *
 * A second call, and it can fail on its own. By the time this runs the erratum
 * is already saved, so a failure here must never be reported as a failed
 * submission — resubmitting would file a duplicate. See `useSubmitErrata`.
 *
 * `fileText` is RAW base64 with no `data:` prefix. Apex checks nothing about
 * the size; the caller applies the cap.
 *
 * Apex resolves the report against the signed-in member before writing, unlike
 * the legacy, where a crafted request could attach a file to any record.
 */
export async function attachErrataFile(
	errataId: string,
	fileName: string,
	fileText: string,
): Promise<ErrataAttachResult> {
	const key = errataId.trim()
	const name = fileName.trim()
	if (!key) {
		throw new AppError({ messages: ["A report id is required."], status: 400 })
	}
	if (!name || !fileText) {
		throw new AppError({ messages: ["A file is required."], status: 400 })
	}

	return postErrata<ErrataAttachResult>(
		ATTACH_ERRATA_PATH,
		{ errataId: key, fileName: name, fileText },
		"The file could not be attached to your report.",
	)
}

export type ErrataSubmitOutcome = {
	errataId: string | null
	/**
	 * Set when the report was filed but its attachment did not land. The
	 * submission still succeeded — this is a warning, never an error.
	 */
	attachmentError: string | null
}

/**
 * Files an erratum, then attaches its file if there is one.
 *
 * Two calls, and the second can fail on its own. Once `submitErrata` returns,
 * the report **exists** — so an attachment failure must resolve rather than
 * reject: reporting a failed submission would invite a retry that files a
 * duplicate. The reason is handed back for the receipt to mention.
 *
 * Lives here rather than in the hook because it is the endpoint pair's own
 * rule, and because a React hook is an awkward place to test sequencing.
 */
export async function submitErrataWithFile(
	submission: ErrataSubmission,
	file?: File | null,
): Promise<ErrataSubmitOutcome> {
	const result = await submitErrata(submission)
	const errataId = result.errataId?.trim() || null

	// No id means there is nothing to attach to.
	if (!file || !errataId) {
		return { errataId, attachmentError: null }
	}

	try {
		const fileText = await readFileAsBase64(file)
		await attachErrataFile(errataId, file.name, fileText)
		return { errataId, attachmentError: null }
	} catch (error) {
		return {
			errataId,
			attachmentError:
				error instanceof AppError
					? error.messages[0]
					: "The file could not be attached.",
		}
	}
}
