import type { Completeness, Identity, MemberPortalEnvelope } from "@/api/account/types"
import type { PortalCard } from "@/api/membership/types"

/** Provider meta payloads from `GARP_MemberPortal_Service.buildDashboard`. */
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
