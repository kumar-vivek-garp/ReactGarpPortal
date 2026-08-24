import type { Completeness, Identity, MemberPortalEnvelope } from "@/api/account/types"
import type { PortalCard } from "@/api/membership/types"
import type { ProgramExamNotification } from "@/api/programs/types"
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
	notifications?: ProgramExamNotification[]
}

/**
 * One entry in the server's card manifest.
 *
 * The dashboard payload does NOT carry finished cards — it carries which cards
 * to draw and in what order, and each card fetches its own content from the
 * endpoint that owns it. `name` is matched exactly against
 * `DASHBOARD_COMPONENT` and a name the client does not know renders nothing.
 */
export type DashboardComponent = {
	name: string
	rankOrder: number
}

export type DashboardView = {
	identity: Identity
	completeness: Completeness
	/**
	 * The card manifest.
	 *
	 * NOTE the name. This was previously typed `cards: PortalCard[]`, which no
	 * response has ever contained, so the manifest was silently discarded and
	 * every card had to be invented client-side — which is why Member Directory,
	 * GBI, EPP and BenchPrep never appeared for anyone.
	 */
	dashboardComponents: DashboardComponent[]
	/** Which programme the Advertisement card should sell; null when none. */
	adType: string | null
}

/**
 * `GET ad` — the dashboard cross-sell.
 *
 * `adType` is `FRM`, `SCR` or `RAI` — or **null**, which is a success meaning
 * "nothing to advertise": the member either sits every programme already or has
 * a result still pending. The programme is drawn at random from the eligible
 * ones on each request, so it varies between visits by design.
 */
export type AdInfo = {
	statusMessage: string | null
	statusCode: number
	adType: string | null
	/** The administration being advertised; null when no window was found. */
	adminName: string | null
	isRegistrationOpen: boolean | null
	/** Only set when registration is NOT yet open. */
	nextAdminRegistrationOpenDate: string | null
}

/**
 * `dismissCard` / `restoreCard` both return the key they acted on, under a
 * different name — `{ dismissed, muted: true }` or `{ restored, muted: false }`
 * (see `GARP_Portal_DismissCardService.setMuted`). Both keys are optional here
 * so one type covers both directions.
 */
export type CardVisibilityResult = {
	dismissed?: string
	restored?: string
	muted?: boolean
}

export function asDashboardCardMeta(
	meta: Record<string, unknown> | null | undefined,
): DashboardCardMeta {
	if (!meta) return {}
	return meta as DashboardCardMeta
}

export type { MemberPortalEnvelope, PortalCard }
