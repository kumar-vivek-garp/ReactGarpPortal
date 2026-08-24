import { Bell } from "lucide-react"

import type { ProgramExamNotification } from "@/api/notifications"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from "@/components/atoms/dialog"
import { formatLongDate } from "@/lib/account-format"

type DashboardNotificationsDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	notifications: ProgramExamNotification[]
}

/**
 * Every exam notice, in full.
 *
 * The card previews the first two and truncates them; this is where the rest
 * live. "New" is the legacy's word, not a read state — there is no read model
 * anywhere in the payload, so nothing here is marked seen.
 */
function DashboardNotificationsDialog({
	open,
	onOpenChange,
	notifications,
}: DashboardNotificationsDialogProps) {
	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className="flex max-h-[min(85vh,40rem)] flex-col gap-0 overflow-hidden p-0 sm:max-w-lg">
				<DialogHeader className="shrink-0 space-y-1.5 border-b border-border px-6 py-4 pr-12 text-left">
					<DialogTitle className="flex items-center gap-2">
						<Bell className="size-4" aria-hidden />
						Notifications
					</DialogTitle>
					<DialogDescription>
						Exam notices for your programs.
					</DialogDescription>
				</DialogHeader>

				<div className="min-h-0 flex-1 overflow-y-auto px-6 py-4">
					{notifications.length === 0 ? (
						<p className="text-sm text-muted-foreground">
							You have no notifications right now.
						</p>
					) : (
						<ul className="divide-y divide-border/80">
							{notifications.map((notice, index) => (
								<li
									key={`${notice.notificationTitle ?? "notice"}-${index}`}
									className="space-y-1 py-3 first:pt-0 last:pb-0"
								>
									<p className="font-heading text-base leading-snug tracking-wide text-foreground">
										{notice.notificationTitle ?? "Notification"}
									</p>
									{notice.notificationDate ? (
										<p className="text-xs text-muted-foreground">
											{formatLongDate(notice.notificationDate.slice(0, 10))}
										</p>
									) : null}
									{notice.notificationDetails ? (
										<p className="text-sm text-muted-foreground">
											{notice.notificationDetails}
										</p>
									) : null}
								</li>
							))}
						</ul>
					)}
				</div>
			</DialogContent>
		</Dialog>
	)
}

export { DashboardNotificationsDialog }
