import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	ExamNotificationsView,
	MemberPortalEnvelope,
} from "@/api/notifications/types"

const EXAM_NOTIFICATIONS_PATH =
	"/services/apexrest/memberportal/examNotifications"

/**
 * Every exam notice addressed to this member (`examNotifications`).
 *
 * No `programType` filter: it narrows only the site-addressed rows and the
 * dashboard card is a catch-all. The programme pages read their own notices off
 * the `programDetail` payload instead, so this is not a duplicate of that.
 */
export async function fetchExamNotifications(): Promise<ExamNotificationsView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EXAM_NOTIFICATIONS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ExamNotificationsView>
	>(response, {
		unreachableMessage: "Unable to reach the notifications service.",
		fallbackErrorMessage: "Unable to load your notifications.",
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load your notifications.",
		missingDataMessage: "No notifications were returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load your notifications."],
			status: data.statusCode,
		})
	}

	return {
		...data,
		notifications: Array.isArray(data.notifications) ? data.notifications : [],
	}
}
