import { AppError } from "@/api/client/errors"

/** Internal success envelope after normalizing a transport response. */
export type ApiOk<T> = {
	ok: true
	status: number
	data: T
}

/** Internal failure envelope — callers should `unwrap` / throw, not return to React Query. */
export type ApiFail = {
	ok: false
	status: number
	error: AppError
	/**
	 * The parsed response body, when there was one.
	 *
	 * A non-2xx from `GARP_Portal_API` is not always a broken request: the
	 * service returns its own 401/403/502 with the payload the screen still
	 * needs. Keeping the body lets a caller tell "the action ran and refused"
	 * from "the action could not run" — see `memberPortalRefusalPayload`.
	 */
	body?: unknown
}

export type ApiResult<T> = ApiOk<T> | ApiFail

export function apiOk<T>(data: T, status = 200): ApiOk<T> {
	return { ok: true, status, data }
}

export function apiFail(
	error: AppError,
	status?: number,
	body?: unknown,
): ApiFail {
	return { ok: false, status: status ?? error.status, error, body }
}

/** Throw on failure so React Query sees a real error. */
export function unwrapApiResult<T>(result: ApiResult<T>): T {
	if (!result.ok) throw result.error
	return result.data
}
