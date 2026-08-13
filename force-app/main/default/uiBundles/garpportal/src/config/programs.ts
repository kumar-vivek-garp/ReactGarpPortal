import { z } from "zod"

export const PROGRAMS_TABS = [
	"all",
	"in-progress",
	"completed",
	"explore",
] as const

export type ProgramsTab = (typeof PROGRAMS_TABS)[number]

export const DEFAULT_PROGRAMS_TAB: ProgramsTab = "all"

export const programsSearchSchema = z.object({
	tab: z.enum(PROGRAMS_TABS).catch(DEFAULT_PROGRAMS_TAB),
})

export type ProgramsSearch = z.infer<typeof programsSearchSchema>
