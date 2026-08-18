import { CircleArrowRight, Lock } from "lucide-react"
import { Link } from "@tanstack/react-router"

import { SpringNudge } from "@/components/atoms/spring-nudge"
import { useSpringNudge } from "@/hooks/use-spring-nudge"
import { parseInternalAppHref } from "@/lib/parse-internal-app-href"
import { cn } from "@/lib/utils"

type CardCtaProps = {
	label: string | null
	url: string | null
	isExternal: boolean
	/** Accessible name when the visible label is shortened for layout. */
	ariaLabel?: string
	locked?: boolean
	newWindow?: boolean
	/** When true, renders a non-interactive CTA (e.g. Register Now). */
	disabled?: boolean
	className?: string
}

/**
 * Benefit / hero CTA — external `<a>` or in-app TanStack `Link` from Apex flags.
 * In-app URLs may include a query string (`/membership?tab=directory`).
 *
 * Hover / focus motion comes from `useSpringNudge`; the handlers sit on the
 * interactive element itself so keyboard focus nudges too.
 */
function CardCta({
	label,
	url,
	isExternal,
	ariaLabel,
	locked = false,
	newWindow = false,
	disabled = false,
	className,
}: CardCtaProps) {
	const nudge = useSpringNudge({ direction: "forward", disabled })

	if (!label || !url) return null

	const inner = (
		<SpringNudge
			nudge={nudge}
			icon={<CircleArrowRight className="size-5" />}
			iconPosition="trailing"
		>
			{locked ? <Lock className="size-4 shrink-0" aria-hidden /> : null}
			<span>{label}</span>
		</SpringNudge>
	)

	const a11y = ariaLabel ? { "aria-label": ariaLabel } : {}

	const styles = cn(
		"inline-flex items-center text-sm font-semibold text-primary hover:text-primary/80",
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
				{...a11y}
				{...nudge.bind}
			>
				{inner}
			</a>
		)
	}

	const { pathname, search } = parseInternalAppHref(url)
	const hasSearch = Object.keys(search).length > 0

	if (hasSearch) {
		return (
			<Link
				to={pathname}
				search={search}
				className={styles}
				{...a11y}
				{...nudge.bind}
			>
				{inner}
			</Link>
		)
	}

	return (
		<Link to={pathname} className={styles} {...a11y} {...nudge.bind}>
			{inner}
		</Link>
	)
}

export { CardCta }
