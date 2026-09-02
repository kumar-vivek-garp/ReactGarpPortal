import { Megaphone } from "lucide-react"
import { Controller, type Control } from "react-hook-form"

import type { EventView } from "@/api/registration/event-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import { consentKind } from "@/lib/event-registration-presentation"

type ConsentSectionProps = {
	control: Control<EventFormValues>
	event: EventView
}

/**
 * Marketing consent — GARP content OR the sponsor's, never both (the ported
 * rule). Optional, and always starting unticked.
 */
function ConsentSection({ control, event }: ConsentSectionProps) {
	const sponsor = consentKind(event) === "sponsor"
	const sponsorName = event.sponsorName?.trim() || "the sponsor(s) of this event"

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<Megaphone className="size-5 text-muted-foreground" aria-hidden />
					{sponsor ? "Sponsor communications" : "Valuable content"}
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-3">
				<div className="flex items-start gap-3">
					<Controller
						control={control}
						name={sponsor ? "agreeToSponsorContact" : "agreeToGarpContent"}
						render={({ field }) => (
							<Checkbox
								id="event-reg-consent"
								className="mt-0.5"
								checked={field.value}
								onCheckedChange={field.onChange}
							/>
						)}
					/>
					<Label htmlFor="event-reg-consent" className="font-normal leading-snug">
						{sponsor
							? `I agree to receive communications from ${sponsorName} about their products and services.`
							: "I would like to receive GARP risk insights, event invitations, and other valuable content."}
					</Label>
				</div>
				{sponsor && event.sponsorPolicyUrl ? (
					<a
						href={event.sponsorPolicyUrl}
						target="_blank"
						rel="noreferrer noopener"
						className="text-sm font-semibold text-primary hover:underline"
					>
						Sponsor Privacy Statement
					</a>
				) : null}
			</CardContent>
		</Card>
	)
}

export { ConsentSection }
