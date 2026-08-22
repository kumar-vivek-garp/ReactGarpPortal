import type { Completeness, Identity, MemberPortalEnvelope } from "@/api/account/types"
import type { PortalCard } from "@/api/membership/types"
import type { CpdCreditBarRow } from "@/lib/cpd-presentation"

/** Preview row for the Enrolled Programs dashboard card. */
export type DashboardEnrolledPreview = {
	programType: string
	name: string
	adminPartIName: string | null
	adminPartIIName: string | null
}

/** Preview row for the My Events dashboard card. */
export type DashboardEventPreview = {
	eventId: string
	eventType: string
	eventName: string
	eventStartDate: string | null
	eventUrl: string | null
}

/** Provider meta payloads from dashboard composition (Apex + client). */
export type DashboardCardMeta = {
	percentComplete?: number
	missing?: string[]
	missingBySection?: Record<string, number>
	examType?: string
	administrationName?: string
	period?: string
	isRegistrationOpen?: boolean
	registrationEnd?: string | null
	searchEnabled?: boolean
	optedIn?: boolean
	enrolledPrograms?: DashboardEnrolledPreview[]
	upcomingEvents?: DashboardEventPreview[]
	cpdRows?: CpdCreditBarRow[]
	cpdRemaining?: string | null
}

export type DashboardView = {
	identity: Identity
	completeness: Completeness
	cards: PortalCard[]
}

export type DismissCardResult = {
	dismissed: string
}

export function asDashboardCardMeta(
	meta: Record<string, unknown> | null | undefined,
): DashboardCardMeta {
	if (!meta) return {}
	return meta as DashboardCardMeta
}

export type { MemberPortalEnvelope, PortalCard }
