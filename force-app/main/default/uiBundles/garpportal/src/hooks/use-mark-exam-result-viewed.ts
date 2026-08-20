import { useMutation } from "@tanstack/react-query"

import { markExamResultViewed } from "@/api/exam-results"

/**
 * Clears "new result" markers. Silent — viewing the page is enough even if
 * the stamp fails.
 */
export function useMarkExamResultViewed() {
	return useMutation({
		mutationFn: (examAttemptId: string) =>
			markExamResultViewed(examAttemptId),
		meta: { silent: true },
	})
}
