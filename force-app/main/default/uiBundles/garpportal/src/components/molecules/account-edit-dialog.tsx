import type { ReactNode } from "react"
import { Pencil } from "lucide-react"

import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
	DialogTrigger,
} from "@/components/atoms/dialog"
import { cn } from "@/lib/utils"

type AccountEditDialogProps = {
	title: string
	description?: string
	/** Form body (scroll + sticky footer live inside the child). */
	children?: ReactNode
	triggerLabel?: string
	/** Controlled open state (optional). */
	open?: boolean
	onOpenChange?: (open: boolean) => void
	/** Wider content for dense forms (Personal Information). */
	contentClassName?: string
}

/**
 * Shell for My Account section edit modals.
 * Fixed height so the dialog does not jump while the form hydrates.
 */
function AccountEditDialog({
	title,
	description,
	children,
	triggerLabel = "Edit",
	open,
	onOpenChange,
	contentClassName,
}: AccountEditDialogProps) {
	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogTrigger asChild>
				<Button
					type="button"
					variant="outline"
					size="sm"
					className="h-8 shrink-0 gap-1.5 border-border bg-background px-2.5 text-foreground shadow-xs hover:bg-accent hover:text-accent-foreground"
				>
					<Pencil className="size-3.5" aria-hidden />
					{triggerLabel}
				</Button>
			</DialogTrigger>
			<DialogContent
				className={cn(
					// Fixed height from open → loaded (no layout jump).
					"flex h-[min(90vh,52rem)] flex-col gap-0 overflow-hidden p-0 sm:max-w-2xl",
					contentClassName,
				)}
			>
				<DialogHeader className="shrink-0 space-y-1.5 border-b border-border px-6 py-4 pr-12 text-left">
					<DialogTitle>{title}</DialogTitle>
					{description ? <DialogDescription>{description}</DialogDescription> : null}
				</DialogHeader>
				<div className="flex min-h-0 flex-1 flex-col">{children}</div>
			</DialogContent>
		</Dialog>
	)
}

export { AccountEditDialog }
