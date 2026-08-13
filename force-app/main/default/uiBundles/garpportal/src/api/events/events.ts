import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type { EventsView, MemberPortalEnvelope } from "@/api/events/types"

const EVENTS_PATH = "/services/apexrest/memberportal/events"

/**
 * Loads attending / chapter / featured event buckets from Apex
 * `GARP_Portal_API` (events action).
 */
export async function fetchEvents(): Promise<EventsView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(EVENTS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<MemberPortalEnvelope<EventsView>>(
		response,
		{
			unreachableMessage: "Unable to reach the events service.",
			fallbackErrorMessage: "Unable to load events. Please try again.",
		},
	)

	const envelope = unwrapApiResult(result)

	if (!envelope.ok) {
		throw new AppError({
			messages: [envelope.error ?? "Unable to load events."],
			status: result.status,
		})
	}

	if (!envelope.data) {
		throw new AppError({
			messages: ["No events data was returned."],
			status: result.status,
		})
	}

	if (envelope.data.statusCode !== 200) {
		throw new AppError({
			messages: [envelope.data.statusMessage ?? "Unable to load events."],
			status: envelope.data.statusCode,
		})
	}

	return {
		...envelope.data,
		registeredEvents: envelope.data.registeredEvents ?? [],
		upcomingChapterMeetings: envelope.data.upcomingChapterMeetings ?? [],
		upcomingOtherEvents: envelope.data.upcomingOtherEvents ?? [],
	}
}
