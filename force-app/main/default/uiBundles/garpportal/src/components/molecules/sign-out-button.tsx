import { useState } from "react"
import { LogOut } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { logoutToSalesforce } from "@/auth/logout"
import { cn } from "@/lib/utils"

type SignOutButtonProps = {
	className?: string
	size?: "default" | "sm"
}

/**
 * Shared Sign Out control — pointer cursor, disabled + label while redirecting
 * (mirrors the Login button “Signing in…” feedback).
 */
function SignOutButton({ className, size = "sm" }: SignOutButtonProps) {
	const [isPending, setIsPending] = useState(false)

	return (
		<Button
			type="button"
			variant="default"
			size={size}
			disabled={isPending}
			aria-busy={isPending}
			className={cn("cursor-pointer gap-2", className)}
			onClick={() => {
				if (isPending) return
				setIsPending(true)
				logoutToSalesforce()
			}}
		>
			<LogOut className="size-4" />
			{isPending ? "Signing out…" : "Sign Out"}
		</Button>
	)
}

export { SignOutButton }
