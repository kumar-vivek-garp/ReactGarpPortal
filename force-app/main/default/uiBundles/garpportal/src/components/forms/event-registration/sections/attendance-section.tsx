import { MonitorSmartphone } from "lucide-react"
import { Controller, type Control, type FieldErrors } from "react-hook-form"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { FormField } from "@/components/molecules/form-field"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import { EVENT_ATTENDANCE_OPTIONS } from "@/config/event-registration"

type AttendanceSectionProps = {
	control: Control<EventFormValues>
	errors: FieldErrors<EventFormValues>
}

/** Hybrid events only: how the person will attend. Required while rendered. */
function AttendanceSection({ control, errors }: AttendanceSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<MonitorSmartphone
						className="size-5 text-muted-foreground"
						aria-hidden
					/>
					How will you attend?
				</CardTitle>
			</CardHeader>
			<CardContent>
				<FormField
					id="event-reg-attendance"
					label="Attendance"
					required
					error={errors.attendanceMethod?.message}
				>
					<Controller
						control={control}
						name="attendanceMethod"
						rules={{ required: "Please choose how you will attend." }}
						render={({ field }) => (
							/* `?? ""` — an undefined value latches Radix into
							   uncontrolled mode and shows the placeholder for ever. */
							<Select value={field.value ?? ""} onValueChange={field.onChange}>
								<SelectTrigger
									id="event-reg-attendance"
									aria-invalid={Boolean(errors.attendanceMethod)}
									className="w-full sm:w-72"
								>
									<SelectValue placeholder="Select…" />
								</SelectTrigger>
								<SelectContent>
									{EVENT_ATTENDANCE_OPTIONS.map((option) => (
										<SelectItem key={option.value} value={option.value}>
											{option.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						)}
					/>
				</FormField>
			</CardContent>
		</Card>
	)
}

export { AttendanceSection }
