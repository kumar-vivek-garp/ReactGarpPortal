import type {
	CompletedProgram,
	EnrolledProgram,
	OtherProgram,
	ProgramInformation,
} from "@/api/programs"
import { formatLongDate } from "@/lib/account-format"
import { daysUntil } from "@/lib/days-until"
import {
	programDetailsHref,
	programDetailsPath,
	programLearnMoreUrl,
	programRegistrationHref,
	supportsInAppProgramDetail,
} from "@/lib/program-card-links"
import { stripProgramFormalName } from "@/lib/program-formal-name"
import type { MetaLine } from "@/lib/meta-line"
import type { StatusTone } from "@/lib/status-tone"

/** Which bucket of the listing payload a card came from. */
export type ProgramCardVariant = "inProgress" | "completed" | "other"

export type ProgramListingProgram =
	| EnrolledProgram
	| CompletedProgram
	| OtherProgram

export type ProgramListingLink = {
	label: string
	url: string
	isExternal: boolean
	newWindow?: boolean
}

export type ProgramListingPresentation = {
	/** Compact code chip (`FRM`, `SCR`) — a text anchor that survives logo failures. */
	codeLabel: string
	displayName: string
	statusLabel: string
	statusTone: StatusTone
	description: string | null
	metaLines: MetaLine[]
	detailsLink: ProgramListingLink | null
	registrationLink: ProgramListingLink | null
	learnMoreLink: ProgramListingLink | null
}

/** Window inside which an upcoming registration date is worth counting down. */
const OPENS_SOON_DAYS = 60

export function programDisplayName(
	info: ProgramInformation | null | undefined,
	programType?: string | null,
): string {
	return (
		stripProgramFormalName(info?.formalName) ||
		info?.informalName?.trim() ||
		info?.abbrevName?.trim() ||
		programType?.trim() ||
		"Program"
	)
}

/**
 * `abbrevName` is the curated short form; `programType` is always populated
 * (it keys the route), so it is a safe fallback.
 */
export function programCodeLabel(
	info: ProgramInformation | null | undefined,
	programType: string,
): string {
	const abbrev = info?.abbrevName?.trim()
	if (abbrev) return abbrev.toUpperCase()
	return programType.trim().toUpperCase()
}

/**
 * Human phrasing for when a closed registration reopens. Prefers a countdown
 * inside `OPENS_SOON_DAYS` because "opens in 9 days" lands harder than a date.
 */
export function registrationOpensCopy(program: OtherProgram): string | null {
	const iso = program.nextRegistrationOpenDate?.slice(0, 10) ?? null
	const admin = program.nextRegistrationOpenAdminName?.trim() || null
	const remaining = iso ? daysUntil(iso) : null

	if (remaining !== null && remaining >= 0 && remaining <= OPENS_SOON_DAYS) {
		if (remaining === 0) return "Registration opens today"
		if (remaining === 1) return "Registration opens tomorrow"
		return `Registration opens in ${remaining} days`
	}

	const date = formatLongDate(iso)
	if (admin && date) return `${admin} registration opens ${date}`
	if (date) return `Registration opens ${date}`
	if (admin) return `${admin} registration is not open yet`
	return null
}

function administrationLines(program: ProgramListingProgram): MetaLine[] {
	if (!("adminPartIName" in program)) return []
	const parts: Array<[string, string | null]> = [
		["Part I", program.adminPartIName],
		["Part II", program.adminPartIIName],
	]
	const present = parts.filter(([, value]) => Boolean(value?.trim()))

	return present.map(([label, value]) => ({
		icon: "administration" as const,
		// Only label the part when both exist — a single sitting needs no qualifier.
		text: present.length > 1 ? `${label} · ${value!.trim()}` : value!.trim(),
	}))
}

function statusFor(
	variant: ProgramCardVariant,
	program: ProgramListingProgram,
): { statusLabel: string; statusTone: StatusTone } {
	if (variant === "inProgress") {
		return { statusLabel: "In progress", statusTone: "info" }
	}
	if (variant === "completed") {
		return { statusLabel: "Certified", statusTone: "success" }
	}
	if ("isRegistrationOpen" in program && program.isRegistrationOpen) {
		return { statusLabel: "Registration open", statusTone: "success" }
	}
	return { statusLabel: "Registration closed", statusTone: "neutral" }
}

function otherMetaLines(program: OtherProgram): MetaLine[] {
	const lines: MetaLine[] = []

	if (program.isMicroCourse) {
		lines.push({ icon: "microCourse", text: "Micro course" })
	}

	if (program.isRegistrationOpen) {
		lines.push({ icon: "registrationOpen", text: "Open for registration" })
		return lines
	}

	const opens = registrationOpensCopy(program)
	if (opens) lines.push({ icon: "opensLater", text: opens })
	return lines
}

/**
 * Maps one listing-payload program into everything a card or row renders.
 *
 * Pure — no React, no DOM. The listing endpoint carries no exam state, so
 * everything here comes from the catalogue plus the registration flags that
 * `otherPrograms` already returns.
 */
export function buildProgramListingPresentation(
	variant: ProgramCardVariant,
	program: ProgramListingProgram,
): ProgramListingPresentation {
	const info = program.programInformation
	const displayName = programDisplayName(info, program.programType)
	const { statusLabel, statusTone } = statusFor(variant, program)

	const isOther = variant === "other" && "isRegistrationOpen" in program

	const metaLines =
		variant === "inProgress"
			? administrationLines(program)
			: isOther
				? otherMetaLines(program)
				: []

	// Details is in-app where Apex supports the type, MyGarp otherwise.
	const showDetails = variant === "inProgress" || variant === "completed"
	const inAppDetails = showDetails
		? programDetailsPath(program.programType)
		: null
	const externalDetails =
		showDetails && !supportsInAppProgramDetail(program.programType)
			? programDetailsHref(program.programType)
			: null
	const detailsUrl = inAppDetails ?? externalDetails

	const detailsLink: ProgramListingLink | null = detailsUrl
		? {
				label: "View Details",
				url: detailsUrl,
				isExternal: !inAppDetails,
			}
		: null

	const registrationUrl =
		isOther && program.isRegistrationOpen
			? programRegistrationHref(
					info?.registrationPath,
					program.programType,
					program.isMicroCourse,
				)
			: null

	const registrationLink: ProgramListingLink | null = registrationUrl
		? { label: "Register Now", url: registrationUrl, isExternal: true }
		: null

	const learnMoreUrl = isOther
		? programLearnMoreUrl(program.programType, info?.policyURL)
		: null

	const learnMoreLink: ProgramListingLink | null = learnMoreUrl
		? {
				label: `Learn more about ${displayName}`,
				url: learnMoreUrl,
				isExternal: true,
				newWindow: true,
			}
		: null

	return {
		codeLabel: programCodeLabel(info, program.programType),
		displayName,
		statusLabel,
		statusTone,
		// Ungated for every bucket — previously only Explore cards showed copy,
		// which left the member's own programs as the emptiest cards on the page.
		description: info?.description?.trim() || null,
		metaLines,
		detailsLink,
		registrationLink,
		learnMoreLink,
	}
}
