import { queryOptions } from "@tanstack/react-query"

import { fetchCvAttachments } from "@/api/work-experience/attachments"
import { fetchCv } from "@/api/work-experience/cv"
import { fetchExperienceForm } from "@/api/work-experience/experience-form"
import type { CvProgramType } from "@/api/work-experience/types"

export const workExperienceQueryKeys = {
	all: ["work-experience"] as const,
	cv: (programType: CvProgramType) =>
		["work-experience", "cv", programType] as const,
	experienceForm: (programType: CvProgramType, experienceId: string | null) =>
		["work-experience", "experience-form", programType, experienceId] as const,
	attachments: (experienceId: string) =>
		["work-experience", "attachments", experienceId] as const,
}

/** The CV page for one certification. Resolves `null` when none is owed. */
export function cvQueryOptions(programType: CvProgramType) {
	return queryOptions({
		queryKey: workExperienceQueryKeys.cv(programType),
		queryFn: () => fetchCv(programType),
		staleTime: 60_000,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load your work experience",
		},
	})
}

/**
 * One experience plus the form's picklists.
 *
 * `experienceId` is part of the key, and `null` — the Add form — is a distinct
 * entry rather than a shared one: the picklists are identical but the blank
 * `workExperience` must not be served from an edit's cache, or the Add dialog
 * opens pre-filled with whatever was edited last.
 *
 * Not cached long. The picklists are static, but `hasAttachments` and the
 * validation sentence on the row change as soon as anything is uploaded.
 */
export function cvExperienceFormQueryOptions(
	programType: CvProgramType,
	experienceId: string | null,
) {
	return queryOptions({
		queryKey: workExperienceQueryKeys.experienceForm(programType, experienceId),
		queryFn: () => fetchExperienceForm(programType, experienceId),
		staleTime: 0,
		gcTime: 0,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to open this experience",
		},
	})
}

/** Files attached to one experience. */
export function cvAttachmentsQueryOptions(experienceId: string) {
	return queryOptions({
		queryKey: workExperienceQueryKeys.attachments(experienceId),
		queryFn: () => fetchCvAttachments(experienceId),
		enabled: Boolean(experienceId.trim()),
		staleTime: 0,
		retry: false,
		meta: {
			toastError: true,
			errorTitle: "Unable to load files",
		},
	})
}
