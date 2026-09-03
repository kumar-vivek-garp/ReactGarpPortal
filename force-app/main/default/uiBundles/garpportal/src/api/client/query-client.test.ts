import { toast } from "sonner"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { AppError } from "@/api/client/errors"
import { queryClient } from "@/api/client/query-client"

/**
 * The toast policy lives on the singleton's caches, so these run real queries
 * and mutations through it (retries disabled per call to stay fast).
 */

const failing = () =>
	Promise.reject(new AppError({ messages: ["Backend down"] }))

beforeEach(() => {
	queryClient.clear()
	vi.mocked(toast.error).mockClear()
	vi.mocked(toast.success).mockClear()
})

describe("query toast policy", () => {
	it("stays silent for a failing query without meta.toastError", async () => {
		await expect(
			queryClient.fetchQuery({ queryKey: ["silent-q"], queryFn: failing, retry: false }),
		).rejects.toBeInstanceOf(AppError)
		expect(toast.error).not.toHaveBeenCalled()
	})

	it("toasts a failing query that opted in, with its title", async () => {
		await expect(
			queryClient.fetchQuery({
				queryKey: ["loud-q"],
				queryFn: failing,
				retry: false,
				meta: { toastError: true, errorTitle: "Unable to load" },
			}),
		).rejects.toBeInstanceOf(AppError)
		expect(toast.error).toHaveBeenCalledWith("Unable to load", {
			description: "Backend down",
		})
	})
})

describe("mutation toast policy", () => {
	it("toasts mutation errors by default", async () => {
		const mutation = queryClient
			.getMutationCache()
			.build(queryClient, { mutationFn: failing })
		await expect(mutation.execute(undefined)).rejects.toBeInstanceOf(AppError)
		expect(toast.error).toHaveBeenCalledWith("Backend down")
	})

	it("honours meta.silent on a failing mutation", async () => {
		const mutation = queryClient
			.getMutationCache()
			.build(queryClient, { mutationFn: failing, meta: { silent: true } })
		await expect(mutation.execute(undefined)).rejects.toBeInstanceOf(AppError)
		expect(toast.error).not.toHaveBeenCalled()
	})

	it("toasts success only when a successMessage is set", async () => {
		const quiet = queryClient
			.getMutationCache()
			.build(queryClient, { mutationFn: async () => "ok" })
		await quiet.execute(undefined)
		expect(toast.success).not.toHaveBeenCalled()

		const loud = queryClient.getMutationCache().build(queryClient, {
			mutationFn: async () => "ok",
			meta: { successMessage: "Profile saved" },
		})
		await loud.execute(undefined)
		expect(toast.success).toHaveBeenCalledWith("Profile saved", undefined)
	})
})
