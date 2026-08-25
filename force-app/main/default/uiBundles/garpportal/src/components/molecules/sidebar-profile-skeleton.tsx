import { animated } from "@react-spring/web"

import { Skeleton } from "@/components/atoms/skeleton"
import type { SidebarLabelStyle } from "@/hooks/use-sidebar-collapse"
import { cn } from "@/lib/utils"

type SidebarProfileSkeletonProps = {
	className?: string
	/** Must match the `inset` of the SidebarProfileLink it stands in for. */
	inset?: boolean
	/** Desktop rail only: animated label styles from `useSidebarCollapse`. */
	labelStyle?: SidebarLabelStyle
}

/** Matches SidebarProfileLink layout while CurrentUser is loading. */
function SidebarProfileSkeleton({
	className,
	inset = false,
	labelStyle,
}: SidebarProfileSkeletonProps) {
	return (
		<div
			className={cn(
				"flex items-center gap-4",
				inset ? "rounded-xl px-3 py-4" : "px-6 py-5",
				className,
			)}
			aria-hidden
			aria-busy="true"
		>
			<Skeleton className="size-11 shrink-0 rounded-full" />
			{/* Fades with the same spring as the real row's text, so a collapse
			    mid-load looks identical to a collapse after it. */}
			<animated.span
				className="flex min-w-0 flex-1 flex-col gap-2"
				style={labelStyle}
			>
				<Skeleton className="h-4 w-36 max-w-full" />
				<Skeleton className="h-3 w-24 max-w-full" />
			</animated.span>
		</div>
	)
}

export { SidebarProfileSkeleton }
