import { useState, type KeyboardEvent, type PointerEvent } from "react"
import { useSpring } from "@react-spring/web"

/**
 * Snappier than the hover nudge — a press should register immediately, then
 * settle back with a touch of overshoot so it feels sprung rather than linear.
 */
const PRESS_SPRING = { mass: 0.6, tension: 420, friction: 18 } as const

const PRESSED_SCALE = 0.96

/** Keys that activate a button/tab and so should feel like a press. */
const ACTIVATION_KEYS = new Set([" ", "Enter", "Spacebar"])

/** Calls our handler and then the consumer's, so neither is clobbered. */
function chain<E>(
	ours: (event: E) => void,
	theirs?: (event: E) => void,
): (event: E) => void {
	return (event: E) => {
		ours(event)
		theirs?.(event)
	}
}

type ExternalHandlers<T extends Element> = {
	onPointerDown?: (event: PointerEvent<T>) => void
	onPointerUp?: (event: PointerEvent<T>) => void
	onPointerLeave?: (event: PointerEvent<T>) => void
	onPointerCancel?: (event: PointerEvent<T>) => void
	onKeyDown?: (event: KeyboardEvent<T>) => void
	onKeyUp?: (event: KeyboardEvent<T>) => void
}

type UseSpringPressOptions<T extends Element> = ExternalHandlers<T> & {
	disabled?: boolean
}

/**
 * Physics-based press feedback for any control — the third motion primitive
 * alongside `useSpringNudge` (hover) and `StaggerReveal` (list reveal).
 *
 * Spread `bind` onto the interactive element and merge `style` into its style.
 * Keyboard activation is covered too, so Enter / Space feel like a click rather
 * than nothing at all.
 *
 * Reduced motion is handled globally by `useReducedMotion()` in `pages/__root.tsx`.
 */
export function useSpringPress<T extends Element = HTMLButtonElement>({
	disabled = false,
	onPointerDown,
	onPointerUp,
	onPointerLeave,
	onPointerCancel,
	onKeyDown,
	onKeyUp,
}: UseSpringPressOptions<T> = {}) {
	const [pressed, setPressed] = useState(false)
	const engaged = pressed && !disabled

	const style = useSpring({
		scale: engaged ? PRESSED_SCALE : 1,
		config: PRESS_SPRING,
	})

	const press = () => setPressed(true)
	const release = () => setPressed(false)

	const bind = {
		onPointerDown: chain<PointerEvent<T>>(press, onPointerDown),
		onPointerUp: chain<PointerEvent<T>>(release, onPointerUp),
		// Dragging off the control cancels the press, matching native buttons.
		onPointerLeave: chain<PointerEvent<T>>(release, onPointerLeave),
		onPointerCancel: chain<PointerEvent<T>>(release, onPointerCancel),
		onKeyDown: chain<KeyboardEvent<T>>((event) => {
			// `repeat` guards held keys from re-triggering the spring every frame.
			if (!event.repeat && ACTIVATION_KEYS.has(event.key)) press()
		}, onKeyDown),
		onKeyUp: chain<KeyboardEvent<T>>((event) => {
			if (ACTIVATION_KEYS.has(event.key)) release()
		}, onKeyUp),
	}

	return { bind, style, pressed: engaged }
}
