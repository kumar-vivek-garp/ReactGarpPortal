import type { ExamOutcome, ExamResult } from "@/api/exam-results"
import { formatLongDate } from "@/lib/account-format"
import {
	programResultsPath,
	programTypeSlug,
	resolveExperienceHref,
} from "@/lib/program-card-links"
import type { StatusTone } from "@/lib/status-tone"

export type ExamOutcomePresentation = {
	label: string
	tone: StatusTone
}

export type ExamResultCardPresentation = {
	id: string
	title: string
	administration: string | null
	examDateLabel: string | null
	outcome: ExamOutcomePresentation
	resultLabel: string | null
	message: string | null
	pendingReleaseLabel: string | null
	showQuartiles: boolean
	quartiles: Array<{
		topic: number
		name: string
		rank: number
	}>
	resultsLetterHref: string | null
	performanceHref: string | null
	contactMemberServices: boolean
}

export type ExamResultsPagePresentation = {
	programSlug: string
	codeLabel: string
	results: ExamResultCardPresentation[]
	summary: {
		total: number
		passed: number
		failed: number
		pending: number
		other: number
	}
}

const OUTCOME_MAP: Record<string, ExamOutcomePresentation> = {
	pass: { label: "Pass", tone: "success" },
	fail: { label: "Did not pass", tone: "danger" },
	pending: { label: "Awaiting results", tone: "info" },
	deferred: { label: "Deferred", tone: "warning" },
	violation: { label: "On hold", tone: "danger" },
	notgraded: { label: "Not graded", tone: "warning" },
	noshow: { label: "No show", tone: "neutral" },
}

/** Route slug used under `/programs/$programType` (`rai` → `riskai`). */
export function examResultsRouteSlug(programType: string): string {
	const slug = programTypeSlug(programType)
	return slug === "rai" ? "riskai" : slug
}

/**
 * True when an Apex exam result belongs to the program route slug
 * (`frm`, `scr`, `riskai`, …).
 */
export function examResultMatchesProgramSlug(
	result: ExamResult,
	programSlug: string,
): boolean {
	const target = examResultsRouteSlug(programSlug)
	if (!target) return false

	const fromProgram = result.programType?.trim()
		? examResultsRouteSlug(result.programType)
		: ""
	const fromType = result.examType?.trim()
		? examResultsRouteSlug(result.examType)
		: ""

	return fromProgram === target || (!fromProgram && fromType === target)
}

export function outcomePresentation(
	outcome: ExamOutcome | null | undefined,
): ExamOutcomePresentation {
	const key = (outcome ?? "pending").toString().trim().toLowerCase()
	return OUTCOME_MAP[key] ?? { label: "Status unknown", tone: "neutral" }
}

function buildCard(result: ExamResult): ExamResultCardPresentation {
	const outcome = outcomePresentation(result.outcome)
	const pendingRelease =
		result.outcome === "pending" && result.resultsReleaseDate
			? formatLongDate(result.resultsReleaseDate.slice(0, 10))
			: null

	return {
		id: result.id,
		title: result.examLabel?.trim() || "Exam",
		administration: result.administrationName?.trim() || null,
		examDateLabel: formatLongDate(result.examDate?.slice(0, 10)),
		outcome,
		resultLabel: result.result?.trim() || null,
		message: result.message?.trim() || null,
		pendingReleaseLabel: pendingRelease
			? `Results are expected on ${pendingRelease}.`
			: null,
		showQuartiles:
			result.showQuartiles === true &&
			Array.isArray(result.quartiles) &&
			result.quartiles.length > 0,
		quartiles: (result.quartiles ?? [])
			.filter((q) => q != null && typeof q.rank === "number")
			.map((q) => ({
				topic: q.topic,
				name: q.name?.trim() || `Topic ${q.topic}`,
				rank: q.rank,
			})),
		resultsLetterHref: resolveExperienceHref(result.resultsLetterUrl),
		performanceHref: resolveExperienceHref(result.quartilesUrl),
		contactMemberServices:
			result.outcome === "violation" ||
			result.outcome === "notGraded" ||
			result.outcome === "noShow",
	}
}

/**
 * Filters the member-wide examResults list to one program and builds
 * UI-ready cards + summary counts.
 */
export function buildExamResultsPagePresentation(
	results: ExamResult[],
	programSlug: string,
): ExamResultsPagePresentation {
	const slug = examResultsRouteSlug(programSlug)
	const filtered = results.filter((row) =>
		examResultMatchesProgramSlug(row, slug),
	)

	const cards = filtered.map(buildCard)
	let passed = 0
	let failed = 0
	let pending = 0
	let other = 0
	for (const row of filtered) {
		const key = (row.outcome ?? "").toString().trim().toLowerCase()
		if (key === "pass") passed += 1
		else if (key === "fail") failed += 1
		else if (key === "pending" || key === "deferred") pending += 1
		else other += 1
	}

	return {
		programSlug: slug,
		codeLabel: slug.toUpperCase(),
		results: cards,
		summary: {
			total: cards.length,
			passed,
			failed,
			pending,
			other,
		},
	}
}

/**
 * Route slugs of every program the member has a result for.
 *
 * Drives the "Results" chip on the programme listing: a card shows one only
 * when this set contains its slug. Programs the results route cannot serve
 * (`programResultsPath` returns null) are dropped, so a chip is never rendered
 * pointing at a route that does not exist.
 */
export function examResultProgramSlugs(
	results: ExamResult[] | null | undefined,
): Set<string> {
	const slugs = new Set<string>()
	for (const result of results ?? []) {
		const programType = result.programType ?? result.examType ?? ""
		if (!programResultsPath(programType)) continue
		const slug = examResultsRouteSlug(programType)
		if (slug) slugs.add(slug)
	}
	return slugs
}

/** One row of the programs-listing exam-results preview. */
export type ExamResultsPreviewRow = {
	id: string
	title: string
	administration: string | null
	programSlug: string | null
}

/**
 * Unique program+part preview rows for the programs listing card
 * (newest administrations first — API order).
 */
export function buildExamResultsPreviewRows(
	results: ExamResult[],
	limit = 2,
): ExamResultsPreviewRow[] {
	const seen = new Set<string>()
	const rows: ExamResultsPreviewRow[] = []

	for (const result of results) {
		const programKey = (result.programType ?? result.examType ?? "")
			.trim()
			.toLowerCase()
		const partKey = (result.examPart ?? "").trim().toLowerCase()
		const dedupe = `${programKey}|${partKey}`
		if (seen.has(dedupe)) continue
		seen.add(dedupe)

		const path = programResultsPath(
			result.programType ?? result.examType ?? "",
		)
		const programSlug = path
			? examResultsRouteSlug(result.programType ?? result.examType ?? "")
			: null

		rows.push({
			id: result.id,
			title: result.examLabel?.trim() || "Exam",
			administration: result.administrationName?.trim() || null,
			programSlug,
		})

		if (rows.length >= limit) break
	}

	return rows
}
