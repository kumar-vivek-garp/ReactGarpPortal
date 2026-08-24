import { queryOptions } from "@tanstack/react-query"

import { fetchExamNotifications } from "@/api/notifications/notifications"

export const notificationsQueryKeys = {
	all: ["notifications"] as const,
	exam: ["notifications", "exam"] as const,
}

export const examNotificationsQueryOptions = queryOptions({
	queryKey: notificationsQueryKeys.exam,
	queryFn: fetchExamNotifications,
	staleTime: 60_000,
	retry: false,
	meta: {
		toastError: true,
		errorTitle: "Unable to load your notifications",
	},
})
