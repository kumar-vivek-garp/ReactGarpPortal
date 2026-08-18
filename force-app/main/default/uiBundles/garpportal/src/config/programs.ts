import { Award, Compass, GraduationCap, Hourglass } from "lucide-react"
import type { LucideIcon } from "lucide-react"
import { z } from "zod"

export const PROGRAMS_TABS = [
	"all",
	"in-progress",
	"completed",
	"explore",
] as const

export type ProgramsTab = (typeof PROGRAMS_TABS)[number]

export const PROGRAMS_VIEWS = ["grid", "list"] as const

export type ProgramsView = (typeof PROGRAMS_VIEWS)[number]

export const DEFAULT_PROGRAMS_TAB: ProgramsTab = "all"

/** localStorage key for the remembered grid/list choice. */
export const PROGRAMS_VIEW_STORAGE_KEY = "garp-portal:programs-view"

/**
 * `tab` / `view` are optional so an *absent* value stays distinguishable from an
 * explicit one — that difference is what lets the panel pick a smart default and
 * still respect a deliberate choice. Bad values fall through to `undefined`
 * rather than being pinned to a default.
 */
export const programsSearchSchema = z.object({
	tab: z.enum(PROGRAMS_TABS).optional().catch(undefined),
	view: z.enum(PROGRAMS_VIEWS).optional().catch(undefined),
})

export type ProgramsSearch = z.infer<typeof programsSearchSchema>

/**
 * Land members on their own programs when they have any — otherwise the whole
 * catalogue pushes an active enrollment below the fold.
 */
export function resolveProgramsTab(
	tab: ProgramsTab | undefined,
	enrolledCount: number,
): ProgramsTab {
	if (tab) return tab
	return enrolledCount > 0 ? "in-progress" : DEFAULT_PROGRAMS_TAB
}

/**
 * Precedence: an explicit `?view=` in the URL, then whatever the member last
 * chose, then the per-bucket default.
 *
 * The remembered choice sits above the default on purpose — once someone has
 * picked a layout, silently reverting to "browsing buckets get cards, personal
 * buckets get rows" reads as the app forgetting. The default only applies until
 * the first explicit choice.
 */
export function resolveProgramsView(
	view: ProgramsView | undefined,
	tab: ProgramsTab,
	preferred?: ProgramsView | null,
): ProgramsView {
	if (view) return view
	if (preferred) return preferred
	return tab === "in-progress" || tab === "completed" ? "list" : "grid"
}

export type ProgramBucketMeta = {
	label: string
	icon: LucideIcon
	emptyTitle: string
	emptyMessage: string
}

/**
 * One definition per bucket, shared by the tab pills, the "All" section
 * headings, and the empty states — so a bucket looks the same wherever it
 * appears.
 */
export const PROGRAM_BUCKET_META: Record<ProgramsTab, ProgramBucketMeta> = {
	all: {
		label: "All",
		icon: GraduationCap,
		emptyTitle: "No programs to show",
		emptyMessage:
			"Your programs will appear here once they are available.",
	},
	"in-progress": {
		label: "In Progress",
		icon: Hourglass,
		emptyTitle: "No programs in progress",
		emptyMessage: "When you enroll in a program, it will show up here.",
	},
	completed: {
		label: "Completed",
		icon: Award,
		emptyTitle: "No completed programs",
		emptyMessage: "Programs you finish will appear here.",
	},
	explore: {
		label: "Explore Other",
		icon: Compass,
		emptyTitle: "Nothing else to explore",
		emptyMessage:
			"You're already enrolled in or have completed every program we offer right now.",
	},
}

/** Tab order for the pill list. */
export const PROGRAM_TAB_ITEMS = PROGRAMS_TABS.map((value) => ({
	value,
	label: PROGRAM_BUCKET_META[value].label,
	icon: PROGRAM_BUCKET_META[value].icon,
}))
