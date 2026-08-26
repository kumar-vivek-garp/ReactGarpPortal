import { useState } from "react"
import { animated, useTransition } from "@react-spring/web"
import { Check, Copy } from "lucide-react"

import { useSpringPress } from "@/hooks/use-spring-press"
import { cn } from "@/lib/utils"

const COPY_SPRING = { mass: 0.8, tension: 380, friction: 28 }

/** How long the copied-to-clipboard tick stays up. */
const COPIED_HOLD_MS = 1600

type GarpIdChipProps = {
	garpId: string
	className?: string
}

/**
 * Copy-to-clipboard pill for a member's GARP ID — shared by the account and
 * membership identity heroes so the affordance behaves identically everywhere.
 */
function GarpIdChip({ garpId, className }: GarpIdChipProps) {
	const [copied, setCopied] = useState(false)
	const { bind, style } = useSpringPress<HTMLButtonElement>()

	const iconTransitions = useTransition(copied, {
		from: { opacity: 0, transform: "scale(0.6)" },
		enter: { opacity: 1, transform: "scale(1)" },
		leave: { opacity: 0, transform: "scale(0.6)" },
		config: COPY_SPRING,
		exitBeforeEnter: true,
	})

	const copy = () => {
		void navigator.clipboard?.writeText(garpId).then(() => {
			setCopied(true)
			window.setTimeout(() => setCopied(false), COPIED_HOLD_MS)
		})
	}

	return (
		<button
			type="button"
			onClick={copy}
			aria-label={`Copy GARP ID ${garpId}`}
			className={cn(
				"inline-flex items-center gap-1.5 rounded-full border border-border bg-card px-2.5 py-0.5 text-xs font-semibold text-foreground hover:bg-accent hover:text-accent-foreground",
				className,
			)}
			{...bind}
		>
			<animated.span
				className="inline-flex items-center gap-1.5 will-change-transform"
				style={{ scale: style.scale }}
			>
				<span className="text-muted-foreground">GARP ID</span>
				{garpId}
				<span className="relative inline-flex size-3.5 items-center justify-center">
					{iconTransitions((iconStyle, isCopied) => (
						<animated.span
							className="absolute inline-flex"
							style={iconStyle}
							aria-hidden
						>
							{isCopied ? (
								<Check className="size-3.5 text-success-green" />
							) : (
								<Copy className="size-3.5 text-muted-foreground" />
							)}
						</animated.span>
					))}
				</span>
			</animated.span>
		</button>
	)
}

export { GarpIdChip }
