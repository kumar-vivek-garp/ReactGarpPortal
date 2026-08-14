import { getSfdcEnv, isLocalViteHost } from "@/auth/sfdc-env"

/** Must match Vite proxy + `LOCAL_SF_PREFIX` in local-cli-auth (localhost Vite). */
const LOCAL_SF_ASSET_PREFIX = "/__local_sf" as const
const LOCAL_SF_API_VERSION = "67.0"

/**
 * Experience site path from `SFDC_ENV.basePath` (e.g. `/garpportal`).
 * Absolute `/servlet/...` URLs must be under this prefix or the browser hits
 * the domain root and FileDownload returns the login page instead of the file.
 */
function experienceBasePath(): string {
	const base = (getSfdcEnv()?.basePath ?? "").replace(/\/+$/, "")
	if (!base || base === "/") return ""
	return base.startsWith("/") ? base : `/${base}`
}

/**
 * Turns portal-relative asset paths into a browser-loadable URL.
 *
 * `Contact.Photo_URL__c` is stored as `/servlet/servlet.FileDownload?file=…`.
 * On Experience Cloud that path is same-origin **under the site base path**
 * (session cookies). On local Vite, FileDownload returns login HTML under a
 * bearer token, so we map the Attachment Id to the REST Body endpoint via the
 * CLI gateway.
 */
export function resolvePortalAssetUrl(
	url: string | null | undefined,
): string | undefined {
	const trimmed = url?.trim()
	if (!trimmed) return undefined

	if (/^https?:\/\//i.test(trimmed) || trimmed.startsWith("data:")) {
		return trimmed
	}

	const path = trimmed.startsWith("/") ? trimmed : `/${trimmed}`

	if (isLocalViteHost()) {
		const attachmentId = attachmentIdFromFileDownload(path)
		if (attachmentId) {
			return `${LOCAL_SF_ASSET_PREFIX}/services/data/v${LOCAL_SF_API_VERSION}/sobjects/Attachment/${attachmentId}/Body`
		}
		return path
	}

	const base = experienceBasePath()
	if (!base) return path
	if (path === base || path.startsWith(`${base}/`)) return path
	return `${base}${path}`
}

function attachmentIdFromFileDownload(path: string): string | null {
	if (!path.startsWith("/servlet/servlet.FileDownload")) return null
	const queryIndex = path.indexOf("?")
	if (queryIndex < 0) return null
	const fileId = new URLSearchParams(path.slice(queryIndex + 1)).get("file")
	const trimmed = fileId?.trim()
	return trimmed || null
}
