import { useQuery } from "@tanstack/react-query"

import { examNotificationsQueryOptions } from "@/api/notifications"

/** Every exam notice addressed to this member (`GET /memberportal/examNotifications`). */
export function useExamNotifications(enabled = true) {
	return useQuery({ ...examNotificationsQueryOptions, enabled })
}
