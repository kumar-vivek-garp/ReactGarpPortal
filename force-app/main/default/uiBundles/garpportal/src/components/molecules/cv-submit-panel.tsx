import { CheckCircle2, Send, TriangleAlert } from "lucide-react"

import type { CvProgramType, CvView } from "@/api/work-experience"
import { Button } from "@/components/atoms/button"
import { useSubmitCv } from "@/hooks/use-cv"
import {
	cvProgress,
	cvSubmitBlocker,
	cvViewState,
	formatAddressLine,
	formatMonths,
} from "@/lib/work-experience-presentation"

type CvSubmitPanelProps = {
	view: CvView
	programType: CvProgramType
}

/**
 * The last step: what is about to be sent, and the button that sends it.
 *
 * Submit is gated on `cvSubmitBlocker`, whose address half has no server-side
 * equivalent — `cvSubmit` never looks at the address. The reason is always
 * shown rather than the button merely being dead, which is the legacy's
 * failure mode on this screen: it submitted regardless of
 * `isValidExperienceSubmission` and offered no explanation either way.
 */
function CvSubmitPanel({ view, programType }: CvSubmitPanelProps) {
	const mutation = useSubmitCv(programType)
	const state = cvViewState(view)
	const progress = cvProgress(view)
	const blocker = cvSubmitBlocker(view)

	if (state === "submitted" || state === "closed") {
		return (
			<div className="flex items-start gap-3 rounded-lg border border-border bg-muted/20 px-4 py-3">
				<CheckCircle2
					className="mt-0.5 size-5 shrink-0 text-success-green"
					aria-hidden
				/>
				<div className="space-y-1">
					<p className="text-sm font-semibold text-foreground">
						{state === "submitted"
							? "Sent to GARP for review"
							: "Your work experience has been approved"}
					</p>
					<p className="text-sm text-muted-foreground">
						{view.submissionMessage?.trim() ||
							(state === "submitted"
								? "We'll be in touch if we need anything else. Your entries are read-only while it is under review."
								: "Nothing further is needed.")}
					</p>
				</div>
			</div>
		)
	}

	return (
		<div className="space-y-4">
			<dl className="grid gap-x-6 gap-y-2 text-sm sm:grid-cols-[10rem_1fr]">
				<dt className="text-muted-foreground">Experience</dt>
				<dd className="text-foreground">
					{view.workExperiences.length}{" "}
					{view.workExperiences.length === 1 ? "role" : "roles"} ·{" "}
					{formatMonths(progress.logged)}
				</dd>
				<dt className="text-muted-foreground">Certificate posted to</dt>
				<dd className="text-foreground">
					{formatAddressLine(view.address) ?? "Not provided yet"}
				</dd>
			</dl>

			{blocker ? (
				<p className="flex items-start gap-2 text-sm text-garp-saffron">
					<TriangleAlert className="mt-0.5 size-4 shrink-0" aria-hidden />
					{blocker}
				</p>
			) : (
				<p className="text-sm text-muted-foreground">
					Once sent, your entries become read-only while GARP reviews them.
				</p>
			)}

			<Button
				type="button"
				disabled={Boolean(blocker) || mutation.isPending}
				onClick={() => void mutation.mutateAsync().catch(() => undefined)}
			>
				<Send className="size-4" aria-hidden />
				{mutation.isPending ? "Sending…" : "Submit for review"}
			</Button>
		</div>
	)
}

export { CvSubmitPanel }
