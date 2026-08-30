import { LogIn } from "lucide-react"
import { Link, useCanGoBack, useRouter } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { LOGIN_PATH } from "@/auth/constants"
import { cn } from "@/lib/utils"

type NotFoundPanelProps = {
	/** Which way forward to offer — the portal for members, Sign In for guests. */
	variant: "member" | "guest"
	/** The URL that missed, shown so a mistyped link is diagnosable at a glance. */
	attemptedPath?: string
	className?: string
}

/**
 * The 404 content itself, chrome-agnostic — `NotFoundPage` wraps it in the
 * portal or public shell, and route-thrown `notFound()`s render it bare inside
 * whatever chrome the throwing route already has.
 *
 * Guest Sign In deliberately carries no `startUrl`: the attempted path would
 * just 404 again after login, and `_authLayout` already falls back to the
 * dashboard.
 */
function NotFoundPanel({ variant, attemptedPath, className }: NotFoundPanelProps) {
	const router = useRouter()
	const canGoBack = useCanGoBack()

	return (
		// The base Card carries the portal's standard border (border-primary/20)
		// and shadow; the gradient paints over its bg-card fill.
		<Card
			className={cn(
				"min-h-[60vh] items-center justify-center bg-linear-to-br from-surface-gradient-start to-surface-gradient-end px-6 py-16 text-center",
				className,
			)}
		>
			<p
				aria-hidden
				className="font-heading text-7xl font-bold tracking-tight text-foreground sm:text-8xl"
			>
				4<span className="text-primary">0</span>4
			</p>
			<h1 className="mt-4 font-heading text-2xl font-semibold tracking-wide text-foreground">
				Page not found
			</h1>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				The page you&apos;re looking for doesn&apos;t exist or may have moved.
			</p>

			{attemptedPath ? (
				<code className="mt-4 max-w-full truncate rounded-md bg-muted px-2.5 py-1 font-mono text-xs text-muted-foreground">
					{attemptedPath}
				</code>
			) : null}

			<div className="mt-8 flex flex-wrap items-center justify-center gap-3">
				{variant === "member" ? (
					<>
						<Button asChild>
							<Link to="/dashboard">Go to Dashboard</Link>
						</Button>
						{canGoBack ? (
							<Button
								variant="outline"
								onClick={() => {
									router.history.back()
								}}
							>
								Go back
							</Button>
						) : null}
					</>
				) : (
					<>
						<Button asChild className="gap-2">
							<Link to={LOGIN_PATH}>
								<LogIn className="size-4" />
								Sign In
							</Link>
						</Button>
						<Button asChild variant="outline">
							<a href="https://www.garp.org/">Go to garp.org</a>
						</Button>
					</>
				)}
			</div>
		</Card>
	)
}

export { NotFoundPanel }
