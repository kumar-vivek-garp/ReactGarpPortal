import { EXAM_PROGRAMS, type ExamProgramConfig } from "@/config/registration"

/**
 * Legacy URL slugs that are not the programme key.
 *
 * The registration module rejects anything that is not a key of its own
 * registry — `load('rai')` throws `Unsupported registration type: rai`, it does
 * not fall back. But `rai` is a live public address: the legacy sfdcApp routed
 * Risk AI at `#!/registration/rai`, the portal catalogue sells it under that
 * slug, and garp.org's marketing links use it. Without this map those URLs
 * reach the form and then dead-end on a load error.
 *
 * Only inbound resolution lives here. `programRegistrationPath` already emits
 * the canonical `riskai`, so nothing this app generates needs translating.
 */
const SLUG_ALIASES: Record<string, string> = {
	rai: "riskai",
}

/** A route param reduced to the slug the registration module answers to. */
export function canonicalProgramSlug(slug: string): string {
	const raw = slug.trim().toLowerCase()
	return SLUG_ALIASES[raw] ?? raw
}

/**
 * The programme this route param names, or null when no form is built for it.
 *
 * Null is not an error — `ffr`, `frr`, `frr25`, `mem` and `micro` are all real
 * programmes whose forms are still to be written, and the dispatcher gives
 * them a placeholder page rather than a dead end.
 */
export function resolveExamProgram(slug: string): ExamProgramConfig | null {
	return EXAM_PROGRAMS[canonicalProgramSlug(slug)] ?? null
}
