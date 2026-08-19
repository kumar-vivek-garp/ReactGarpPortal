import type { StatusTone } from "@/lib/status-tone"

/**
 * Status label + tone for a member-raised Case.
 *
 * Apex sends the Salesforce Case `Status` picklist as-is. Tones are derived
 * from the label so New / In Progress / Closed stay visually distinct without
 * hardcoding org-specific picklist values.
 */
export function caseStatusPresentation(
	status: string | null | undefined,
): { label: string; tone: StatusTone } {
	const label = status?.trim() || "—"
	if (label === "—") return { label, tone: "neutral" }

	const key = label.toLowerCase()
	if (
		key.includes("close") ||
		key.includes("solved") ||
		key === "done"
	) {
		return { label, tone: "success" }
	}
	if (key.includes("escalat") || key.includes("cancel")) {
		return { label, tone: "danger" }
	}
	if (
		key.includes("hold") ||
		key.includes("wait") ||
		key.includes("pending")
	) {
		return { label, tone: "warning" }
	}
	return { label, tone: "info" }
}
