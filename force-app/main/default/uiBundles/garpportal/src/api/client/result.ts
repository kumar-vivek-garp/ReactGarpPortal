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
}

export type ApiResult<T> = ApiOk<T> | ApiFail

export function apiOk<T>(data: T, status = 200): ApiOk<T> {
	return { ok: true, status, data }
}

export function apiFail(error: AppError, status?: number): ApiFail {
	return { ok: false, status: status ?? error.status, error }
}

/** Throw on failure so React Query sees a real error. */
export function unwrapApiResult<T>(result: ApiResult<T>): T {
	if (!result.ok) throw result.error
	return result.data
}
