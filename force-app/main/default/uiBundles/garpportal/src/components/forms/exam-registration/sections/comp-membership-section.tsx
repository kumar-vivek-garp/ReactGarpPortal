import { BadgeCheck, RefreshCw } from "lucide-react"
import { Controller, type Control } from "react-hook-form"

import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import type { ExamFormValues } from "@/components/forms/exam-registration/exam-form-values"
import { COMP_MEMBERSHIP_COPY } from "@/config/registration"

type CompMembershipSectionProps = {
	control: Control<ExamFormValues>
	/**
	 * Whether this registration actually includes a free membership. False on
	 * the membership programme itself, where the membership IS the purchase —
	 * the card then carries the renewal offer alone.
	 */
	hasCompMembership: boolean
	/** From `compMembershipTerm` — carries its own trailing "of". */
	term: string
	/** Whether to offer automatic renewal. Card orders with a membership only. */
	showAutoRenew: boolean
	/** The renewal wording. The membership programme passes its own. */
	autoRenewLabel: string
	disabled?: boolean
}

/**
 * The membership that comes with the registration, and the offer to keep it.
 *
 * Auto-renew used to be a bare checkbox stapled to the bottom of the Payment
 * card, on the reasoning that it is a property of paying by card. True, but it
 * meant a year of free membership — the thing the candidate is being given —
 * was never stated anywhere on the form, and the one control that follows from
 * it read as payment small print. The 2027 designs give it a card; this is it.
 *
 * The auto-renew tick keeps its `showAutoRenew` gate exactly as it was: it is
 * still meaningless without a saved card, and someone who already has renewal
 * switched on is not asked again. When that gate is closed the card is pure
 * copy, which is the point — the benefit is worth stating on its own.
 *
 * Callers must not render this when both halves are off; there would be nothing
 * inside it.
 */
function CompMembershipSection({
	control,
	hasCompMembership,
	term,
	showAutoRenew,
	autoRenewLabel,
	disabled,
}: CompMembershipSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					{hasCompMembership ? (
						<BadgeCheck className="size-5 text-muted-foreground" aria-hidden />
					) : (
						<RefreshCw className="size-5 text-muted-foreground" aria-hidden />
					)}
					{hasCompMembership
						? COMP_MEMBERSHIP_COPY.title
						: COMP_MEMBERSHIP_COPY.renewalOnlyTitle}
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				{hasCompMembership ? (
					<p className="text-body leading-6 text-muted-foreground">
						{COMP_MEMBERSHIP_COPY.body.replace("{term}", term)}
					</p>
				) : null}

				{showAutoRenew ? (
					/*
					 * Inset and tinted so the one thing on this card that is a DECISION
					 * is visibly separate from the copy explaining the gift. Without
					 * that separation the tick reads as a confirmation of the benefit
					 * rather than an opt-in to being charged next year.
					 */
					<div className="flex flex-col gap-3 rounded-xl bg-muted p-4">
						{/* Only a heading when there is body copy above to distinguish it
						    from — otherwise it repeats the card title verbatim. */}
						{hasCompMembership ? (
							<p className="text-body font-bold">
								{COMP_MEMBERSHIP_COPY.autoRenewTitle}{" "}
								<span className="font-normal text-muted-foreground">
									{COMP_MEMBERSHIP_COPY.optional}
								</span>
							</p>
						) : null}
						<div className="flex items-start gap-3">
							<Controller
								control={control}
								name="autoRenew"
								render={({ field }) => (
									<Checkbox
										id="autoRenew"
										checked={field.value}
										onCheckedChange={(next) => field.onChange(next === true)}
										disabled={disabled}
										className="mt-0.5"
									/>
								)}
							/>
							<Label
								htmlFor="autoRenew"
								className="block text-body leading-6 font-normal"
							>
								{autoRenewLabel}
							</Label>
						</div>
					</div>
				) : null}
			</CardContent>
		</Card>
	)
}

export { CompMembershipSection }
