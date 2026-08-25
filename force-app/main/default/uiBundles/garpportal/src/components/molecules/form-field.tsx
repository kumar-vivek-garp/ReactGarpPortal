import type { ReactNode } from "react"

import { Label } from "@/components/atoms/label"
import { cn } from "@/lib/utils"

/** The inline error under a control. Renders nothing when there is no error. */
function FieldError({
	message,
	className,
}: {
	message?: string
	className?: string
}) {
	if (!message) return null
	return (
		<p className={cn("text-caption text-destructive", className)} role="alert">
			{message}
		</p>
	)
}

type FormFieldProps = {
	/** Must match the control's `id` so the label actually targets it. */
	id: string
	label: ReactNode
	/** Draws the asterisk. A prop, not an assumption — see below. */
	required?: boolean
	error?: string
	hint?: string
	children: ReactNode
	className?: string
}

/**
 * One labelled control: label, control, optional hint, inline error.
 *
 * `required` is a prop rather than always-on because forms here mix mandatory
 * and optional fields, and some are mandatory only in context. A permanent
 * asterisk would tell someone a field is compulsory when it is not.
 *
 * A hint is suppressed while an error shows: two lines of small print under
 * one input, one of them stale advice, reads worse than the error alone.
 */
function FormField({
	id,
	label,
	required = false,
	error,
	hint,
	children,
	className,
}: FormFieldProps) {
	return (
		<div className={cn("flex flex-col gap-2", className)}>
			<Label htmlFor={id} className="font-bold">
				{label}
				{required ? (
					<span className="text-destructive" aria-hidden>
						{" "}
						*
					</span>
				) : null}
			</Label>
			{children}
			{hint && !error ? (
				<p className="text-caption text-muted-foreground">{hint}</p>
			) : null}
			<FieldError message={error} />
		</div>
	)
}

export { FieldError, FormField }
