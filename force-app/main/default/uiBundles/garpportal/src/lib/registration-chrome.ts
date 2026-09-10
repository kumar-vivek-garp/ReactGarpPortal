import { programChrome, type ProgramChrome } from "@/config/program-chrome"
import type { MegaMenuHeading } from "@/config/navigation/types"
import { publicRegistrationProgramSlug } from "@/lib/registration-paths"
import {
	canonicalProgramSlug,
	resolveExamProgram,
} from "@/lib/registration-programs"

/**
 * The designed chrome a programme's registration surfaces should wear, or
 * `undefined` when that programme has none yet.
 *
 * Not guest-only, despite where it started. Four callers now reach the same
 * rule from different directions and must not disagree:
 *
 * - `PublicShell` — by pathname, to decide whether to render the guest banner
 * - the public route — by slug, to decide whether the form's bar stands its
 *   title down
 * - the member registration bar — by slug, for the seal and brand wash
 * - the Exam Setup bar — likewise
 *
 * Disagreement is not cosmetic: if the route suppressed the title for a
 * programme the shell has no banner for, that page would have no `h1` at all.
 *
 * Both halves must resolve. A programme with artwork but no registration config
 * could not title its own banner, and one with config but no artwork has
 * nothing to show — either way the honest answer is today's GARP chrome, not a
 * half-redesigned page. That is also what keeps the guest 404,
 * `/registration/affiliate`, `raij` and every un-redesigned programme on the
 * existing look, and what lets programmes land one at a time.
 *
 * The slug is canonicalised first: `/registration/rai` is a live marketing
 * address that resolves to the `riskai` programme, so a raw lookup would miss
 * the chrome on a URL GARP actually publishes.
 */
export type RegistrationChrome = {
	chrome: ProgramChrome
	heading: MegaMenuHeading
}

export function registrationChromeForSlug(
	slug: string | null | undefined,
): RegistrationChrome | undefined {
	if (!slug?.trim()) return undefined

	const chrome = programChrome(canonicalProgramSlug(slug))
	if (!chrome) return undefined

	const program = resolveExamProgram(slug)
	if (!program) return undefined

	return { chrome, heading: program.heading }
}

/**
 * The same decision from a pathname, for `PublicShell` — which is an *ancestor*
 * of the route that owns `$programType` and so cannot read the param.
 */
export function registrationChromeForPath(
	pathname: string,
): RegistrationChrome | undefined {
	return registrationChromeForSlug(
		publicRegistrationProgramSlug(pathname),
	)
}
