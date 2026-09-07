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

/**
 * A business refusal that still carries its payload — `GARP_Portal_API`
 * answering 401/403/404 with the screen's data intact. Serve it with the same
 * HTTP status: `HttpResponse.json(memberPortalRefusal(...), { status })`.
 * The client resolves these as a state (`memberPortalRefusalPayload`) rather
 * than throwing.
 */
export function memberPortalRefusal<T>(
	statusCode: number,
	errorMessage: string,
	data: T,
) {
	return {
		status: "Error" as const,
		statusCode,
		errorMessage,
		data,
	}
}
