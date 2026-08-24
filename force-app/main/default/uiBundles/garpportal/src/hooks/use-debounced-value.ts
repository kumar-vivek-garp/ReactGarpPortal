import { useEffect, useState } from "react"

/**
 * Trails a value by `delay` ms.
 *
 * Used to drive search-as-you-type without a request per keystroke. The
 * *displayed* value stays the live one — only the value the query keys off is
 * delayed — so typing never feels laggy, and the timer resets on every change
 * so a fast typist causes exactly one request.
 */
export function useDebouncedValue<T>(value: T, delay = 350): T {
	const [debounced, setDebounced] = useState(value)

	useEffect(() => {
		const timer = window.setTimeout(() => setDebounced(value), delay)
		return () => window.clearTimeout(timer)
	}, [value, delay])

	return debounced
}
