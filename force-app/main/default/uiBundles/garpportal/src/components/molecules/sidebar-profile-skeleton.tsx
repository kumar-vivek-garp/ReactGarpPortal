import { Skeleton } from "@/components/atoms/skeleton"
import { cn } from "@/lib/utils"

type SidebarProfileSkeletonProps = {
	className?: string
	/** Must match the `inset` of the SidebarProfileLink it stands in for. */
	inset?: boolean
}

/** Matches SidebarProfileLink layout while CurrentUser is loading. */
function SidebarProfileSkeleton({ className, inset = false }: SidebarProfileSkeletonProps) {
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
			<span className="flex min-w-0 flex-1 flex-col gap-2">
				<Skeleton className="h-4 w-36 max-w-full" />
				<Skeleton className="h-3 w-24 max-w-full" />
			</span>
		</div>
	)
}

export { SidebarProfileSkeleton }
