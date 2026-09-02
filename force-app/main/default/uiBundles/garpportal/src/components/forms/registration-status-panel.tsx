import type { LucideIcon } from "lucide-react"
import type { ReactNode } from "react"

import { Card } from "@/components/atoms/card"
import { cn } from "@/lib/utils"

const TONES = {
	muted: "text-muted-foreground",
	/** Closed, pending, not yet open — the system working, not a fault. */
	notice: "text-garp-saffron",
	/** Something actually failed. */
	error: "text-destructive",
	/** A state that is good news — an existing registration. */
	success: "text-success-green",
} as const

type RegistrationStatusPanelProps = {
	icon: LucideIcon
	tone?: keyof typeof TONES
	title: string
	message?: string
	/** Extra facts between the message and the actions — an order number chip. */
	detail?: ReactNode
	/** A way forward, when there is one. */
	action?: ReactNode
	className?: string
}

/**
 * A page-level statement, not an empty-list placeholder — the registration
 * screens that end here (closed, not found, already registered, a dead reg
 * code) ARE the page, so they get the 404 page's treatment: a full-width
 * card on the soft gradient surface, filling the slot the form would have
 * taken. Shared by the event and exam registration panels.
 */
function RegistrationStatusPanel({
	icon: Icon,
	tone = "muted",
	title,
	message,
	detail,
	action,
	className,
}: RegistrationStatusPanelProps) {
	return (
		<Card
			className={cn(
				"min-h-[55vh] items-center justify-center bg-linear-to-br from-surface-gradient-start to-surface-gradient-end px-6 py-16 text-center",
				className,
			)}
		>
			<Icon className={cn("size-12", TONES[tone])} aria-hidden />
			<h2 className="font-heading text-2xl font-semibold tracking-wide text-foreground">
				{title}
			</h2>
			{message ? (
				<p className="max-w-md text-sm leading-relaxed text-muted-foreground">
					{message}
				</p>
			) : null}
			{detail}
			{action ? <div className="mt-2">{action}</div> : null}
		</Card>
	)
}

export { RegistrationStatusPanel }
