import { isLocalViteHost } from "@/auth/sfdc-env"
import { ERRATA_PROGRAM_SLUGS } from "@/config/errata"
import { orderDetailsPath } from "@/lib/order-paths"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"

/**
 * Listing-card href helpers — mirrors MyGarp garpApp2 ProgramCard CTAs.
 *
 * View Details: in-app `/programs/{slug}` for Apex-supported types; MyGarp
 * `/sfdcApp#!/myprograms/{type}` otherwise. Register uses MyGarp registration.
 * Learn More goes to garp.org.
 *
 * On local Vite there is no MyGarp — MyGarp links use the sandbox Experience host.
 */

/** Sandbox Experience site that hosts MyGarp (shared with garpportal). */
const LOCAL_MY_GARP_ORIGIN =
	"https://garp--devjuly25a.sandbox.my.site.com" as const

function isSafeHttpUrl(url: string | null | undefined): url is string {
	if (!url?.trim()) return false
	try {
		const parsed = new URL(url.trim())
		return parsed.protocol === "http:" || parsed.protocol === "https:"
	} catch {
		return false
	}
}

/**
 * Portal / Experience relative paths (`/BenchPrepSSO`, `/PearsonVue_SSO`, …).
 * Absolute http(s) URLs pass through. FileDownload uses `resolvePortalAssetUrl`.
 * Other relative paths: Experience site origin on local Vite; site-root on Cloud.
 */
