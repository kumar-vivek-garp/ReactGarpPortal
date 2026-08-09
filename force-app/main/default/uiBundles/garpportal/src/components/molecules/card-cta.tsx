import { CircleArrowRight, Lock } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { cn } from "@/lib/utils"

type CardCtaProps = {
	label: string | null
	url: string | null
	isExternal: boolean
	locked?: boolean
	newWindow?: boolean
	className?: string
}

/**
 * Benefit / hero CTA — external `<a>` or in-app TanStack `Link` from Apex flags.
 */
function CardCta({
	label,
	url,
	isExternal,
	locked = false,
	newWindow = false,
	className,
}: CardCtaProps) {
	if (!label || !url) return null

	const inner = (
		<>
			{locked ? <Lock className="size-4" /> : null}
			<span>{label}</span>
			<CircleArrowRight className="size-5 shrink-0" />
		</>
	)

	const styles = cn(
		"inline-flex items-center gap-2 text-sm font-semibold text-foreground hover:text-garp-cyan",
		className,
	)

	if (isExternal) {
		return (
			<a
				href={url}
				className={styles}
				{...(newWindow ? { target: "_blank", rel: "noreferrer noopener" } : {})}
			>
				{inner}
			</a>
		)
	}

	return (
		<Link to={url} className={styles}>
			{inner}
		</Link>
	)
}

export { CardCta }
