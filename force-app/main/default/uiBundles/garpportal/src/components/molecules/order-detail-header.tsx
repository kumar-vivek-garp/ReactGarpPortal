import { Link } from "@tanstack/react-router"
import { ArrowLeft } from "lucide-react"

import { SpringNudge } from "@/components/atoms/spring-nudge"
import { useSpringNudge } from "@/hooks/use-spring-nudge"
import { cn } from "@/lib/utils"

type OrderDetailHeaderProps = {
	title?: string
	className?: string
}

/**
 * Order detail chrome — back to My Account → Order History.
 */
function OrderDetailHeader({ title, className }: OrderDetailHeaderProps) {
	const nudge = useSpringNudge({ direction: "backward" })

	return (
		<header className={cn("shrink-0 space-y-3", className)}>
			<Link
				to="/my-account"
				search={{ tab: "order-history" }}
				className="inline-flex text-lg font-bold text-foreground hover:text-primary"
				{...nudge.bind}
			>
				<SpringNudge
					nudge={nudge}
					icon={<ArrowLeft className="size-6" strokeWidth={2.5} />}
					iconPosition="leading"
					className="gap-3"
				>
					Order History
				</SpringNudge>
			</Link>
			{title ? (
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					{title}
				</h1>
			) : null}
		</header>
	)
}

export { OrderDetailHeader }
