/**
 * Semantic tone for status pills, shared across modules.
 *
 * Lives here rather than inside any one module's presentation layer so programs,
 * study materials, events, membership and order history all describe status with
 * the same vocabulary — and so `StatusBadge` has one tone→token map to maintain.
 */
export type StatusTone =
	| "neutral"
	| "info"
	| "success"
	| "warning"
	| "danger"