export function resolveExperienceHref(
	url: string | null | undefined,
): string | null {
	const trimmed = url?.trim()
	if (!trimmed) return null
	if (/^https?:\/\//i.test(trimmed)) return trimmed

	const path = trimmed.startsWith("/") ? trimmed : `/${trimmed}`
	if (path.startsWith("/servlet/servlet.FileDownload")) {
		return resolvePortalAssetUrl(path) ?? null
	}
	if (isLocalViteHost()) {
		return `${LOCAL_MY_GARP_ORIGIN}${path}`
	}
	return path
}

/** Lowercase slug for routes and marketing paths (`RiskAI` → `riskai`). */
export function programTypeSlug(programType: string): string {
	return programType.trim().toLowerCase()
}

/**
 * Types Apex `GARP_Portal_ProgramDetailService.normalise` accepts
 * (`frm` / `erp` / `scr` / `raij` / `rai`|`riskai`).
 */
const IN_APP_PROGRAM_DETAIL_SLUGS = new Set([
	"frm",
	"erp",
	"scr",
	"raij",
	"rai",
	"riskai",
])

/** True when View Details can open in-app `/programs/{slug}`. */
export function supportsInAppProgramDetail(programType: string): boolean {
	return IN_APP_PROGRAM_DETAIL_SLUGS.has(programTypeSlug(programType))
}

/**
 * In-app program detail path. Prefer over MyGarp when
 * `supportsInAppProgramDetail` is true.
 */
export function programDetailsPath(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (!slug || !supportsInAppProgramDetail(slug)) return null
	const routeSlug = slug === "rai" ? "riskai" : slug
	return `/programs/${routeSlug}`
}

/**
 * In-app exam results for a program (`/programs/{slug}/results`).
 * Same type gate as program detail.
 */
export function programResultsPath(programType: string): string | null {
	const detail = programDetailsPath(programType)
	return detail ? `${detail}/results` : null
}

/**
 * In-app work experience for a program (`/programs/{slug}/work-experience`).
 *
 * Narrower than the detail gate: only FRM and ERP carry a certification CV,
 * and Apex silently treats anything that is not FRM as ERP — so an unguarded
 * slug would quietly show one programme's CV under another's name.
 */
export function programWorkExperiencePath(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (slug !== "frm" && slug !== "erp") return null
	return `/programs/${slug}/work-experience`
}

/**
 * In-app curriculum errata for a program (`/programs/{slug}/errata`).
 *
 * Narrower than the detail gate: only the programmes in `ERRATA_PROGRAM_SLUGS`
 * — the ones the `errataForm` action accepts — get a link. Whether THIS member
 * may report is Apex's answer (403 → the page's no-access state), not the
 * link's.
 */
export function programErrataPath(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (!slug) return null
	const routeSlug = slug === "rai" ? "riskai" : slug
	return (ERRATA_PROGRAM_SLUGS as readonly string[]).includes(routeSlug)
		? `/programs/${routeSlug}/errata`
		: null
}

/**
 * Absolute on local Vite; same-origin relative on Experience (MyGarp + portal
 * share `*.my.site.com`).
 */
function myGarpSfdcAppHref(hashRoute: string): string {
	const cleaned = hashRoute.replace(/^\/+/, "")
	const path = `/sfdcApp#!/${cleaned}`
	if (isLocalViteHost()) {
		return `${LOCAL_MY_GARP_ORIGIN}${path}`
	}
	return path
}

/**
 * In-app course detail (`/courses/{slug}`).
 *
 * The complement of `programDetailsPath`: anything the two-part detail
 * endpoint does not serve is a course, and `courseDetail` does serve it. Both
 * the three fixed courses and micro courses go here — micro codes cannot be
 * enumerated, so the slug is passed through and Apex resolves it.
 */
export function programCoursePath(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (!slug || supportsInAppProgramDetail(slug)) return null
	return `/courses/${slug}`
}

/**
 * MyGarp program detail (legacy `myprograms-type` → `/myprograms/:examType`).
 *
 * The last-resort fallback. It used to serve FFR / FRR / micro, which now have
 * a real page — see `programCoursePath`. Kept for anything neither endpoint
 * knows about.
 */
export function programDetailsHref(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (!slug) return null
	return myGarpSfdcAppHref(`myprograms/${slug}`)
}

/**
 * Programme slug -> its path on garp.org, for the ones where the two differ.
 *
 * RAIJ is the Japanese sitting of the same Risk AI certification and has no
 * page of its own — `/raij` answers 404, the same way `/raij/exam-policies`
 * does (see `config/registration.ts`). Its marketing page is `/rai/japan`.
 * Anything absent here uses its slug unchanged.
 */
const MARKETING_PATHS: Record<string, string> = {
	riskai: "rai",
	raij: "rai/japan",
}

/**
 * Marketing Learn More URL. MyGarp maps `riskai` → `rai` on garp.org.
 * Falls back to catalogue `policyURL` when no type slug is available.
 */
export function programLearnMoreUrl(
	programType: string,
	policyUrl?: string | null,
): string | null {
	const slug = programTypeSlug(programType)
	const marketingPath = MARKETING_PATHS[slug] ?? slug
	if (marketingPath) {
		return `https://www.garp.org/${marketingPath}`
	}
	return isSafeHttpUrl(policyUrl) ? policyUrl.trim() : null
}

/**
 * In-app registration for a program (`/programs/{slug}/register`).
 *
 * A child segment like `exam-setup` and `errata`, so one dynamic route serves
 * every programme. Note this does NOT depend on `/programs/{slug}` resolving:
 * `programDetail` only serves the two-part exams, but a course-kind programme
 * still registers here.
 */
export function programRegistrationPath(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (!slug) return null
	const routeSlug = slug === "rai" ? "riskai" : slug
	return `/programs/${routeSlug}/register`
}

/**
 * MyGarp registration wizard (garpApp2 `navigateToRegistration`).
 * Prefers Apex `registrationPath`; otherwise derives from program type
 * (RiskAI → `rai`, micro → `micro/{code}`).
 */
export function programRegistrationHref(
	registrationPath: string | null | undefined,
	programType: string,
	isMicroCourse = false,
): string | null {
	let path = registrationPath?.trim() || ""
	if (!path) {
		const slug = programTypeSlug(programType)
		if (!slug) return null
		if (slug === "riskai") path = "rai"
		else if (isMicroCourse) path = `micro/${slug}`
		else path = slug
	}
	const cleaned = path.replace(/^\/+/, "")
	if (!cleaned) return null
	return myGarpSfdcAppHref(`registration/${cleaned}`)
}

/**
 * In-app exam setup for a program (`/programs/{slug}/exam-setup`).
 *
 * Same type gate as program detail, because Apex `examSetup` accepts exactly
 * the set `programDetail` does. This is also the deferral route — moving to a
 * different exam administration IS the deferral, and the wizard prices it.
 */
export function programExamSetupHref(programType: string): string | null {
	const detail = programDetailsPath(programType)
	return detail ? `${detail}/exam-setup` : null
}

/**
 * The legacy sfdcApp wizard, still needed for the half we cannot finish here.
 *
 * One hand-off uses it now: the provider push, while
 * `EXAM_SETUP_AUTHORIZE_ENABLED` is off. Not a route in this app, so this stays
 * a full-page navigation and must never be given to `<Link>`.
 */
export function programExamSetupMyGarpHref(
	programType: string,
): string | null {
	const slug = programTypeSlug(programType)
	if (!slug) return null
	const routeSlug = slug === "rai" ? "riskai" : slug
	return myGarpSfdcAppHref(`programs/exam-setup/${routeSlug}`)
}

/**
 * The legacy fees checkout for a raised exam modification.
 *
 * `examSetupFees` prices a change but returns no order and no checkout URL, and
 * nothing in the portal API raises the Opportunity the lines are billed
 * against — so the charge is taken by the legacy app, which the member is sent
 * to through its own login so the session is established before the deep link
 * resolves.
 *
 * Not a hash route, so it does not go through `myGarpSfdcAppHref`. Like that
 * helper it is absolute on local Vite and same-origin elsewhere, and it is a
 * full-page navigation — never a `<Link>`.
 */
export function examSetupFeesCheckoutHref(
	modificationId: string | null | undefined,
): string | null {
	const id = modificationId?.trim()
	if (!id) return null
	// Only the id is encoded — the path separators in `start` are part of the
	// legacy route and must survive.
	const path = `/Login?start=myprograms/setup/feescheckout/${encodeURIComponent(id)}`
	return isLocalViteHost() ? `${LOCAL_MY_GARP_ORIGIN}${path}` : path
}

/**
 * The legacy checkout that reorders a printed certificate.
 *
 * FRM and ERP certificates are not downloadable at all — a copy is bought
 * through this checkout, keyed by programme type, which only the legacy app
 * can run. Same host rule and login hand-off as `examSetupFeesCheckoutHref`,
 * and a full-page navigation for the same reason — never a `<Link>`.
 */
export function certificateCopyCheckoutHref(
	programType: string,
): string | null {
	const slug = programTypeSlug(programType)
	if (!slug) return null
	const path = `/Login?start=myprograms/certcheckout/${encodeURIComponent(slug)}`
	return isLocalViteHost() ? `${LOCAL_MY_GARP_ORIGIN}${path}` : path
}

/**
 * The study-materials catalogue filtered to one programme.
 *
 * `?tab=` takes a `StudyMaterial.programKey`, which uses the marketing slug —
 * `rai`, not `riskai` — so the rewrite runs the other way from the route
 * helpers above. Same-origin and a route, so `<Link>`-safe.
 */
export function programStudyMaterialsPath(programType: string): string {
	const slug = programTypeSlug(programType)
	if (!slug) return "/study-materials"
	const key = slug === "riskai" ? "rai" : slug
	return `/study-materials?tab=${encodeURIComponent(key)}`
}

/**
 * In-app order detail for unpaid registration orders
 * (`/my-account/orders/:orderNumber` — Opportunity Id or invoice #).
 */
export function programOrderHref(
	orderId: string | null | undefined,
): string | null {
	return orderDetailsPath(orderId)
}
