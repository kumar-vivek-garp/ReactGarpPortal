/** What a caller's upload rules look like. */
export type UploadRules = {
	maxBytes: number
	/** Human form of `maxBytes`, e.g. "2 MB" — used in the refusal message. */
	maxLabel: string
	allowedTypes: readonly string[]
	allowedExtensions: readonly string[]
}

/**
 * Why a chosen file cannot be uploaded, or null when it is fine.
 *
 * Shared because none of the Apex upload actions validate anything: the
 * platform caps an `Attachment` body at 5 MB, base64 inflates a file by about
 * a third, and the overflow surfaces as an opaque HTTP 500. Refusing it here
 * is the only way the member learns what actually went wrong.
 *
 * The extension is checked as well as the MIME type because browsers report an
 * empty `type` for several of the formats GARP accepts — `.doc` most reliably,
 * so a name-only check has to be enough on its own.
 */
export function validateUpload(
	file: { name: string; size: number; type: string },
	rules: UploadRules,
): string | null {
	if (file.size <= 0) return "This file is empty."
	if (file.size > rules.maxBytes) {
		return `This file is larger than ${rules.maxLabel}. Please upload a smaller one.`
	}

	const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0] ?? ""
	const typeOk = rules.allowedTypes.includes(file.type)
	const extensionOk = rules.allowedExtensions.includes(extension)

	if (!typeOk && !extensionOk) {
		return `${rules.allowedExtensions.join(", ")} files only.`
	}
	return null
}
