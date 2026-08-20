/**
 * Icon-prefixed metadata rows, shared across modules.
 *
 * Presentation layers stay React-free by naming an icon *key* rather than
 * importing a component, so the key union lives here and `MetaLines` owns the
 * mapping to actual Lucide icons.
 */
export type MetaIcon =
	// programs
	| "administration"
	| "registrationOpen"
	| "opensLater"
	| "microCourse"
	| "certified"
	// events
	| "when"
	| "location"
	| "eventType"
	// study materials
	| "accessUntil"
	| "expiringSoon"
	| "lastOpened"
	| "unavailable"
	| "price"
	| "materialType"
	// my account identity
	| "email"
	| "phone"
	| "memberSince"
	| "renews"
	// order history
	| "invoice"
	| "paymentMethod"

export type MetaLine = {
	icon: MetaIcon
	text: string
}
