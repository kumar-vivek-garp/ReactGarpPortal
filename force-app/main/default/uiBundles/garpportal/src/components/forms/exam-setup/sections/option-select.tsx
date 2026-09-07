import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"

type OptionSelectProps = {
	id: string
	value: string
	options: readonly string[]
	placeholder: string
	onChange: (value: string) => void
	"aria-invalid"?: boolean
	"aria-label"?: string
}

/**
 * A string-list select.
 *
 * `value` is always a string, never `undefined` — handing Radix `undefined`
 * latches the Select into uncontrolled mode, after which every later value is
 * ignored and the field renders its placeholder forever.
 */
function OptionSelect({
	id,
	value,
	options,
	placeholder,
	onChange,
	...aria
}: OptionSelectProps) {
	return (
		<Select value={value} onValueChange={onChange}>
			<SelectTrigger
				id={id}
				className="w-full"
				aria-invalid={aria["aria-invalid"] ? true : undefined}
				aria-label={aria["aria-label"]}
			>
				<SelectValue placeholder={placeholder} />
			</SelectTrigger>
			<SelectContent>
				{options.map((option) => (
					<SelectItem key={option} value={option}>
						{option}
					</SelectItem>
				))}
			</SelectContent>
		</Select>
	)
}

export { OptionSelect }
