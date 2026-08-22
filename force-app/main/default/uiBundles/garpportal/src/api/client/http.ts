import { AppError } from "@/api/client/errors"
import { apiFail, apiOk, type ApiResult } from "@/api/client/result"

type ErrorsBody = {
	errors?: string[]
	message?: string
	/** Legacy `{ ok, error }` envelope. */
	error?: string
	/** Current memberportal Apex envelope. */
	errorMessage?: string | null
}

/**
 * Read a Response body as JSON when possible (consumes the body either way).
 */
export async function readJsonBody<T>(response: Response): Promise<T | null> {
	const contentType = response.headers.get("content-type")
	if (!contentType?.includes("application/json")) {
		await response.text()
		return null
	}
	return (await response.json()) as T
}

/**
 * Normalize a fetch Response into ApiResult.
 * Uses Apex-style `{ errors: string[] }` when present.
 */
export async function normalizeHttpResponse<T>(
	response: Response | undefined | null,
	options?: {
		unreachableMessage?: string
		fallbackErrorMessage?: string
	},
): Promise<ApiResult<T>> {
	if (!response) {
		return apiFail(
			new AppError({
				messages: [
					options?.unreachableMessage ?? "Unable to reach the service.",
				],
				status: 0,
			}),
		)
	}

	const body = await readJsonBody<T & ErrorsBody>(response)
	const status = response.status

	if (!response.ok) {
		const fromBody = body?.errors?.filter(Boolean)
		if (fromBody?.length) {
			return apiFail(new AppError({ messages: fromBody, status }), status, body)
		}
		if (body?.message) {
			return apiFail(
				new AppError({ messages: [body.message], status }),
				status,
				body,
			)
		}
		if (body?.error) {
			return apiFail(
				new AppError({ messages: [body.error], status }),
				status,
				body,
			)
		}
		if (body?.errorMessage) {
			return apiFail(
				new AppError({ messages: [body.errorMessage], status }),
				status,
				body,
			)
		}
		return apiFail(
			new AppError({
				messages: [
					options?.fallbackErrorMessage ??
						"An unexpected error occurred. Please try again.",
				],
				status,
			}),
			status,
			body,
		)
	}

	return apiOk((body ?? ({} as T)) as T, status)
}
