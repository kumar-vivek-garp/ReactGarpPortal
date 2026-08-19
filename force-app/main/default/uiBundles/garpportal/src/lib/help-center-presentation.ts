import type { CaseSummary } from "@/api/help-center"
import { formatDateTime } from "@/lib/account-format"
import { caseStatusPresentation } from "@/lib/case-status"
import { daysUntil } from "@/lib/days-until"
import type { MetaLine } from "@/lib/meta-line"
import type { StatusTone } from "@/lib/status-tone"

export type CasePresentation = {
	key: string
	caseNumber: string
	subject: string
	statusLabel: string
	statusTone: StatusTone
	/** Absolute timestamp, e.g. "18 August 2026 at 18:09". */
	raisedLabel: string | null
	/** Relative age — the fast read when scanning a list of open requests. */
	agoLabel: string | null
	metaLines: MetaLine[]
}

/**
 * How long ago a case was raised.
 *
 * Support requests are judged by age far more than by date — "raised 6 days ago"
 * answers "should I have heard back?" where a timestamp does not.
 */
export function caseAgeLabel(
	createdDate: string | null | undefined,
): string | null {
	const iso = createdDate?.slice(0, 10) ?? null
	if (!iso) return null
	const remaining = daysUntil(iso)
	if (remaining === null) return null

	const age = -remaining
	// A future-dated case is a data problem, not something to narrate.
	if (age < 0) return null
	if (age === 0) return "Raised today"
	if (age === 1) return "Raised yesterday"
	if (age < 30) return `Raised ${age} days ago`
	const months = Math.round(age / 30)
	return months <= 1 ? "Raised last month" : `Raised ${months} months ago`
}

/** Stable list key — Apex may omit `id`, so fall back through the number. */
export function caseKey(item: CaseSummary, index: number): string {
	return item.id ?? item.caseNumber ?? `case-${index}`
}

/**
 * Maps one case into everything a row renders.
 *
 * Pure — no React, no DOM. The payload is thin (number, subject, status,
 * created date), so the value added here is tone and recency rather than
 * additional fields.
 */
export function buildCasePresentation(
	item: CaseSummary,
	index = 0,
): CasePresentation {
	const { label, tone } = caseStatusPresentation(item.status)
	const raisedLabel = formatDateTime(item.createdDate)
	const agoLabel = caseAgeLabel(item.createdDate)

	const metaLines: MetaLine[] = []
	if (agoLabel) metaLines.push({ icon: "lastOpened", text: agoLabel })

	return {
		key: caseKey(item, index),
		caseNumber: item.caseNumber?.trim() || "—",
		subject: item.subject?.trim() || "—",
		statusLabel: label,
		statusTone: tone,
		raisedLabel,
		agoLabel,
		metaLines,
	}
}
