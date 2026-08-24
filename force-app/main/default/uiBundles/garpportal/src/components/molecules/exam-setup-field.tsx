import type { ReactNode } from "react"

import { Label } from "@/components/atoms/label"
import { cn } from "@/lib/utils"

type ExamSetupFieldProps = {
	id: string
	label: string
	/** Draws the asterisk and marks the control for assistive tech. */
	required?: boolean
	error?: string
	hint?: string
	children: ReactNode
	className?: string
}

/**
 * One labelled control on the exam-setup page.
 *
 * Unlike the field helper inside `osta-id-form`, `required` is a prop rather
 * than assumed: the ID step's fields are only mandatory when Apex says
 * `isIDRequired`, and the whole China block is conditional on `isOSTA`. A
 * permanent asterisk would tell most members a field is compulsory when it is
 * not.
 */
function ExamSetupField({
	id,
	label,
	required = false,
	error,
	hint,
	children,
	className,
}: ExamSetupFieldProps) {
	return (
		<div className={cn("space-y-1.5", className)}>
			<Label htmlFor={id} className="text-sm">
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
				<p className="text-xs text-muted-foreground">{hint}</p>
			) : null}
			{error ? (
				<p className="text-xs text-destructive" role="alert">
					{error}
				</p>
			) : null}
		</div>
	)
}

export { ExamSetupField }
