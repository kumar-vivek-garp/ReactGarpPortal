import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	memberPortalRefusalPayload,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	CourseDetail,
	CourseView,
	MemberPortalEnvelope,
} from "@/api/courses/types"

const COURSE_DETAIL_PATH = "/services/apexrest/memberportal/courseDetail"

/**
 * One course — FRR, FRR25, FFR or a micro course.
 *
 * Resolves `null` rather than throwing for all **three** of Apex's refusals,
 * because each is an ordinary answer rather than a failure:
 *
 *   501 "Invalid Course Type"     a code that matches no course
 *   401 "Contract not found"      the member does not hold this course
 *   401 "Exam Attempt not found"  enrolled, but with no sitting behind it —
 *                                 the legacy refuses the page rather than
 *                                 showing a course with nothing to sit
 *
 * That last one is easy to mistake for a bug: it is a 401 on a course the
 * member genuinely holds. All three still describe themselves in `data`, so a
 * refusal is told apart from a dead session by the payload being present — see
 * `memberPortalRefusalPayload`. An empty body still throws.
 *
 * `courseType` must be what Apex matches on (`FRR` / `FRR25` / `FFR` upper-
 * cased, or a micro course code) — not a route slug. Use `courseTypeFromSlug`.
 */
export async function fetchCourseDetail(
	courseType: string,
): Promise<CourseDetail | null> {
	const key = courseType.trim()
	if (!key) {
		throw new AppError({
			messages: ["A course type is required."],
			status: 400,
		})
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(
		`${COURSE_DETAIL_PATH}?courseType=${encodeURIComponent(key)}`,
		{ method: "GET", headers: { Accept: "application/json" } },
	)

	const result = await normalizeHttpResponse<MemberPortalEnvelope<CourseView>>(
		response,
		{
			unreachableMessage: "Unable to reach the course service.",
			fallbackErrorMessage: "Unable to load this course. Please try again.",
		},
	)

	if (
		(result.status === 401 || result.status === 501) &&
		memberPortalRefusalPayload<CourseView>(result)
	) {
		return null
	}

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: "Unable to load this course.",
		missingDataMessage: "No course data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage ?? "Unable to load this course."],
			status: data.statusCode,
		})
	}

	return data.courseDetailInfo ?? null
}
