import { useNavigate } from "@tanstack/react-router"

import { parseInternalAppHref } from "@/lib/parse-internal-app-href"

/** Where a whole-card click should go, in the shape the listing builders emit. */
export type CardActivationTarget = {
	url: string
	isExternal: boolean
} | null

type CardActivationProps = {
	interactive: boolean
	role?: "link"
	tabIndex?: number
	"aria-label"?: string
	onActivate?: () => void
}

/**
 * Turns a card's single destination into the props that make the whole card
 * the hit target — spread straight onto `Card`.
 *
 * The card becomes a `role="link"` with `onActivate` rather than wrapping its
 * content in an `<a>`: a programme card already contains a link (the Results
 * chip), and an anchor inside an anchor is invalid HTML that browsers repair
 * by breaking the outer one apart. Anything interactive nested inside a card
 * that uses this must stop its own click from bubbling, or both destinations
 * fire.
 *
 * Returns `{ interactive: false }` when there is nowhere to go, so a card with
 * no details link keeps its flat, un-hoverable surface and does not imply a
 * click that would do nothing.
 */
export function useCardActivation(
	target: CardActivationTarget,
	ariaLabel: string,
): CardActivationProps {
	const navigate = useNavigate()

	if (!target?.url) return { interactive: false }

	const { url, isExternal } = target

	return {
		interactive: true,
		role: "link",
		tabIndex: 0,
		"aria-label": ariaLabel,
		onActivate: () => {
			/*
			 * External here means MyGarp (`/sfdcApp#!/…`) or garp.org — not a
			 * route, so it has to be a full-page navigation. `assign` rather than
			 * `href =` so a test can spy on it.
			 */
			if (isExternal) {
				window.location.assign(url)
				return
			}
			const { pathname, search } = parseInternalAppHref(url)
			void navigate({ to: pathname, search })
		},
	}
}
