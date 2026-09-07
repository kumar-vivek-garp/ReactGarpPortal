import type { ComponentProps } from "react"

import { Input } from "@/components/atoms/input"

type SuggestInputProps = ComponentProps<typeof Input> & {
	id: string
	/** Free text with suggestions — the legacy typeahead, as the platform's own control. */
	suggestions: readonly string[]
}

/**
 * A text input with a `<datalist>` of suggestions.
 *
 * Promoted from the OSTA section once the survey needed the same company and
 * school lists: the browser's native suggestion list needs no extra atom, stays
 * keyboard-accessible for free, and still accepts anything typed — these lists
 * are hints, not an allow-list. The `list` attribute is only set when there is
 * something to suggest, so an empty list does not render a dead dropdown.
 */
function SuggestInput({ id, suggestions, ...props }: SuggestInputProps) {
	const listId = `${id}-suggestions`
	const hasSuggestions = suggestions.length > 0
	return (
		<>
			<Input id={id} list={hasSuggestions ? listId : undefined} {...props} />
			{hasSuggestions ? (
				<datalist id={listId}>
					{suggestions.map((name) => (
						<option key={name} value={name} />
					))}
				</datalist>
			) : null}
		</>
	)
}

export { SuggestInput }
