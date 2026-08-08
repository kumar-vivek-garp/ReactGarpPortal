/**
 * Normalized client-side API failure. Domain modules throw this after inspecting
 * raw Salesforce / Apex / GraphQL / fetch responses.
 */
export class AppError extends Error {
	readonly status: number
	readonly messages: string[]
	readonly code?: string
	readonly cause?: unknown

	constructor(options: {
		messages: string[]
		status?: number
		code?: string
		cause?: unknown
	}) {
		const messages =
			options.messages.length > 0 ? options.messages : ["Request failed"]
		super(messages[0])
		this.name = "AppError"
		this.messages = messages
		this.status = options.status ?? 0
		this.code = options.code
		this.cause = options.cause
	}

	/** @deprecated Prefer `messages` — kept for login form helpers. */
	get errors(): string[] {
		return this.messages
	}

	static fromUnknown(
		error: unknown,
		fallback = "Something went wrong. Please try again.",
	): AppError {
		if (error instanceof AppError) return error
		if (error instanceof Error && error.message) {
			return new AppError({ messages: [error.message], cause: error })
		}
		return new AppError({ messages: [fallback] })
	}
}

/** Apex auth endpoints historically used this name. Alias of AppError. */
export class AuthApiError extends AppError {
	constructor(errors: string[], status = 400) {
		super({ messages: errors, status })
		this.name = "AuthApiError"
	}
}
