export type SfdcEnv = {
	basePath?: string
	apiPath?: string
	orgUrl?: string
}

export function getSfdcEnv(): SfdcEnv | undefined {
	return (globalThis as { SFDC_ENV?: SfdcEnv }).SFDC_ENV
}

/**
 * The org-specific path the bundle is mounted at, without a trailing slash —
 * `""` on local Vite, `/lwr/application/…` on the Experience site. Anything
 * that builds an absolute URL to an in-app route (a payment provider's return
 * address) must prefix it with this; `location.pathname` already carries it.
 */
export function siteBasePath(): string {
	return (getSfdcEnv()?.basePath ?? "").replace(/\/+$/, "")
}

/** True when the UI Bundle runs under Vite on localhost (org API is proxied). */
export function isLocalViteHost(): boolean {
	if (typeof window === "undefined") return false
	const { hostname } = window.location
	return hostname === "localhost" || hostname === "127.0.0.1"
}
