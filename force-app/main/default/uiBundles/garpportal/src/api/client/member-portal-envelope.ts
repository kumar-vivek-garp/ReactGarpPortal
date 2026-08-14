import type { MemberPortalEnvelope } from "@/api/account/types"
import { AppError } from "@/api/client/errors"

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
