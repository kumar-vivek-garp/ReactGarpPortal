/**
 * The response envelope every `/services/apexrest/memberportal/*` action
 * returns (`GARP_Portal_API.respond`). Handlers must mirror `statusCode` in
 * the HTTP status: `HttpResponse.json(memberPortalError(...), { status: ... })`.
 */
export function memberPortalEnvelope<T>(data: T) {
	return {
		status: "Success" as const,
		statusCode: 200,
		errorMessage: null,
		data,
	}
}

/**
 * A transport-level failure: empty `data`, so the client throws `AppError`
 * carrying `errorMessage`. For a business refusal that resolves `null`
 * instead, keep `data` populated — see `member-portal-envelope.ts`.
 */
export function memberPortalError(statusCode: number, errorMessage: string) {
	return {
		status: "Error" as const,
		statusCode,
		errorMessage,
		data: {},
	}
}
