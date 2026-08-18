import { CircleArrowRight, Lock } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { parseInternalAppHref } from "@/lib/parse-internal-app-href"
import { cn } from "@/lib/utils"

type CardCtaProps = {
	label: string | null
	url: string | null
	isExternal: boolean
	locked?: boolean
	newWindow?: boolean
	/** When true, renders a non-interactive CTA (e.g. Register Now). */
	disabled?: boolean
	className?: string
}

/**
 * Benefit / hero CTA — external `<a>` or in-app TanStack `Link` from Apex flags.
 * In-app URLs may include a query string (`/membership?tab=directory`).
 */
function CardCta({
	label,
	url,
	isExternal,
	locked = false,
	newWindow = false,
	disabled = false,
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
		"inline-flex items-center gap-2 text-sm font-semibold text-primary hover:text-primary/80",
		disabled && "pointer-events-none opacity-50 hover:text-primary",
		className,
	)

	if (disabled) {
		return (
			<span className={styles} aria-disabled="true">
				{inner}
			</span>
		)
	}

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

	const { pathname, search } = parseInternalAppHref(url)
	const hasSearch = Object.keys(search).length > 0

	if (hasSearch) {
		return (
			<Link to={pathname} search={search} className={styles}>
				{inner}
			</Link>
		)
	}

	return (
		<Link to={pathname} className={styles}>
			{inner}
		</Link>
	)
}

export { CardCta }
