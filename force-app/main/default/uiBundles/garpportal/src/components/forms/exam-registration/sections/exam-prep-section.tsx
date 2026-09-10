import { GraduationCap } from "lucide-react"
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
import { EXAM_PREP_COPY } from "@/config/registration"

type ExamPrepSectionProps = {
	control: Control<ExamFormValues>
	/** The programme's published provider list. The card needs it to exist. */
	providersUrl: string
	/** The programme code the link names, e.g. `FRM`. */
	abbrev: string
	disabled?: boolean
}

/**
 * An OPTIONAL opt-in to GARP passing the candidate's contact details to its
 * third-party exam preparation providers.
 *
 * Optional in the strict sense: no `required` rule, and it must stay that way.
 * Ticking it releases personal data to third parties, so an unticked box is a
 * real and complete answer — gating submit on it would make "no" impossible to
 * say.
 *
 * The caller renders this only for a programme that has a published provider
 * list (`examPrepProvidersUrl` — FRM, SCR and RAI today). Asking someone to
 * consent to a network they cannot look at would be consent in name only.
 */
function ExamPrepSection({
	control,
	providersUrl,
	abbrev,
	disabled,
}: ExamPrepSectionProps) {
	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<GraduationCap className="size-5 text-muted-foreground" aria-hidden />
					{EXAM_PREP_COPY.title}
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-3">
				<div className="flex items-start gap-3">
					<Controller
						control={control}
						name="examPrepProviders"
						render={({ field }) => (
							<Checkbox
								id="examPrepProviders"
								checked={field.value}
								onCheckedChange={(next) => field.onChange(next === true)}
								disabled={disabled}
								className="mt-0.5"
							/>
						)}
					/>
					<Label
						htmlFor="examPrepProviders"
						className="block text-body leading-6 font-normal"
					>
						{EXAM_PREP_COPY.optIn}
					</Label>
				</div>

				{/* Outside the label, so following the link cannot toggle the tick. */}
				<p className="pl-7 text-caption text-muted-foreground">
					{EXAM_PREP_COPY.linkIntro}{" "}
					<a
						href={providersUrl}
						target="_blank"
						rel="noreferrer"
						className="font-semibold text-primary hover:underline"
					>
						{EXAM_PREP_COPY.linkLabel.replace("{abbrev}", abbrev)}
					</a>
					.
				</p>
			</CardContent>
		</Card>
	)
}

export { ExamPrepSection }
