import type { ComponentProps } from "react"

import { cn } from "@/lib/utils"

/**
 * Centers main page content at the live `$page-width` cap (1000px / `max-w-page`).
 * Use inside app layout `main` (and any future page that needs the same shell).
 */
function PageContainer({ className, ...props }: ComponentProps<"div">) {
	return <div className={cn("page-container", className)} {...props} />
}

export { PageContainer }
