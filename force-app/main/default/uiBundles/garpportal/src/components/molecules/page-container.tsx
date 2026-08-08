import type { ComponentProps } from "react"

import { cn } from "@/lib/utils"

/**
 * Main-column content shell. Fills the area beside the sidebar with modest
 * horizontal gutters (`px-4`). Prefer this over ad-hoc padding on pages.
 */
function PageContainer({ className, ...props }: ComponentProps<"div">) {
	return <div className={cn("page-container", className)} {...props} />
}

export { PageContainer }
