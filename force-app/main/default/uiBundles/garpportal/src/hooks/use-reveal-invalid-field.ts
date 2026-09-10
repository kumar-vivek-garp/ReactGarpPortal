import { useCallback, useEffect, useRef, useState } from "react"

import { firstInvalidControl } from "@/lib/first-invalid-control"
import { useSpringScrollTo } from "@/hooks/use-spring-scroll-to"

/**
 * After a submit attempt, scroll the first invalid control into view and
 * focus it.
 *
 * The forms no longer disable their submit button until valid — a dead button
 * with a tooltip is not an explanation. Instead the click runs validation,
 * every invalid control gets its red border and inline error as before, and
 * this hook makes sure the FIRST of them is on screen with focus, so the next
 * keystroke fixes it.
 *
 * Wire-up, three lines:
 *
 *   const { formState: { submitCount } } = useForm({ …, shouldFocusError: false })
 *   const { formRef } = useRevealInvalidField(submitCount)
 *   <form ref={formRef} onSubmit={handleSubmit(onValid)} noValidate>
 *
 * **Keyed on `submitCount`, not on a callback.** react-hook-form awaits
 * `onInvalid` and only THEN pushes `{ submitCount, errors }` to subscribers in
 * one update — so an effect on `submitCount` runs after the commit that put
 * `aria-invalid` into the DOM, guaranteed. A counter bumped from inside
 * `onInvalid` would run a commit early and find nothing. State a form keeps
 * outside react-hook-form (the exam choice) is flagged in the same submit
 * tick, so it batches into the same commit and is found the same way.
 *
 * **`shouldFocusError: false` is required.** react-hook-form's own focus
 * calls `ref.focus()` without `preventScroll` — an instant jump the spring
 * then glides back from — walks fields in registration order rather than DOM
 * order, and cannot see a `Controller` anyway (nothing here attaches
 * `field.ref`). One focus, ours.
 *
 * `reveal()` is the escape hatch for a form that flags something outside
 * react-hook-form AFTER `submitCount` has already moved — none of the current
 * forms need it, but the next one might.
 */
export function useRevealInvalidField(submitCount: number) {
	const formRef = useRef<HTMLFormElement | null>(null)
	const [nudge, setNudge] = useState(0)
	const { scrollTo } = useSpringScrollTo()

	useEffect(() => {
		if (submitCount === 0 && nudge === 0) return
		const root = formRef.current
		if (!root) return
		const target = firstInvalidControl(root)
		if (!target) return

		// Scroll first, then focus WITHOUT the browser's own scroll — the other
		// order jumps to the element and then springs back from it.
		scrollTo(target, { align: "center", ifNeeded: true })
		target.focus({ preventScroll: true })
	}, [submitCount, nudge, scrollTo])

	const reveal = useCallback(() => {
		setNudge((count) => count + 1)
	}, [])

	return { formRef, reveal }
}
