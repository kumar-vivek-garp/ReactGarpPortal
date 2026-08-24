import { queryOptions } from "@tanstack/react-query"

import { fetchCourseDetail } from "@/api/courses/course-detail"

export const coursesQueryKeys = {
	all: ["courses"] as const,
	detail: (courseType: string) =>
		["courses", "detail", courseType.trim().toUpperCase()] as const,
}

/** One course. Resolves `null` when the member does not hold it. */
export function courseDetailQueryOptions(courseType: string) {
	return queryOptions({
		queryKey: coursesQueryKeys.detail(courseType),
		queryFn: () => fetchCourseDetail(courseType),
		enabled: Boolean(courseType.trim()),
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load this course",
		},
	})
}
