export type SfdcEnv = {
	basePath?: string
	apiPath?: string
	orgUrl?: string
}

export function getSfdcEnv(): SfdcEnv | undefined {
	return (globalThis as { SFDC_ENV?: SfdcEnv }).SFDC_ENV
}

/** True when the UI Bundle runs under Vite on localhost (org API is proxied). */
export function isLocalViteHost(): boolean {
	if (typeof window === "undefined") return false
	const { hostname } = window.location
	return hostname === "localhost" || hostname === "127.0.0.1"
}
