import { useState } from "react"

import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { useEppOptIn } from "@/hooks/use-epp-opt-in"

type EppOptInDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	programType: string
}

/**
 * "Need Help Studying?" — the legacy's EPP opt-in, not a marketing link.
 *
 * A Yes writes through `eppOptIn`; a No just closes, as the legacy does (the
 * question is only stamped as asked when it is answered). On success the copy
 * turns into the thank-you and the offer disappears from the rail once the
 * programme detail refetches.
 */
function EppOptInDialog({
	open,
	onOpenChange,
	programType,
}: EppOptInDialogProps) {
	const mutation = useEppOptIn(programType)
	const [thanked, setThanked] = useState(false)

	const close = (next: boolean) => {
		if (!next) setThanked(false)
		onOpenChange(next)
	}

	const optIn = async () => {
		try {
			await mutation.mutateAsync(true)
			setThanked(true)
		} catch {
			// Toast comes from the shared MutationCache; keep the question up.
		}
	}

	return (
		<Dialog open={open} onOpenChange={close}>
			<DialogContent className="sm:max-w-md">
				<DialogHeader>
					<DialogTitle>Need Help Studying?</DialogTitle>
					<DialogDescription>
						{thanked
							? "Thank you for opting into GARP's network of Exam Prep Providers! Someone will be in contact with you shortly."
							: "Would you like to be contacted by GARP's network of exam prep providers?"}
					</DialogDescription>
				</DialogHeader>
				<DialogFooter className="sm:justify-end">
					{thanked ? (
						<Button type="button" onClick={() => close(false)}>
							Done
						</Button>
					) : (
						<>
							<Button
								type="button"
								variant="outline"
								onClick={() => close(false)}
								disabled={mutation.isPending}
							>
								No
							</Button>
							<Button
								type="button"
								onClick={() => void optIn()}
								disabled={mutation.isPending}
							>
								{mutation.isPending ? "Saving…" : "Yes"}
							</Button>
						</>
					)}
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { EppOptInDialog }
