import type { PicklistOption } from "@/api/account/types"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"

type PicklistSelectProps = {
	id: string
	/** Always a string — `""` shows the placeholder. Never `undefined`: that
	 * latches Radix into uncontrolled mode and the placeholder never leaves. */
	value: string
	options: readonly PicklistOption[]
	placeholder: string
	onChange: (value: string) => void
	disabled?: boolean
}

/** One picklist question: label/value pairs from the org's field describe. */
function PicklistSelect({
	id,
	value,
	options,
	placeholder,
	onChange,
	disabled,
}: PicklistSelectProps) {
	return (
		<Select value={value} onValueChange={onChange} disabled={disabled}>
			<SelectTrigger id={id} className="w-full">
				<SelectValue placeholder={placeholder} />
			</SelectTrigger>
			<SelectContent>
				{options.map((option) => (
					<SelectItem key={option.value} value={option.value}>
						{option.label}
					</SelectItem>
				))}
			</SelectContent>
		</Select>
	)
}

/** A plain string list (years) as picklist options. */
export function asPicklistOptions(values: readonly string[]): PicklistOption[] {
	return values.map((value) => ({ label: value, value }))
}

export { PicklistSelect }
