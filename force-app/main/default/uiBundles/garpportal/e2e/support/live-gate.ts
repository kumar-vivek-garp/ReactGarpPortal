/**
 * Availability + org-identity gate for the live suite. Probed via the
 * gateway's /health (which shells out to the sf CLI — slow on first call;
 * probe once per file, not per test). The org must be the EXPECTED one:
 * without the SF_TARGET_ORG pin the gateway silently resolves the
 * project-local default, which is currently the preprod org.
 */

export const EXPECTED_ORG = process.env.SF_TARGET_ORG ?? "devjuly25a"

export type LiveGate = {
	ok: boolean
	reason: string
	username?: string
	orgId?: string
	targetOrg?: string
}

type GatewayHealth = {
	ok?: boolean
	username?: string | null
	orgId?: string | null
	targetOrg?: string | null
	error?: string
	hint?: string
}

export async function probeGateway(): Promise<LiveGate> {
	try {
		const response = await fetch("http://127.0.0.1:8787/health", {
			headers: { Accept: "application/json" },
		})
		const health = (await response.json()) as GatewayHealth
		if (!response.ok || health.ok !== true) {
			return {
				ok: false,
				reason: `gateway not ready: ${health.error ?? `HTTP ${response.status}`}${
					health.hint ? ` (${health.hint})` : ""
				}`,
			}
		}
		if (health.targetOrg !== EXPECTED_ORG) {
			return {
				ok: false,
				reason: `gateway is pointed at org "${health.targetOrg}", expected "${EXPECTED_ORG}" — refusing to run live reads against the wrong org`,
			}
		}
		return {
			ok: true,
			reason: "ready",
			username: health.username ?? undefined,
			orgId: health.orgId ?? undefined,
			targetOrg: health.targetOrg ?? undefined,
		}
	} catch (error) {
		return {
			ok: false,
			reason: `gateway unreachable (${String(error)}) — start it with: SF_TARGET_ORG=${EXPECTED_ORG} npm run local-sf (repo root)`,
		}
	}
}
