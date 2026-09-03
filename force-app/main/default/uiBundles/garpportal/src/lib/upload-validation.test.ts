import { describe, expect, it } from "vitest"

import { validateUpload, type UploadRules } from "./upload-validation"

const rules: UploadRules = {
	maxBytes: 100,
	maxLabel: "100 bytes",
	allowedTypes: ["application/pdf"],
	allowedExtensions: [".pdf", ".doc"],
}

function file(overrides: Partial<{ name: string; size: number; type: string }> = {}) {
	return { name: "cv.pdf", size: 50, type: "application/pdf", ...overrides }
}

describe("validateUpload", () => {
	it("accepts a file within every rule", () => {
		expect(validateUpload(file(), rules)).toBeNull()
	})

	it("refuses an empty file", () => {
		expect(validateUpload(file({ size: 0 }), rules)).toBe("This file is empty.")
		expect(validateUpload(file({ size: -1 }), rules)).toBe("This file is empty.")
	})

	it("refuses an oversize file by the human label, not the byte count", () => {
		expect(validateUpload(file({ size: 101 }), rules)).toBe(
			"This file is larger than 100 bytes. Please upload a smaller one.",
		)
	})

	it("allows a file exactly at the cap", () => {
		expect(validateUpload(file({ size: 100 }), rules)).toBeNull()
	})

	it("lets the extension vouch for a file with no MIME type", () => {
		// Browsers report an empty `type` for several accepted formats — `.doc`
		// most reliably — so the name alone has to be enough.
		expect(validateUpload(file({ name: "cv.doc", type: "" }), rules)).toBeNull()
	})

	it("compares the extension case-insensitively", () => {
		expect(validateUpload(file({ name: "CV.PDF", type: "" }), rules)).toBeNull()
	})

	it("lets the MIME type vouch for a misnamed file", () => {
		expect(
			validateUpload(file({ name: "resume", type: "application/pdf" }), rules),
		).toBeNull()
	})

	it("refuses when neither the type nor the extension is allowed", () => {
		expect(
			validateUpload(file({ name: "cv.exe", type: "application/x-dosexec" }), rules),
		).toBe(".pdf, .doc files only.")
	})

	it("uses only the last extension of a multi-dot name", () => {
		expect(
			validateUpload(file({ name: "cv.pdf.exe", type: "" }), rules),
		).toBe(".pdf, .doc files only.")
	})
})
