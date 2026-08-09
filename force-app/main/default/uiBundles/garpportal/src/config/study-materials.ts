import { z } from "zod"

/** Default program tab — shows the full catalogue. */
export const DEFAULT_STUDY_MATERIALS_TAB = "all"

/**
 * Program filter synced to `?tab=`. Values are `"all"` or a live program `key`
 * from the API (dynamic), so we accept any non-empty string and normalize
 * unknowns after data loads.
 */
export const studyMaterialsSearchSchema = z.object({
	tab: z.string().min(1).catch(DEFAULT_STUDY_MATERIALS_TAB),
})

export type StudyMaterialsSearch = z.infer<typeof studyMaterialsSearchSchema>
