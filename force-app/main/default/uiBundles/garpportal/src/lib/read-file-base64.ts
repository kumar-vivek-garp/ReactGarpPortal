/**
 * Reads a File into RAW base64 — no `data:` prefix.
 *
 * `FileReader.readAsDataURL` is used rather than `arrayBuffer()` +
 * `btoa(String.fromCharCode(...))`: the latter blows the argument limit and
 * throws on any file of a realistic size, and it corrupts anything non-ASCII.
 * The prefix is stripped here because Apex hands the string straight to
 * `EncodingUtil.base64Decode`, which rejects it.
 */
export function readFileAsBase64(file: File): Promise<string> {
	return new Promise((resolve, reject) => {
		const reader = new FileReader()
		reader.onload = () => {
			const result = typeof reader.result === "string" ? reader.result : ""
			const base64 = result.includes(",") ? result.split(",")[1] : ""
			if (!base64) {
				reject(new Error("Unable to read this file."))
				return
			}
			resolve(base64)
		}
		reader.onerror = () => reject(new Error("Unable to read this file."))
		reader.readAsDataURL(file)
	})
}
