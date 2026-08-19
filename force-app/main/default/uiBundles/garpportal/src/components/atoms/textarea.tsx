import type { ComponentProps } from "react"

import { cn } from "@/lib/utils"

function Textarea({ className, ...props }: ComponentProps<"textarea">) {
	return (
		<textarea
			data-slot="textarea"
			className={cn(
				"flex min-h-24 w-full rounded-xl border border-input bg-transparent px-3 py-2 text-base outline-none placeholder:text-muted-foreground disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm dark:bg-input/30",
				"focus-visible:border-primary",
				"aria-invalid:border-destructive",
				className,
			)}
			{...props}
		/>
	)
}

export { Textarea }
