import type { MemberPortalEnvelope } from "@/api/account/types"
import { AppError } from "@/api/client/errors"
import type { ApiResult } from "@/api/client/result"

/** `{}` / `[]` / null all mean "there is nothing here to render". */
function isEmptyPayload(data: unknown): boolean {
	if (data == null) return true
	if (Array.isArray(data)) return data.length === 0
	if (typeof data === "object") return Object.keys(data).length === 0
	return false
}

/**
 * The payload of a *service refusal*, or `null` for a real transport failure.
 *
 * `GARP_Portal_API` answers a refusal with its own status code AND the payload
 * the screen still needs — 401 "CPD Contract not found" carries the reason,
 * 403 from study materials carries the upsell, 502 from exam setup carries the
 * reschedule. A request that could not run at all — an expired session, an
 * unknown action, an unhandled exception — carries an empty `data`.
 *
 * Both arrive as the same HTTP status, so branching on the status alone cannot
 * tell them apart: a caller that maps "401" to a friendly empty state would
 * show that same empty state to someone whose session had simply expired.
 * The presence of a payload is the discriminator.
 */
export function memberPortalRefusalPayload<T>(
	result: ApiResult<unknown>,
): T | null {
	if (result.ok) return null

	const body = result.body
	if (!body || typeof body !== "object") return null

	const envelope = body as MemberPortalEnvelope<T>
	if (typeof envelope.statusCode !== "number") return null
	if (isEmptyPayload(envelope.data)) return null

	return envelope.data as T
}

export function isMemberPortalEnvelopeOk(
	envelope: MemberPortalEnvelope<unknown>,
): boolean {
	return envelope.statusCode === 200 && !envelope.errorMessage
}

/**
 * Ensures a memberportal Apex envelope succeeded. Does not require `data`.
 */
export function assertMemberPortalEnvelopeOk(
	envelope: MemberPortalEnvelope<unknown>,
	options?: {
		fallbackErrorMessage?: string
		status?: number
	},
): void {
	if (isMemberPortalEnvelopeOk(envelope)) return

	const message =
		envelope.errorMessage?.trim() ||
		options?.fallbackErrorMessage ||
		"An unexpected error occurred. Please try again."

	throw new AppError({
		messages: [message],
		status: envelope.statusCode || options?.status || 0,
	})
}

/**
 * Validates the Apex envelope and returns `data`, or throws `AppError`.
 */
export function unwrapMemberPortalEnvelope<T>(
	envelope: MemberPortalEnvelope<T>,
	options?: {
		fallbackErrorMessage?: string
		missingDataMessage?: string
		status?: number
	},
): T {
	assertMemberPortalEnvelopeOk(envelope, options)

	if (envelope.data === undefined) {
		throw new AppError({
			messages: [
				options?.missingDataMessage ?? "No data was returned.",
			],
			status: envelope.statusCode || options?.status || 0,
		})
	}

	return envelope.data
}
