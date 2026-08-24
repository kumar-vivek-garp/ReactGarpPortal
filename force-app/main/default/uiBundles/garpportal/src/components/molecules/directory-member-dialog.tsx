import { useState } from "react"
import { Send, UserPlus } from "lucide-react"

import type { DirectoryMember, DirectoryMessageType } from "@/api/directory"
import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { Label } from "@/components/atoms/label"
import { Textarea } from "@/components/atoms/textarea"
import { useSendDirectoryMessage } from "@/hooks/use-directory"
import {
	directoryCredentials,
	directoryMemberSubtitle,
} from "@/lib/directory-presentation"

type DirectoryMemberDialogProps = {
	member: DirectoryMember | null
	onOpenChange: (open: boolean) => void
}

function DetailRow({ label, value }: { label: string; value: string | null }) {
	if (!value?.trim()) return null
	return (
		<>
			<dt className="text-muted-foreground">{label}</dt>
			<dd className="text-foreground">{value}</dd>
		</>
	)
}

/**
 * One member's directory entry, and the two ways to reach them.
 *
 * Send Message and Invite to Connect are gated per row on `canSendMessage` /
 * `canInvite`, which Apex decides from the subject's own privacy switches and
 * the viewer's standing — never from the viewer's entitlement alone.
 *
 * The composed text is actually sent. The legacy passed the wrong message type
 * for Send Message and dropped whatever the member had typed, so a message
 * appeared to send and arrived empty.
 */
function DirectoryMemberDialog({
	member,
	onOpenChange,
}: DirectoryMemberDialogProps) {
	const [message, setMessage] = useState("")
	const [mode, setMode] = useState<DirectoryMessageType | null>(null)
	const mutation = useSendDirectoryMessage()

	const credentials = member ? directoryCredentials(member) : []
	const subtitle = member ? directoryMemberSubtitle(member) : ""

	const close = (open: boolean) => {
		if (!open) {
			setMessage("")
			setMode(null)
		}
		onOpenChange(open)
	}

	const send = async () => {
		if (!member?.id || !mode) return
		try {
			await mutation.mutateAsync({
				recipientContactId: member.id,
				messageType: mode,
				message,
			})
			close(false)
		} catch {
			// Toast comes from the shared MutationCache; keep the dialog open.
		}
	}

	return (
		<Dialog open={member !== null} onOpenChange={close}>
			<DialogContent className="sm:max-w-lg">
				<DialogHeader>
					<DialogTitle>{member?.name ?? "Member"}</DialogTitle>
					{subtitle ? (
						<DialogDescription>{subtitle}</DialogDescription>
					) : null}
				</DialogHeader>

				{credentials.length > 0 ? (
					<p className="text-sm text-foreground">{credentials.join(" · ")}</p>
				) : null}

				<dl className="grid grid-cols-[9rem_1fr] gap-x-4 gap-y-1.5 text-sm">
					<DetailRow label="Location" value={member?.mailingCity ?? null} />
					<DetailRow label="Country" value={member?.mailingCountry ?? null} />
					<DetailRow label="Job function" value={member?.jobFunction ?? null} />
					<DetailRow
						label="Risk specialty"
						value={member?.riskSpecialty ?? null}
					/>
					<DetailRow
						label="Industry"
						value={member?.areaOfConcentration ?? null}
					/>
					<DetailRow
						label="CPD cycle"
						value={member?.cpeCurrentCycle ?? null}
					/>
					<DetailRow
						label="Last completed"
						value={member?.cpeLastCompletedCycle ?? null}
					/>
					<DetailRow
						label="Other qualifications"
						value={member?.otherQualifications ?? null}
					/>
				</dl>

				{mode ? (
					<div className="space-y-1.5">
						<Label htmlFor="directory-message" className="text-sm">
							{mode === "Directory_Connect_Invite"
								? "Add a note to your invitation"
								: "Your message"}
						</Label>
						<Textarea
							id="directory-message"
							rows={4}
							value={message}
							onChange={(event) => setMessage(event.target.value)}
							placeholder="GARP passes this on — your email address is not shared."
						/>
					</div>
				) : null}

				<DialogFooter className="sm:justify-end">
					{mode ? (
						<>
							<Button
								type="button"
								variant="outline"
								onClick={() => setMode(null)}
								disabled={mutation.isPending}
							>
								Back
							</Button>
							<Button
								type="button"
								onClick={() => void send()}
								disabled={mutation.isPending || !message.trim()}
							>
								{mutation.isPending ? "Sending…" : "Send"}
							</Button>
						</>
					) : (
						<>
							{member?.canSendMessage ? (
								<Button
									type="button"
									variant="outline"
									onClick={() => setMode("Directory_Connect")}
								>
									<Send className="size-4" aria-hidden />
									Send Message
								</Button>
							) : null}
							{member?.canInvite ? (
								<Button
									type="button"
									onClick={() => setMode("Directory_Connect_Invite")}
								>
									<UserPlus className="size-4" aria-hidden />
									Invite to Connect
								</Button>
							) : null}
							{!member?.canSendMessage && !member?.canInvite ? (
								<p className="text-sm text-muted-foreground">
									This member has not enabled messaging.
								</p>
							) : null}
						</>
					)}
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}

export { DirectoryMemberDialog }
