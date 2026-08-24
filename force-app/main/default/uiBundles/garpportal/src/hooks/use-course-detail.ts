import { useQuery } from "@tanstack/react-query"

import { courseDetailQueryOptions } from "@/api/courses"
import { courseTypeFromSlug } from "@/lib/course-detail-presentation"

/**
 * One course by route slug (`GET /memberportal/courseDetail`).
 *
 * The slug is mapped to the `courseType` Apex matches on before it is sent —
 * a lower-cased slug matches neither the fixed map nor a micro code and comes
 * back 501. Resolves `null` for any of the three refusals.
 */
export function useCourseDetail(slug: string, enabled = true) {
	const courseType = courseTypeFromSlug(slug) ?? ""
	return useQuery({
		...courseDetailQueryOptions(courseType),
		enabled: enabled && Boolean(courseType),
	})
}
