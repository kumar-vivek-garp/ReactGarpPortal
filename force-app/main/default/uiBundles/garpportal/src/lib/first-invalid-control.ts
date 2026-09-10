/**
 * The first control in `root` that is currently invalid, in DOM order —
 * which is visual order, so it is also the first one a person would reach.
 *
 * Found by `aria-invalid="true"`, not by a field-name → id map: every control
 * that can be invalid already sets that attribute (it is what draws the red
 * border through `aria-invalid:border-destructive` on the atoms), and control
 * ids do not follow field names consistently anywhere (`billing.street1` ↔
 * `billing-street1`, `email` ↔ `event-reg-email`). It also means required
 * state react-hook-form does not own — the exam choice — is found the same
 * way, as long as its section flags itself.
 *
 * The flagged element is not always focusable: a `div[role="radiogroup"]` is
 * flagged as a whole, and what should take focus is its first live radio.
 */
export function firstInvalidControl(root: HTMLElement): HTMLElement | null {
	const flagged = root.querySelector<HTMLElement>('[aria-invalid="true"]')
	if (!flagged) return null
	if (isFocusableControl(flagged)) return flagged
	return flagged.querySelector<HTMLElement>(FOCUSABLE_DESCENDANT) ?? flagged
}

const CONTROL_TAGS = new Set(["INPUT", "SELECT", "TEXTAREA", "BUTTON"])

/*
 * Deliberately NOT `[tabindex]`: a Radix `RadioGroup` root carries
 * `tabIndex=0` and, on focus, forwards to an item with a plain `focus()` —
 * no `preventScroll` — which is exactly the browser jump the caller is
 * avoiding. Landing on the item directly sidesteps that. The exclusions skip
 * Radix's hidden bubble `<input aria-hidden tabindex=-1>` siblings and a tile
 * disabled for the chosen country.
 */
const FOCUSABLE_DESCENDANT = [
	"button:not([disabled])",
	"input:not([disabled])",
	"select:not([disabled])",
	"textarea:not([disabled])",
	"a[href]",
]
	.map((selector) => `${selector}:not([aria-hidden="true"]):not([tabindex="-1"])`)
	.join(", ")

function isFocusableControl(element: HTMLElement): boolean {
	return CONTROL_TAGS.has(element.tagName) && !element.hasAttribute("disabled")
}
