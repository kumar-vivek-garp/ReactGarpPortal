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
	/*
	 * The membership programme's wire type is `mem` (`GARP_ExamReg_Program__mdt`
	 * keys it that way) but its address is `/registration/membership`, as in
	 * GarpAppv1 and the legacy app. Either slug reaches the same entry.
	 */
	mem: "membership",
}

/** A route param reduced to the slug the registration module answers to. */
export function canonicalProgramSlug(slug: string): string {
	const raw = slug.trim().toLowerCase()
	return SLUG_ALIASES[raw] ?? raw
}

/**
 * The programme this route param names, or null when no form is built for it.
 *
 * Null is not an error — `micro` is a real programme whose form is still to
 * be written, and the dispatcher gives it a placeholder page rather than a
 * dead end.
 */
export function resolveExamProgram(slug: string): ExamProgramConfig | null {
	return EXAM_PROGRAMS[canonicalProgramSlug(slug)] ?? null
}
