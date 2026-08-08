import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AuthApiError,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import { AUTH_API } from "@/auth/constants"
import { clearLocalLogoutFlag } from "@/auth/local-session"

export type LoginCredentials = {
	email: string
	password: string
	startUrl: string
}

export type LoginSuccess = {
	success: true
	redirectUrl: string
}

type LoginBody = {
	success?: boolean
	redirectUrl?: string | null
	errors?: string[]
}

/**
 * Authenticates via Apex `UIBundleLogin` (`Site.login`).
 * On success, caller must hard-navigate to `redirectUrl` so Salesforce can set the session cookie.
 */
export async function login(credentials: LoginCredentials): Promise<LoginSuccess> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(AUTH_API.LOGIN, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({
			email: credentials.email.trim().toLowerCase(),
			password: credentials.password,
			startUrl: credentials.startUrl,
		}),
	})

	const result = await normalizeHttpResponse<LoginBody>(response, {
		unreachableMessage: "Unable to reach the login service.",
		fallbackErrorMessage: "An unexpected error occurred. Please try again.",
	})

	const data = unwrapApiResult(result)
	const status = result.ok ? result.status : 400

	if (data.redirectUrl) {
		clearLocalLogoutFlag()
		return { success: true, redirectUrl: data.redirectUrl }
	}

	if (data.errors?.length) {
		throw new AuthApiError(data.errors, status)
	}

	throw new AuthApiError(["Login failed. Please try again."], status)
}
