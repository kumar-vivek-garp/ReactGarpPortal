import { useId, useState } from "react"

import { Button } from "@/components/atoms/button"
import { Checkbox } from "@/components/atoms/checkbox"
import {
	Dialog,
	DialogContent,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { Label } from "@/components/atoms/label"
import { useAttestCpdCycle } from "@/hooks/use-save-cpd-claim"

/** Verbatim from the legacy dialog. */
const ATTESTATION_COPY =
	"By clicking this box, I attest that all I have submitted to be accurate and true to the best of my knowledge."
const CODE_OF_CONDUCT_COPY =
	"By clicking this box, I indicate that I have read, and agree to continue to abide by GARP's Code of Conduct and fully understand GARP's Privacy Notice."

type AttestationBodyProps = {
	attestationId: string | null
	creditsRequired: number | null
	onClose: () => void
	onAttested: () => void
}

/**
 * Mounted only while the dialog is open, so the ticks reset by unmounting
 * rather than by an effect that writes state on every close.
 */
function AttestationBody({
	attestationId,
	creditsRequired,
	onClose,
	onAttested,
}: AttestationBodyProps) {
	const id = useId()
	const mutation = useAttestCpdCycle()
	const [attested, setAttested] = useState(false)
	const [codeOfConduct, setCodeOfConduct] = useState(false)

	const canSubmit =
		attested && codeOfConduct && Boolean(attestationId) && !mutation.isPending

	const submit = async () => {
		if (!attestationId) return
		try {
			await mutation.mutateAsync(attestationId)
			onAttested()
		} catch {
			// Toast comes from the shared MutationCache; keep the dialog open.
		}
	}

	return (
		<>
			<DialogHeader>
				<DialogTitle>
					{creditsRequired == null
						? "Confirm your CPD credits."
						: `You have completed your required ${creditsRequired} credits.`}
				</DialogTitle>
			</DialogHeader>

			<div className="space-y-4 py-2">
				<div className="flex items-start gap-3">
					<Checkbox
						id={`${id}-attestation`}
						checked={attested}
						onCheckedChange={(next) => setAttested(next === true)}
						className="mt-0.5"
					/>
					{/* Label wraps the copy so the text is clickable — the legacy's
					    sibling span was not. */}
					<Label
						htmlFor={`${id}-attestation`}
						className="text-sm leading-snug font-normal"
					>
						{ATTESTATION_COPY}
					</Label>
				</div>

				<div className="flex items-start gap-3">
					<Checkbox
						id={`${id}-code-of-conduct`}
						checked={codeOfConduct}
						onCheckedChange={(next) => setCodeOfConduct(next === true)}
						className="mt-0.5"
					/>
					<Label
						htmlFor={`${id}-code-of-conduct`}
						className="text-sm leading-snug font-normal"
					>
						{CODE_OF_CONDUCT_COPY}
					</Label>
				</div>
			</div>

			<DialogFooter className="sm:justify-end">
				<Button
					type="button"
					variant="outline"
					onClick={onClose}
					disabled={mutation.isPending}
				>
					Cancel
				</Button>
				<Button type="button" onClick={() => void submit()} disabled={!canSubmit}>
					{mutation.isPending ? "Submitting…" : "Submit"}
				</Button>
			</DialogFooter>
		</>
	)
}

type CpdAttestationDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	attestationId: string | null
	/** Credits the cycle required, for the heading. */
	creditsRequired: number | null
	/** Runs after a successful attestation — opens the certificate. */
	onAttested: () => void
}

/**
 * Attest the cycle before a certificate can be downloaded.
 *
 * Both boxes must be ticked, matching the legacy's `requiredTrue` validators.
 * The write happens here rather than in the caller so a failure keeps the
 * dialog open with its toast, instead of silently opening nothing.
 */
function CpdAttestationDialog({
	open,
	onOpenChange,
	attestationId,
	creditsRequired,
	onAttested,
}: CpdAttestationDialogProps) {
	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="sm:max-w-lg">
				{open ? (
					<AttestationBody
						attestationId={attestationId}
						creditsRequired={creditsRequired}
						onClose={() => onOpenChange(false)}
						onAttested={() => {
							onOpenChange(false)
							onAttested()
						}}
					/>
				) : null}
			</DialogContent>
		</Dialog>
	)
}

export { CpdAttestationDialog }
