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
 * Narrower than the detail gate. Apex entitles a member holding an activated
 * contract on FRM, SCR, RiskAI, RAIJ or ICBRR — everything else (FRR, FRR25,
 * micro courses) has no published curriculum to report against, and the legacy
 * hides the link for exactly those.
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
 * Marketing Learn More URL. MyGarp maps `riskai` → `rai` on garp.org.
 * Falls back to catalogue `policyURL` when no type slug is available.
 */
export function programLearnMoreUrl(
	programType: string,
	policyUrl?: string | null,
): string | null {
	const slug = programTypeSlug(programType)
	const marketingSlug = slug === "riskai" ? "rai" : slug
	if (marketingSlug) {
		return `https://www.garp.org/${marketingSlug}`
	}
	return isSafeHttpUrl(policyUrl) ? policyUrl.trim() : null
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
 * MyGarp exam-setup wizard (`garpApp2` path `programs/exam-setup/:program`).
 * Phase C will replace this with an in-app wizard once write APIs land.
 */
export function programExamSetupHref(programType: string): string | null {
	const slug = programTypeSlug(programType)
	if (!slug) return null
	const routeSlug = slug === "rai" ? "riskai" : slug
	return myGarpSfdcAppHref(`programs/exam-setup/${routeSlug}`)
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
