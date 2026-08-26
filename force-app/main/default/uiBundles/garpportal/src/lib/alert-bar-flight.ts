/**
 * The physics and the maths behind the alert card's minimise-to-toolbar flight.
 *
 * Kept here, and kept pure, for the same reason `alert-bar-presentation` is:
 * a rule that lives inside a spring callback can only be checked by watching
 * it, and "it lands slightly off" is exactly the kind of bug nobody files.
 */

/**
 * The travel itself.
 *
 * Heavier and much softer than the chrome vocabulary in `nav-spring`, and
 * deliberately not part of it: that vocabulary is near-critically damped
 * because it drives surfaces a member meets on every page, where settling
 * quietly beats being seen. This is the opposite — a one-off gesture that has
 * to be *watched* to be understood, over a diagonal several hundred pixels
 * long. At mega-menu stiffness the card arrives before the eye has followed it.
 */
export const ALERT_FLIGHT_SPRING = { mass: 1.1, tension: 210, friction: 30 } as const

/**
 * The trigger's arrival, once the card has landed in it.
 *
 * Low friction so it visibly overshoots. That bounce is what stitches the two
 * halves together: without it the card disappearing and the button appearing
 * read as two unrelated animations rather than one thing being put away.
 * Same intent as `POP_SPRING` in `forms/exam-registration/animated-amount`.
 */
export const ALERT_LANDING_SPRING = { mass: 0.7, tension: 380, friction: 14 } as const

/**
 * Progress at which the card starts to fade, as a fraction of the journey.
 *
 * The card used to fade on the same spring that moved it, which meant it was
 * half transparent a third of the way across and the eye got a dissolving
 * ghost instead of a travelling object. Holding it solid for the first stretch
 * is the whole difference between the two.
 */
const FADE_STARTS_AT = 0.55

/** The slice of `DOMRect` this module needs — so a test can pass a literal. */
export type FlightRect = {
	top: number
	left: number
	width: number
	height: number
}

export type FlightPose = {
	x: number
	y: number
	scale: number
}

/**
 * How small the card gets before it hands over to the toolbar button.
 *
 * Small enough that it reads as being swallowed by the trigger rather than
 * merely getting smaller and vanishing.
 */
const LANDED_SCALE = 0.14

/**
 * With no toolbar to aim at, the card lifts and fades on the spot rather than
 * flying to the viewport origin. Reachable if both toolbars are unmounted —
 * a layout that shows the alert but no chrome — so it degrades instead of
 * throwing the card into the top-left corner.
 */
const NO_ANCHOR_POSE: FlightPose = { x: 0, y: -24, scale: 0.9 }

/**
 * Lands the card's **top-right** corner on the anchor's centre.
 *
 * The card scales about that same corner (`transform-origin: top right`), so
 * it is the one point that does not move under the scale and therefore the one
 * point worth aiming. Anchoring the card's centre instead would leave it
 * visibly short of the button by half its own shrunken width.
 */
export function computeFlightPose(
	card: FlightRect,
	anchor: FlightRect | null,
): FlightPose {
	if (!anchor) return NO_ANCHOR_POSE

	const cardRight = card.left + card.width
	const anchorCentreX = anchor.left + anchor.width / 2
	const anchorCentreY = anchor.top + anchor.height / 2

	return {
		x: anchorCentreX - cardRight,
		y: anchorCentreY - card.top,
		scale: LANDED_SCALE,
	}
}

/**
 * The card's opacity at a given point along the flight — `0` at rest, `1` when
 * it has landed in the trigger.
 *
 * Keyed on progress rather than on the pose's scale, because the no-anchor
 * fallback barely shrinks: read off scale, that degraded flight would never
 * fade out at all and the card would simply stall in mid-air.
 *
 * Clamped at both ends because a spring overshoots — `t` genuinely arrives
 * above 1, and an unclamped ramp would push the opacity negative and flicker.
 */
export function flightFade(t: number): number {
	if (t <= FADE_STARTS_AT) return 1
	if (t >= 1) return 0
	return 1 - (t - FADE_STARTS_AT) / (1 - FADE_STARTS_AT)
}

/**
 * The first anchor that is actually on screen.
 *
 * The desktop and mobile toolbars are both mounted at all times and hidden
 * from each other with `app:` / `app:hidden`. A `display: none` subtree
 * measures as a zero rect, which makes width the honest test of which one the
 * member can currently see — cheaper and less brittle than reading computed
 * styles or duplicating the breakpoint in JS.
 */
export function resolveAnchorRect(
	anchors: Array<HTMLElement | null>,
): FlightRect | null {
	for (const element of anchors) {
		const rect = element?.getBoundingClientRect()
		if (rect && rect.width > 0) return rect
	}
	return null
}
