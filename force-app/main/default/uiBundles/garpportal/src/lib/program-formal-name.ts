/**
 * Turns Apex `formalName` HTML (`<sup>&reg;</sup>`, `&trade;`) into plain
 * text with unicode ® / ™. Do not feed the result to `dangerouslySetInnerHTML`.
 */
export function stripProgramFormalName(
	html: string | null | undefined,
): string {
	if (!html) return ""

	return html
		.replace(/<sup>\s*(?:&reg;|&#174;)\s*<\/sup>/gi, "®")
		.replace(/<sup>\s*(?:&trade;|&#8482;)\s*<\/sup>/gi, "™")
		.replace(/&reg;|&#174;/gi, "®")
		.replace(/&trade;|&#8482;/gi, "™")
		.replace(/<[^>]+>/g, "")
		.replace(/&nbsp;/gi, " ")
		.replace(/&amp;/gi, "&")
		.replace(/&lt;/gi, "<")
		.replace(/&gt;/gi, ">")
		.replace(/\s+/g, " ")
		.trim()
}
