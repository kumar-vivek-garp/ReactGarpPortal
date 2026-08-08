import { toast } from "sonner"

import { AppError } from "@/api/client/errors"

/** Global / imperative success toast. */
export function notifySuccess(message: string, description?: string) {
	toast.success(message, description ? { description } : undefined)
}

/** Global / imperative warning toast. */
export function notifyWarning(message: string, description?: string) {
	toast.warning(message, description ? { description } : undefined)
}

/**
 * Map any thrown value to an error toast.
 * Prefer the server / AppError messages — never hide them behind a generic title.
 */
export function notifyError(error: unknown, title?: string) {
	const appError = AppError.fromUnknown(error)
	const detail = appError.messages.join(" ").trim() || appError.message

	if (title && title !== detail) {
		toast.error(title, { description: detail })
		return
	}

	toast.error(detail)
}
