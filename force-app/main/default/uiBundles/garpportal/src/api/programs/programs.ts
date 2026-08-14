import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	MemberPortalEnvelope,
	ProgramsView,
} from "@/api/programs/types"

const PROGRAMS_PATH = "/services/apexrest/memberportal/programs"

/**
 * Loads enrolled / completed / other program buckets from Apex
 * `GARP_Portal_API` (programs action).
 */
export async function fetchPrograms(): Promise<ProgramsView> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(PROGRAMS_PATH, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<ProgramsView>
	>(response, {
		unreachableMessage: "Unable to reach the programs service.",
		fallbackErrorMessage: "Unable to load programs. Please try again.",
	})

	const envelope = unwrapApiResult(result)

	const data = unwrapMemberPortalEnvelope(envelope, {
		fallbackErrorMessage: "Unable to load programs.",
		missingDataMessage: "No programs data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load programs."],
			status: data.statusCode,
		})
	}

	return {
		...data,
		enrolledPrograms: data.enrolledPrograms ?? [],
		completedPrograms: data.completedPrograms ?? [],
		otherPrograms: data.otherPrograms ?? [],
	}
}
