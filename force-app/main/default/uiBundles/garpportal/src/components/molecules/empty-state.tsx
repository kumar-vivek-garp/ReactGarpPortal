import type { LucideIcon } from "lucide-react"
import type { ReactNode } from "react"

import { cn } from "@/lib/utils"

/**
 * How the glyph is tinted.
 *
 * `muted` is the ordinary empty list — nothing has happened yet, and grey says
 * so. The other two mark a state the visitor may need to act on, so the icon
 * carries the distinction rather than the copy having to shout it.
 */
const TONES = {
	muted: "text-muted-foreground",
	/** Closed, pending, or not yet open — the system working, not a fault. */
	notice: "text-garp-saffron",
	/** Something actually failed. */
	error: "text-destructive",
} as const

export type EmptyStateTone = keyof typeof TONES

type EmptyStateProps = {
	icon: LucideIcon
	tone?: EmptyStateTone
	title: string
	message?: string
	/** A way forward, when there is one. */
	action?: ReactNode
	className?: string
}

/**
 * The block a page shows in place of content it has none of.
 *
 * The same shape the programmes, events, errata, orders and CPD panels each
 * built inline — dashed border, centred glyph, headline, one supporting line.
 * Lifted here so a new use is a call rather than a seventh copy; those five
 * still hold their own copies and are worth migrating when they are next
 * touched.
 */
function EmptyState({
	icon: Icon,
	tone = "muted",
	title,
	message,
	action,
	className,
}: EmptyStateProps) {
	return (
		<div
			className={cn(
				"flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center",
				className,
			)}
		>
			<Icon className={cn("size-10", TONES[tone])} aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</p>
			{message ? (
				<p className="mt-2 max-w-md text-sm text-muted-foreground">{message}</p>
			) : null}
			{action ? <div className="mt-6">{action}</div> : null}
		</div>
	)
}

export { EmptyState }
