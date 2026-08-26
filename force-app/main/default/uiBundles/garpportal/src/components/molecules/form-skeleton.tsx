import type { ReactNode } from "react"

import { Card, CardContent, CardHeader } from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

/**
 * A labelled control, greyed out.
 *
 * `h-4` label over an `h-9` input, which is the height of the `Input` atom —
 * so the field does not resize when the real one replaces it.
 */
function SkeletonField({ className }: { className?: string }) {
	return (
		<div className={cn("flex flex-col gap-2", className)}>
			<Skeleton className="h-4 w-24" />
			<Skeleton className="h-9 w-full rounded-xl" />
		</div>
	)
}

/**
 * A titled card, greyed out — the same `Card` the real section uses, so its
 * padding, radius and border are not approximated.
 */
function SkeletonCard({
	rows,
	className,
}: {
	rows: ReactNode
	className?: string
}) {
	return (
		<Card className={className}>
			<CardHeader>
				<Skeleton className="h-5 w-40" />
			</CardHeader>
			<CardContent>{rows}</CardContent>
		</Card>
	)
}

/** A stack of plain rows — a summary, a consent list, a set of line items. */
function SkeletonRows({ count, className }: { count: number; className?: string }) {
	return (
		<div className={cn("flex flex-col gap-3", className)}>
			{Array.from({ length: count }).map((_, index) => (
				<Skeleton key={index} className="h-5 w-full rounded-lg" />
			))}
		</div>
	)
}

export { SkeletonCard, SkeletonField, SkeletonRows }
