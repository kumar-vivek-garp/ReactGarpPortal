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
 * How long an undo stays offered.
 *
 * The toast IS the undo window — once it closes the action is only reversible
 * by whatever slower route the app provides, if any. Sonner's 4s default is
 * tuned for "read this and move on"; it is not long enough to notice a button,
 * decide, and reach it, so undoable actions get double.
 */
const UNDO_TOAST_MS = 8000

/**
 * Toast a completed action alongside the one control that reverses it.
 *
 * For reversible, low-stakes actions only. Anything the member would go looking
 * for later needs a real affordance on the page, not a toast that expires.
 */
export function notifyWithUndo(
	message: string,
	onUndo: () => void,
	undoLabel = "Undo",
) {
	toast(message, {
		duration: UNDO_TOAST_MS,
		action: { label: undoLabel, onClick: () => onUndo() },
	})
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
