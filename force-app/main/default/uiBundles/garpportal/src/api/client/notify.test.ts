import { toast } from "sonner"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { AppError } from "@/api/client/errors"
import {
	notifyError,
	notifySuccess,
	notifyWarning,
	notifyWithUndo,
} from "@/api/client/notify"

// `sonner` is mocked globally in vitest.setup.ts — these assert against it.
beforeEach(() => {
	vi.mocked(toast.success).mockClear()
	vi.mocked(toast.warning).mockClear()
	vi.mocked(toast.error).mockClear()
	vi.mocked(toast).mockClear()
})

describe("notifySuccess / notifyWarning", () => {
	it("passes a description only when one is given", () => {
		notifySuccess("Saved")
		expect(toast.success).toHaveBeenCalledWith("Saved", undefined)

		notifySuccess("Saved", "All fields written")
		expect(toast.success).toHaveBeenCalledWith("Saved", {
			description: "All fields written",
		})

		notifyWarning("Careful")
		expect(toast.warning).toHaveBeenCalledWith("Careful", undefined)
	})
})

describe("notifyWithUndo", () => {
	it("offers a longer-lived toast whose action runs the undo", () => {
		const onUndo = vi.fn()
		notifyWithUndo("Card hidden", onUndo)

		const [message, options] = vi.mocked(toast).mock.calls[0] as [
			string,
			{ duration: number; action: { label: string; onClick: () => void } },
		]
		expect(message).toBe("Card hidden")
		expect(options.duration).toBe(8000)
		expect(options.action.label).toBe("Undo")

		options.action.onClick()
		expect(onUndo).toHaveBeenCalledTimes(1)
	})
})

describe("notifyError", () => {
	it("shows the server detail alone when there is no title", () => {
		notifyError(new AppError({ messages: ["Session expired", "Sign in again"] }))
		expect(toast.error).toHaveBeenCalledWith("Session expired Sign in again")
	})

	it("keeps the server detail as the description under a custom title", () => {
		notifyError(new AppError({ messages: ["Contract not found"] }), "Load failed")
		expect(toast.error).toHaveBeenCalledWith("Load failed", {
			description: "Contract not found",
		})
	})

	it("does not repeat a title that IS the detail", () => {
		notifyError(new AppError({ messages: ["Same text"] }), "Same text")
		expect(toast.error).toHaveBeenCalledWith("Same text")
	})

	it("normalizes non-AppError throwables first", () => {
		notifyError(new Error("plain failure"))
		expect(toast.error).toHaveBeenCalledWith("plain failure")
	})
})
