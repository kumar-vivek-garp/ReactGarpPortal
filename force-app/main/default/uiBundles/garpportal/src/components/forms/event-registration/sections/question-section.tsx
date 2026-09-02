import { MessageCircleQuestionMark } from "lucide-react"
import type { UseFormRegister } from "react-hook-form"

import type { EventView } from "@/api/registration/event-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Textarea } from "@/components/atoms/textarea"
import { FormField } from "@/components/molecules/form-field"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"

type QuestionSectionProps = {
	register: UseFormRegister<EventFormValues>
	event: EventView
}

/** The event's own free-text question, when the organiser configured one. */
function QuestionSection({ register, event }: QuestionSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<MessageCircleQuestionMark
						className="size-5 text-muted-foreground"
						aria-hidden
					/>
					{event.eventQuestionTitle}
				</CardTitle>
				{event.eventQuestionDetail ? (
					<p className="text-body text-muted-foreground">
						{event.eventQuestionDetail}
					</p>
				) : null}
			</CardHeader>
			<CardContent>
				<FormField id="event-reg-question" label="Your response">
					<Textarea
						id="event-reg-question"
						rows={3}
						{...register("eventQuestionResponse")}
					/>
				</FormField>
			</CardContent>
		</Card>
	)
}

export { QuestionSection }
