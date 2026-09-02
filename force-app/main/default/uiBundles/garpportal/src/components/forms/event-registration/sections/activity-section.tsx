import { PartyPopper } from "lucide-react"
import {
	Controller,
	useWatch,
	type Control,
	type UseFormRegister,
} from "react-hook-form"

import type { EventView } from "@/api/registration/event-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { Textarea } from "@/components/atoms/textarea"
import { FormField } from "@/components/molecules/form-field"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import {
	showActivityQuestion,
	showDietary,
} from "@/lib/event-registration-presentation"

type ActivitySectionProps = {
	register: UseFormRegister<EventFormValues>
	control: Control<EventFormValues>
	event: EventView
}

/**
 * The event's side activity (a dinner, a reception). Dietary and the
 * activity's own question only appear once the person says they are coming —
 * unmounted fields stop counting toward validity, which is the behaviour we
 * want here.
 */
function ActivitySection({ register, control, event }: ActivitySectionProps) {
	const attending = useWatch({ control, name: "attendingActivity" })
	const dietary = useWatch({ control, name: "dietaryRestriction" })

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<PartyPopper className="size-5 text-muted-foreground" aria-hidden />
					{event.rsvpActivityName}
				</CardTitle>
				{event.rsvpActivityDetails ? (
					<p className="text-body text-muted-foreground">
						{event.rsvpActivityDetails}
					</p>
				) : null}
				{event.rsvpActivityLocation ? (
					<p className="text-caption text-muted-foreground">
						{event.rsvpActivityLocation}
					</p>
				) : null}
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				<div className="flex items-center gap-3">
					<Controller
						control={control}
						name="attendingActivity"
						render={({ field }) => (
							<Checkbox
								id="event-reg-activity"
								checked={field.value}
								onCheckedChange={field.onChange}
							/>
						)}
					/>
					<Label htmlFor="event-reg-activity" className="font-normal">
						Yes, I will attend {event.rsvpActivityName}.
					</Label>
				</div>

				{attending && showDietary(event) ? (
					<div className="flex flex-col gap-3 border-l-2 border-border pl-4">
						<div className="flex items-center gap-3">
							<Controller
								control={control}
								name="dietaryRestriction"
								render={({ field }) => (
									<Checkbox
										id="event-reg-dietary"
										checked={field.value}
										onCheckedChange={field.onChange}
									/>
								)}
							/>
							<Label htmlFor="event-reg-dietary" className="font-normal">
								I have dietary restrictions.
							</Label>
						</div>
						{dietary ? (
							<FormField id="event-reg-dietary-details" label="Tell us more">
								<Textarea
									id="event-reg-dietary-details"
									rows={2}
									{...register("dietaryRestrictionDetails")}
								/>
							</FormField>
						) : null}
					</div>
				) : null}

				{attending && showActivityQuestion(event) ? (
					<FormField
						id="event-reg-activity-question"
						label={event.rsvpActivityQuestion ?? ""}
					>
						<Textarea
							id="event-reg-activity-question"
							rows={2}
							{...register("activityQuestionResponse")}
						/>
					</FormField>
				) : null}
			</CardContent>
		</Card>
	)
}

export { ActivitySection }
