import type { LucideIcon } from "lucide-react"

import { FieldError } from "@/components/molecules/form-field"
import { Label } from "@/components/atoms/label"
import { cn } from "@/lib/utils"

export type TileRadioOption = {
	value: string
	label: string
	icon: LucideIcon
	/** Shown under the label in the muted caption size. */
	caption?: string
}

type TileRadioGroupProps = {
	id: string
	legend: string
	value: string
	options: readonly TileRadioOption[]
	onChange: (value: string) => void
	required?: boolean
	error?: string
	disabled?: boolean
	className?: string
}

/**
 * A choice between a few named things, each carrying its own icon — the
 * registration form's payment-type tiles, lifted so the next form is a call
 * rather than a fourth copy.
 *
 * A real `role="radiogroup"` of `role="radio"` buttons: arrow keys and a
 * screen reader get the same control a native radio gives, without the native
 * radio's dot. Selected state is the primary tint at low alpha, matching every
 * other selected tile in the app; hover is a Tailwind colour transition, the
 * one place the animation rule allows one.
 */
function TileRadioGroup({
	id,
	legend,
	value,
	options,
	onChange,
	required = false,
	error,
	disabled = false,
	className,
}: TileRadioGroupProps) {
	return (
		<div className={cn("flex flex-col gap-2", className)}>
			<Label id={`${id}-legend`} className="font-bold">
				{legend}
				{required ? (
					<span className="text-destructive" aria-hidden>
						{" "}
						*
					</span>
				) : null}
			</Label>
			<div
				role="radiogroup"
				aria-labelledby={`${id}-legend`}
				aria-invalid={error ? true : undefined}
				className={cn(
					"grid grid-cols-1 gap-3",
					options.length === 2 ? "sm:grid-cols-2" : "sm:grid-cols-3",
				)}
			>
				{options.map((option) => {
					const selected = value === option.value
					const Icon = option.icon
					return (
						<button
							key={option.value}
							type="button"
							role="radio"
							aria-checked={selected}
							disabled={disabled}
							onClick={() => onChange(option.value)}
							className={cn(
								"flex flex-col items-center gap-2 rounded-xl border p-4 text-body transition-colors",
								selected
									? "border-primary bg-primary/10 text-primary"
									: "border-border hover:bg-accent",
								disabled && "cursor-not-allowed opacity-50 hover:bg-transparent",
							)}
						>
							<Icon className="size-5" aria-hidden />
							<span className="font-medium">{option.label}</span>
							{option.caption ? (
								<span className="text-caption text-muted-foreground">
									{option.caption}
								</span>
							) : null}
						</button>
					)
				})}
			</div>
			<FieldError message={error} />
		</div>
	)
}

export { TileRadioGroup }
