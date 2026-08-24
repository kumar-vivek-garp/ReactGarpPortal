import { BookMarked } from "lucide-react"
import { BookOpen, GraduationCap, Library } from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

import { LIST_VIEWS, type ListView } from "@/config/list-view"

/** Default program tab — shows the full catalogue. */
export const DEFAULT_STUDY_MATERIALS_TAB = "all"

/**
 * Program filter synced to `?tab=`. Values are `"all"` or a live program `key`
 * from the API (dynamic), so we accept any non-empty string and normalize
 * unknowns after data loads.
 *
 * `view` is optional so an *absent* value stays distinguishable from an explicit
 * one — that difference is what lets a remembered choice apply.
 */
export const studyMaterialsSearchSchema = z.object({
	tab: z.string().min(1).catch(DEFAULT_STUDY_MATERIALS_TAB),
	view: z.enum(LIST_VIEWS).optional().catch(undefined),
})

export type StudyMaterialsSearch = z.infer<typeof studyMaterialsSearchSchema>

/**
 * Precedence: explicit `?view=`, then the remembered choice, then grid.
 *
 * Grid is the default because this page is primarily a catalogue — artwork and
 * blurbs carry meaning while browsing. List earns its place when scanning many
 * items for a specific one.
 */
export function resolveStudyMaterialsView(
	view: ListView | undefined,
	preferred?: ListView | null,
): ListView {
	if (view) return view
	if (preferred) return preferred
	return "grid"
}

export type StudyMaterialsSectionMeta = {
	heading: string
	icon: LucideIcon
	emptyMessage: string
}

/**
 * One definition per section, shared by the panel headings and empty states —
 * the same bucket-identity pattern the Programs page uses.
 */
export const STUDY_MATERIALS_SECTIONS = {
	entitlements: {
		heading: "My Materials",
		icon: GraduationCap,
		emptyMessage: "Materials you own will appear here.",
	},
	catalogue: {
		heading: "Catalogue",
		icon: Library,
		emptyMessage: "Nothing published for that program yet.",
	},
	all: {
		heading: "Study Materials",
		icon: BookOpen,
		emptyMessage:
			"No study materials published yet. Study materials appear here once they are published for a program.",
	},
} as const satisfies Record<string, StudyMaterialsSectionMeta>

/** The purchased-materials archive (`/study-materials/archive`). */
export const EBOOK_ARCHIVE = {
	icon: BookMarked,
	title: "Purchased Study Materials",
	emptyTitle: "No purchased materials yet",
	emptyMessage:
		"eBooks you buy appear here, grouped by edition. Nothing has been purchased on this account.",
} as const
