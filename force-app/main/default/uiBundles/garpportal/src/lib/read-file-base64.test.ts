import { afterEach, describe, expect, it, vi } from "vitest"

import { readFileAsBase64 } from "./read-file-base64"

afterEach(() => {
	vi.unstubAllGlobals()
})

describe("readFileAsBase64", () => {
	it("resolves the RAW base64 of a text file — no data: prefix", async () => {
		// Apex hands the string straight to EncodingUtil.base64Decode, which
		// rejects a data: URL, so the prefix must already be gone.
		const file = new File(["hello"], "hello.txt", { type: "text/plain" })
		await expect(readFileAsBase64(file)).resolves.toBe("aGVsbG8=")
	})

	it("encodes binary bytes without corruption", async () => {
		// 0x00 0xFF 0x10 — exactly the bytes a naive btoa(String.fromCharCode)
		// pipeline mangles.
		const file = new File([new Uint8Array([0, 255, 16])], "raw.bin", {
			type: "application/octet-stream",
		})
		await expect(readFileAsBase64(file)).resolves.toBe("AP8Q")
	})

	it("rejects an empty file — its data URL carries no payload", async () => {
		const file = new File([], "empty.txt", { type: "text/plain" })
		await expect(readFileAsBase64(file)).rejects.toThrow(
			"Unable to read this file.",
		)
	})

	it("rejects when the reader itself fails", async () => {
		// Stubbed rather than MSW: there is no HTTP boundary here, and jsdom's
		// real FileReader offers no way to make a Blob read fail.
		class FailingReader {
			onload: (() => void) | null = null
			onerror: (() => void) | null = null
			result: string | ArrayBuffer | null = null
			readAsDataURL() {
				queueMicrotask(() => this.onerror?.())
			}
		}
		vi.stubGlobal("FileReader", FailingReader)

		await expect(
			readFileAsBase64(new File(["x"], "x.txt")),
		).rejects.toThrow("Unable to read this file.")
	})

	it("rejects a result that is not a string", async () => {
		// Guards the `typeof reader.result` branch — readAsDataURL should never
		// produce an ArrayBuffer, but the promise must settle if it does.
		class ArrayBufferReader {
			onload: (() => void) | null = null
			onerror: (() => void) | null = null
			result: string | ArrayBuffer | null = new ArrayBuffer(3)
			readAsDataURL() {
				queueMicrotask(() => this.onload?.())
			}
		}
		vi.stubGlobal("FileReader", ArrayBufferReader)

		await expect(
			readFileAsBase64(new File(["x"], "x.txt")),
		).rejects.toThrow("Unable to read this file.")
	})
})
