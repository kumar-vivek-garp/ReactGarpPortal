import { useMutation, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import { removeProfilePhoto, uploadProfilePhoto } from "@/api/personal-info"

type UploadArgs = {
	base64Body: string
	fileName: string
}

/** Profile photo upload / remove via `memberPhoto` / `memberPhotoRemove`. */
export function useProfilePhoto() {
	const queryClient = useQueryClient()

	const upload = useMutation({
		mutationFn: ({ base64Body, fileName }: UploadArgs) =>
			uploadProfilePhoto(base64Body, fileName),
		meta: {
			successMessage: "Profile photo updated",
			errorTitle: "Unable to upload photo",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient)
		},
	})

	const remove = useMutation({
		mutationFn: () => removeProfilePhoto(),
		meta: {
			successMessage: "Profile photo removed",
			errorTitle: "Unable to remove photo",
		},
		onSuccess: async () => {
			await invalidateAccountCaches(queryClient)
		},
	})

	return { upload, remove }
}
