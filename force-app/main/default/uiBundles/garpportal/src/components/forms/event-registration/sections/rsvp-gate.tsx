import { MailQuestionMark } from "lucide-react"

import type { EventView } from "@/api/registration/event-types"
import { Button } from "@/components/atoms/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import {
	rsvpAcceptLabel,
	rsvpGateCopy,
} from "@/lib/event-registration-presentation"

type RsvpGateProps = {
	event: EventView
	onAccept: () => void
	onDecline: () => void
	declining: boolean
	declineError: string | null
}

/**
 * The invite-only gate. Accept is client-side only — it reveals the form;
 * nothing is written until that form submits. Decline records the reply
 * server-side and leads to its own declined screen (the deployed GarpAppv1
 * shows "You're registered" for a decline — a bug this port does not carry).
 */
function RsvpGate({
	event,
	onAccept,
	onDecline,
	declining,
	declineError,
}: RsvpGateProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<MailQuestionMark
						className="size-5 text-muted-foreground"
						aria-hidden
					/>
					You're invited
				</CardTitle>
				<p className="text-body text-muted-foreground">{rsvpGateCopy(event)}</p>
			</CardHeader>
			<CardContent className="flex flex-col gap-3">
				<div className="flex flex-wrap items-center gap-3">
					<Button onClick={onAccept} disabled={declining}>
						{rsvpAcceptLabel(event.maxCapacityMet)}
					</Button>
					<Button variant="outline" onClick={onDecline} disabled={declining}>
						{declining ? "Sending…" : "Decline"}
					</Button>
				</div>
				{declineError ? (
					<p className="text-caption text-destructive" role="alert">
						{declineError}
					</p>
				) : null}
			</CardContent>
		</Card>
	)
}

export { RsvpGate }
