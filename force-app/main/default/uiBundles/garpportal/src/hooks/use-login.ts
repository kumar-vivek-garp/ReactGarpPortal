import { useMutation } from "@tanstack/react-query"

import { login, type LoginCredentials } from "@/api/auth/login"
import { AppError } from "@/api/client"

/**
 * Login mutation. On success the caller must `window.location.replace(redirectUrl)`
 * so Experience Cloud can set the session cookie.
 * Failures toast via QueryClient MutationCache (not silent).
 */
export function useLogin() {
	return useMutation({
		mutationFn: (credentials: LoginCredentials) => login(credentials),
		meta: { errorTitle: "Sign in failed" },
	})
}

export function getLoginErrorMessages(error: unknown): string[] {
	if (error instanceof AppError) return error.messages
	if (error instanceof Error && error.message) return [error.message]
	return ["Login failed. Please try again."]
}
