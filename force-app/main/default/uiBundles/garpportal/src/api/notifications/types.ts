import type { MemberPortalEnvelope } from "@/api/account/types"
import type { ProgramExamNotification } from "@/api/programs/types"

/**
 * `GET examNotifications` — every exam notice addressed to this member.
 *
 * The rows are the same shape the programme detail payload already carries, so
 * `ProgramExamNotification` is reused rather than redeclared.
 *
 * `?programType=` filters only the **site-addressed** rows; notices addressed
 * to the member directly come back whatever is passed. The dashboard card asks
 * for all of them, so it sends no filter.
 */
export type ExamNotificationsView = {
	statusMessage: string | null
	statusCode: number
	notifications: ProgramExamNotification[]
}

export type { MemberPortalEnvelope, ProgramExamNotification }
