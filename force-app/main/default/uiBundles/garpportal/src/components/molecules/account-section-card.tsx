import type { ReactNode } from "react"

import {
	Card,
	CardAction,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { cn } from "@/lib/utils"

type AccountSectionCardProps = {
	title: string
	subtitle?: string
	children: ReactNode
	/** Extreme-right control in the title row (e.g. Edit). */
	action?: ReactNode
	className?: string
}

function AccountSectionCard({
	title,
	subtitle,
	children,
	action,
	className,
}: AccountSectionCardProps) {
	return (
		<Card className={cn("h-full gap-4 bg-muted/40 py-5 shadow-none", className)}>
			{/*
			 * Title / description / action must be direct CardHeader children so the
			 * shadcn grid places Edit in column 2 (not beside the subtitle).
			 */}
			<CardHeader className="gap-1.5">
				<CardTitle className="min-w-0 font-heading text-lg tracking-wide">
					{title}
				</CardTitle>
				{subtitle ? <CardDescription>{subtitle}</CardDescription> : null}
				{action ? <CardAction>{action}</CardAction> : null}
			</CardHeader>
			<CardContent className="flex flex-1 flex-col gap-2.5">{children}</CardContent>
		</Card>
	)
}

export { AccountSectionCard }
