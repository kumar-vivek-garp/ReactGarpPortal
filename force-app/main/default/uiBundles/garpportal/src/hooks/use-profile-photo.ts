import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import { removeProfilePhoto, uploadProfilePhoto } from "@/api/personal-info"

type UploadArgs = {
	contactId: string
	base64Body: string
	fileName: string
}

/** Profile photo upload / remove via Attachment + Contact.Photo_URL__c. */
export function useProfilePhoto() {
	const queryClient = useQueryClient()

	const upload = useMutation({
		mutationFn: ({ contactId, base64Body, fileName }: UploadArgs) =>
			uploadProfilePhoto(contactId, base64Body, fileName),
		meta: {
			successMessage: "Profile photo updated",
			errorTitle: "Unable to upload photo",
		},
		onSuccess: async (_url, variables) => {
			await invalidateAccountCaches(queryClient, variables.contactId)
		},
	})

	const remove = useMutation({
		mutationFn: (contactId: string) => removeProfilePhoto(contactId),
		meta: {
			successMessage: "Profile photo removed",
			errorTitle: "Unable to remove photo",
		},
		onSuccess: async (_data, contactId) => {
			await invalidateAccountCaches(queryClient, contactId)
		},
	})

	return { upload, remove }
}
