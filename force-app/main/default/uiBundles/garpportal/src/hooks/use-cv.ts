import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import {
	cvAttachmentsQueryOptions,
	cvExperienceFormQueryOptions,
	cvQueryOptions,
	deleteCvAttachment,
	deleteExperience,
	invalidateCvAddressCaches,
	invalidateWorkExperienceCaches,
	saveCvAddress,
	saveExperience,
	submitCv,
	uploadCvAttachment,
	type CvAddressPayload,
	type CvExperienceInput,
	type CvProgramType,
} from "@/api/work-experience"

/**
 * Work Experience for one certification (`GET /memberportal/cv`).
 * Resolves `null` when the member has no CV requirement.
 */
export function useCv(programType: CvProgramType, enabled = true) {
	return useQuery({ ...cvQueryOptions(programType), enabled })
}

/**
 * One experience plus the form's four picklists (`GET /memberportal/cvExperience`).
 *
 * A null `experienceId` is the Add form — the deployed service answers that
 * with a blank row and the populated options, which is why the dialog does not
 * carry a hard-coded option list.
 */
export function useCvExperienceForm(
	programType: CvProgramType,
	experienceId: string | null,
	enabled = true,
) {
	return useQuery({
		...cvExperienceFormQueryOptions(programType, experienceId),
		enabled,
	})
}

/** Files on one experience (`GET /memberportal/cvAttachments`). */
export function useCvAttachments(experienceId: string, enabled = true) {
	return useQuery({
		...cvAttachmentsQueryOptions(experienceId),
		enabled: enabled && Boolean(experienceId.trim()),
	})
}

/**
 * Create or update one logged role (`POST /memberportal/cvExperience`).
 *
 * `input` must be built by `toExperienceInput()` — see that function for why a
 * spread of a `WorkExperience` destroys the request.
 */
export function useSaveExperience(programType: CvProgramType, isEdit: boolean) {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (input: CvExperienceInput) =>
			saveExperience(programType, input),
		meta: {
			successMessage: isEdit ? "Experience updated" : "Experience added",
			errorTitle: isEdit
				? "Unable to update this experience"
				: "Unable to add this experience",
		},
		onSuccess: async () => {
			await invalidateWorkExperienceCaches(queryClient)
		},
	})
}

/** Remove one logged role (`POST /memberportal/cvExperienceDelete`). */
export function useDeleteExperience() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (experienceId: string) => deleteExperience(experienceId),
		meta: {
			successMessage: "Experience removed",
			errorTitle: "Unable to remove this experience",
		},
		onSuccess: async () => {
			await invalidateWorkExperienceCaches(queryClient)
		},
	})
}

type UploadArgs = {
	experienceId: string
	fileName: string
	/** Raw base64 — no `data:` prefix. */
	fileText: string
}

/**
 * Upload one supporting document (`POST /memberportal/cvAttachment`).
 *
 * No success toast: the file appearing in the list is the confirmation, and a
 * member adding three documents does not want three toasts. Failures still
 * toast, carrying the server's own `data.message`.
 */
export function useUploadCvAttachment() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: ({ experienceId, fileName, fileText }: UploadArgs) =>
			uploadCvAttachment(experienceId, fileName, fileText),
		meta: { errorTitle: "Unable to upload this file" },
		onSuccess: async () => {
			await invalidateWorkExperienceCaches(queryClient)
		},
	})
}

/** Remove one uploaded document (`POST /memberportal/cvAttachmentDelete`). */
export function useDeleteCvAttachment() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (attachmentId: string) => deleteCvAttachment(attachmentId),
		meta: {
			successMessage: "File removed",
			errorTitle: "Unable to remove this file",
		},
		onSuccess: async () => {
			await invalidateWorkExperienceCaches(queryClient)
		},
	})
}

/**
 * Save the certificate delivery address (`POST /memberportal/cvAddress`).
 *
 * Invalidates My Account as well as this page — the write lands on the
 * member's own Contact mailing fields, not on anything CV-local.
 */
export function useSaveCvAddress() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (payload: CvAddressPayload) => saveCvAddress(payload),
		meta: {
			successMessage: "Address saved",
			errorTitle: "Unable to save your address",
		},
		onSuccess: async () => {
			await invalidateCvAddressCaches(queryClient)
		},
	})
}

/**
 * Send the CV to GARP (`POST /memberportal/cvSubmit`).
 *
 * No optimistic state: the page's whole shape is driven by `status`, and Apex
 * re-checks the months and can refuse with a 501 even from a page that offered
 * the button. The refetch is what turns the page into the receipt.
 */
export function useSubmitCv(programType: CvProgramType) {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: () => submitCv(programType),
		meta: { errorTitle: "Unable to submit your work experience" },
		onSuccess: async () => {
			await invalidateWorkExperienceCaches(queryClient)
		},
	})
}
