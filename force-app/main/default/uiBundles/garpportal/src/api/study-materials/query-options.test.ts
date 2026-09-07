import { describe, expect, it } from "vitest"

import {
	materialQuoteQueryOptions,
	myEBooksQueryOptions,
	studyMaterialsQueryKeys,
	studyMaterialsQueryOptions,
} from "./query-options"

describe("study-materials query options", () => {
	it("keys the catalogue and the archive under one root, and toasts their failures", () => {
		expect(studyMaterialsQueryOptions.queryKey).toEqual(["study-materials", "list"])
		expect(studyMaterialsQueryOptions.meta).toMatchObject({ toastError: true })
		expect(myEBooksQueryOptions.queryKey).toEqual(["study-materials", "archive"])
		expect(myEBooksQueryOptions.meta).toMatchObject({ toastError: true })
		expect(studyMaterialsQueryKeys.all).toEqual(["study-materials"])
	})

	it("keys a quote by its trimmed product code and stays idle without one", () => {
		expect(materialQuoteQueryOptions(" SCRH ").queryKey).toEqual([
			"study-materials",
			"quote",
			"SCRH",
		])
		expect(materialQuoteQueryOptions("SCRH").enabled).toBe(true)
		expect(materialQuoteQueryOptions("  ").enabled).toBe(false)
		// The purchase panel is the error surface — no toast.
		expect(materialQuoteQueryOptions("SCRH").meta).toBeUndefined()
	})
})
