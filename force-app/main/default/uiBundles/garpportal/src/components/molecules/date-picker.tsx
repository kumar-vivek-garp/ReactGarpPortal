import { useState } from "react"
import { format, isValid, parseISO } from "date-fns"
import { CalendarIcon } from "lucide-react"
import type { DayPickerProps } from "react-day-picker"

import { Button } from "@/components/atoms/button"
import { Calendar } from "@/components/atoms/calendar"
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from "@/components/atoms/popover"
import { cn } from "@/lib/utils"

type DatePickerProps = {
	id: string
	/** ISO `yyyy-MM-dd`, or `""` for nothing chosen. */
	value: string
	onChange: (iso: string) => void
	placeholder?: string
	/** Bounds the month/year dropdowns; defaults to react-day-picker's own. */
	startMonth?: Date
	endMonth?: Date
	captionLayout?: DayPickerProps["captionLayout"]
	disabled?: boolean
	"aria-invalid"?: boolean
	className?: string
}

/** Local-time parse, so `2030-01-01` is the first, not the last day of 2029 in the Americas. */
function parseIso(value: string): Date | undefined {
	if (!value) return undefined
	const date = parseISO(value)
	return isValid(date) ? date : undefined
}

/**
 * A calendar behind a button — shadcn's date-picker recipe (Popover + Calendar)
 * as one control, because the registry ships no DatePicker root.
 *
 * Speaks ISO strings on both sides. The forms that use it already hold dates as
 * `yyyy-MM-dd` (it is what the API returns and what `toUsDateString` converts
 * from), so keeping the wire shape here means nothing upstream changes when a
 * native date input becomes this. `parseISO` / `format` are both local-time,
 * which is the point — `new Date("2030-01-01")` is UTC midnight and lands a day
 * early west of Greenwich.
 */
function DatePicker({
	id,
	value,
	onChange,
	placeholder = "Select a date",
	startMonth,
	endMonth,
	captionLayout = "dropdown",
	disabled,
	className,
	...aria
}: DatePickerProps) {
	const [open, setOpen] = useState(false)
	const date = parseIso(value)

	return (
		<Popover open={open} onOpenChange={setOpen}>
			<PopoverTrigger asChild>
				<Button
					id={id}
					type="button"
					variant="outline"
					disabled={disabled}
					aria-invalid={aria["aria-invalid"] ? true : undefined}
					data-empty={!date}
					className={cn(
						"w-full justify-start font-normal data-[empty=true]:text-muted-foreground",
						className,
					)}
				>
					<CalendarIcon className="text-muted-foreground" aria-hidden />
					{date ? format(date, "PPP") : placeholder}
				</Button>
			</PopoverTrigger>
			<PopoverContent className="w-auto overflow-hidden p-0" align="start">
				<Calendar
					mode="single"
					selected={date}
					defaultMonth={date}
					captionLayout={captionLayout}
					startMonth={startMonth}
					endMonth={endMonth}
					onSelect={(next) => {
						onChange(next ? format(next, "yyyy-MM-dd") : "")
						setOpen(false)
					}}
				/>
			</PopoverContent>
		</Popover>
	)
}

export { DatePicker }
