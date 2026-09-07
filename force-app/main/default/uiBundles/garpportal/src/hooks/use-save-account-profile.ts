import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import {
	saveAccountProfile,
	type AccountProfileValues,
} from "@/api/account/save-profile"
import { eventsQueryKeys } from "@/api/events"

type SaveProfileToast = {
	successMessage?: string
	errorTitle?: string
}

/** Saves Contact profile fields via REST `/memberportal/profile`. */
export function useSaveAccountProfile(toast?: SaveProfileToast) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (values: AccountProfileValues) => saveAccountProfile(values),
		meta: {
			successMessage: toast?.successMessage ?? "Career information saved",
			errorTitle: toast?.errorTitle ?? "Unable to save career information",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient)
		},
	})
}

/** Preferred chapters — same profile POST, plus Events cache (meetings use these names). */
export function useSavePreferredChapters() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (values: AccountProfileValues) => saveAccountProfile(values),
		meta: {
			successMessage: "Preferred chapters saved",
			errorTitle: "Unable to save chapters",
		},
		onSuccess: async () => {
			await Promise.all([
				invalidateAccountCaches(queryClient),
				queryClient.invalidateQueries({ queryKey: eventsQueryKeys.view }),
			])
		},
	})
}

/** Directory privacy flags — same profile POST as other Contact fields. */
export function useSaveDirectorySettings() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (values: AccountProfileValues) => saveAccountProfile(values),
		meta: {
			successMessage: "Directory settings saved",
			errorTitle: "Unable to save directory settings",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient)
		},
	})
}
