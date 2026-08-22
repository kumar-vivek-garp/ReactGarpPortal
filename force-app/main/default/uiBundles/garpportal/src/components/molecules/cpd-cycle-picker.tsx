import { useId } from "react"

import { Label } from "@/components/atoms/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { cn } from "@/lib/utils"

type CpdCyclePickerProps = {
	cycles: string[]
	value: string | null
	onChange: (cycleName: string) => void
	className?: string
}

/**
 * Cycle switcher. Every cycle arrives in one `cpdProgram` payload, so changing
 * the selection is local state only — it must not refetch.
 */
function CpdCyclePicker({
	cycles,
	value,
	onChange,
	className,
}: CpdCyclePickerProps) {
	const id = useId()

	return (
		<div className={cn("flex items-center gap-2", className)}>
			<Label htmlFor={id} className="text-sm text-muted-foreground">
				Cycle:
			</Label>
			<Select value={value ?? undefined} onValueChange={onChange}>
				<SelectTrigger id={id} size="sm" className="w-[10.5rem]">
					<SelectValue placeholder="Select a cycle" />
				</SelectTrigger>
				<SelectContent>
					{cycles.map((cycle) => (
						<SelectItem key={cycle} value={cycle}>
							{cycle}
						</SelectItem>
					))}
				</SelectContent>
			</Select>
		</div>
	)
}

export { CpdCyclePicker }
