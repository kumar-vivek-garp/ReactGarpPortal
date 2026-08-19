import { asDashboardCardMeta, type PortalCard } from "@/api/dashboard"
import { formatLongDate } from "@/lib/account-format"
import { DASHBOARD_PROVIDER } from "@/lib/compose-dashboard-cards"
import { daysUntil } from "@/lib/days-until"
import type { MetaLine } from "@/lib/meta-line"
import type { StatusTone } from "@/lib/status-tone"

/** Inside this window a registration deadline is worth counting down. */
const CLOSING_SOON_DAYS = 30

export type DashboardCardPresentation = {
	/** Apex/composed `badge` — e.g. the profile completeness percentage. */
	badgeLabel: string | null
	badgeTone: StatusTone | null
	/** Exam registration facts, empty for every other provider. */
	metaLines: MetaLine[]
}

/**
 * Phrasing for an exam registration window.
 *
 * Mirrors the Programs listing: a deadline inside the window counts down,
 * because "closes in 6 days" prompts action where a date does not.
 */
export function registrationWindowLine(
	isRegistrationOpen: boolean | undefined,
	registrationEnd: string | null | undefined,
): MetaLine | null {
	const iso = registrationEnd?.slice(0, 10) ?? null
	const remaining = iso ? daysUntil(iso) : null

	if (isRegistrationOpen === false) {
		return { icon: "opensLater", text: "Registration is not open" }
	}

	if (isRegistrationOpen === true) {
		if (remaining !== null && remaining >= 0 && remaining <= CLOSING_SOON_DAYS) {
			if (remaining === 0) {
				return { icon: "expiringSoon", text: "Registration closes today" }
			}
			if (remaining === 1) {
				return { icon: "expiringSoon", text: "Registration closes tomorrow" }
			}
			return {
				icon: "expiringSoon",
				text: `Registration closes in ${remaining} days`,
			}
		}
		const date = formatLongDate(iso)
		return {
			icon: "registrationOpen",
			text: date ? `Registration open until ${date}` : "Registration is open",
		}
	}

	// Apex did not send the flag — say nothing rather than imply a state.
	return null
}

/**
 * Maps one dashboard card's provider metadata into renderable facts.
 *
 * Every field is read defensively: `meta` is an untyped Apex bag, and the exam
 * fields in particular are not set by client composition, so an absent field
 * must render nothing rather than a placeholder.
 */
export function buildDashboardCardPresentation(
	card: PortalCard,
): DashboardCardPresentation {
	const meta = asDashboardCardMeta(card.meta)
	const metaLines: MetaLine[] = []

	if (card.provider === DASHBOARD_PROVIDER.exam) {
		const examType = meta.examType?.trim()
		const administration = meta.administrationName?.trim()
		const period = meta.period?.trim()

		const sitting = [examType, administration ?? period]
			.filter(Boolean)
			.join(" · ")
		if (sitting) metaLines.push({ icon: "administration", text: sitting })

		const window = registrationWindowLine(
			meta.isRegistrationOpen,
			meta.registrationEnd,
		)
		if (window) metaLines.push(window)
	}

	const badgeLabel = card.badge?.trim() || null

	return {
		badgeLabel,
		// A bare percentage or short label is informational, not a warning.
		badgeTone: badgeLabel ? "info" : null,
		metaLines,
	}
}
