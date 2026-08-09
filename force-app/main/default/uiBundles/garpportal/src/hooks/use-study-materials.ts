import { useQuery } from "@tanstack/react-query"

import { studyMaterialsQueryOptions } from "@/api/study-materials/query-options"

/** Catalogue + entitlements from `GET /memberportal/studyMaterials`. */
export function useStudyMaterials() {
	return useQuery(studyMaterialsQueryOptions)
}
