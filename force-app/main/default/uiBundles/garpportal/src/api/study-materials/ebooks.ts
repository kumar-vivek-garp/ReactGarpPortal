import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type { MemberPortalEnvelope } from "@/api/account/types"
import type {
	EBookAccess,
	MyEBooksView,
} from "@/api/study-materials/types"

const MY_EBOOKS_PATH = "/services/apexrest/memberportal/myEBooks"
const EBOOK_ACCESS_PATH = "/services/apexrest/memberportal/eBookAccess"

/**
 * The member's purchased eBooks (`myEBooks`).
 *
 * `eBooks` arrives as a **map keyed by edition year**, not a list — Apex builds
 * a `Map<Integer, List<EBook>>` and the JSON keys are therefore year strings.
 * Ordering is the client's job; the map carries none.
 *
 * Apex already drops any key that did not resolve to vendor items or has no
 * year, so every entry here is something the member can actually open.
 */
export async function fetchMyEBooks(): Promise<MyEBooksView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(MY_EBOOKS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<MyEBooksView>
	>(response, {
		unreachableMessage: "Unable to reach the study materials service.",
		fallbackErrorMessage: "Unable to load your purchased materials.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load your purchased materials.",
		missingDataMessage: "No purchased materials were returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load your purchased materials."],
			status: data.statusCode,
		})
	}

	return { ...data, eBooks: data.eBooks ?? {} }
}

/**
 * Exchanges a vendor product id for a signed reader link (`eBookAccess`).
 *
 * Fetched on demand rather than up front: the link is short-lived and Apex
 * calls out to the vendor to mint it, so pre-fetching one per title would both
 * be slow and hand out links that expire before they are clicked.
 *
 * The member is never asked which account to open — Apex takes the email from
 * the session's Contact, so one member cannot reach another's book.
 */
export async function fetchEBookAccess(vendorId: string): Promise<string> {
	const key = vendorId.trim()
	if (!key) {
		throw new AppError({ messages: ["A book id is required."], status: 400 })
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(
		`${EBOOK_ACCESS_PATH}?vendorId=${encodeURIComponent(key)}`,
		{ method: "GET", headers: { Accept: "application/json" } },
	)

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<EBookAccess>
	>(response, {
		unreachableMessage: "Unable to reach the study materials service.",
		fallbackErrorMessage: "This book could not be opened.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "This book could not be opened.",
		missingDataMessage: "No access link was returned.",
		status: result.status,
	})

	const url = data.accessURL?.trim()
	if (data.statusCode !== 200 || !url) {
		throw new AppError({
			messages: [data.statusMessage ?? "This book could not be opened."],
			status: data.statusCode,
		})
	}

	return url
}
