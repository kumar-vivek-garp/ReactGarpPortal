import { animated, useTransition } from "@react-spring/web"
import { Info, TriangleAlert, X } from "lucide-react"

import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { CardCta } from "@/components/molecules/card-cta"
import {
	ALERT_BAR_COLLAPSE_LABEL,
	ALERT_BAR_COLLAPSED_LABEL,
	ALERT_BAR_EXPAND_LABEL,
} from "@/config/alert-bar"
import type { AlertBarModel } from "@/lib/alert-bar-presentation"
import { cn } from "@/lib/utils"

const SWAP_SPRING = { mass: 0.8, tension: 380, friction: 30 }

/**
 * Floats clear of the page rather than taking a band of it.
 *
 * Bottom-right, above page content but **below** dialogs and sheets (`z-50`),
 * so a modal is never fighting an alert for the foreground. Width is capped so
 * it stays a card and never becomes a full-width banner; the viewport clamp
 * keeps it inside the screen on a phone.
 */
const ANCHOR =
	"fixed right-4 bottom-4 z-40 w-[min(23rem,calc(100vw-2rem))] sm:right-6 sm:bottom-6"

/**
 * The TanStack Query devtools button lives in this exact corner and is drawn
 * over us, which hides the collapsed pill almost completely — the alert looks
 * dismissed rather than collapsed. It is mounted for `import.meta.env.DEV`
 * only (see `pages/__root.tsx`), so the clearance is too.
 */
const DEVTOOLS_CLEARANCE = import.meta.env.DEV ? "bottom-20 sm:bottom-20" : ""

type AlertBarBannerProps = {
	model: AlertBarModel
	isCollapsed: boolean
	onCollapse: () => void
	onExpand: () => void
	className?: string
}

/**
 * The exam alert, as a floating card that collapses to a pill.
 *
 * Presentational only — it renders a resolved `AlertBarModel` and decides
 * nothing about which alert this is, where its button goes, or whether there is
 * one at all. All of that is settled in `alert-bar-presentation`.
 *
 * Collapse shrinks it; it never dismisses. Every alert Apex raises here is a
 * deadline, so the collapsed state is a labelled, bordered control sitting in
 * the same corner the card occupied — not a faint chip that reads as "closed".
 * Losing a deadline behind a stray click is the one outcome to design out.
 */
function AlertBarBanner({
	model,
	isCollapsed,
	onCollapse,
	onExpand,
	className,
}: AlertBarBannerProps) {
	const urgent = model.tone === "urgent"
	const Icon = urgent ? TriangleAlert : Info

	const transitions = useTransition(isCollapsed, {
		from: { opacity: 0, transform: "translateY(12px) scale(0.96)" },
		enter: { opacity: 1, transform: "translateY(0px) scale(1)" },
		leave: { opacity: 0, transform: "translateY(12px) scale(0.96)" },
		config: SWAP_SPRING,
		exitBeforeEnter: true,
	})

	return (
		<div className={cn(ANCHOR, DEVTOOLS_CLEARANCE, className)}>
			{transitions((style, collapsed) =>
				collapsed ? (
					<animated.div style={style} className="flex justify-end">
						<button
							type="button"
							onClick={onExpand}
							aria-label={ALERT_BAR_EXPAND_LABEL}
							className={cn(
								"inline-flex items-center gap-2 rounded-full border bg-card px-3.5 py-2",
								"text-sm font-semibold shadow-lg",
								"hover:bg-accent hover:text-accent-foreground",
								"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
								urgent ? "text-destructive" : "text-foreground",
							)}
						>
							<Icon className="size-4 shrink-0" aria-hidden />
							{ALERT_BAR_COLLAPSED_LABEL}
						</button>
					</animated.div>
				) : (
					<animated.div style={style}>
						<Alert
							variant={urgent ? "destructive" : "default"}
							// The atom hardcodes role="alert". That is right for an
							// urgent rung and too interrupting for a soft nudge.
							role={urgent ? "alert" : "status"}
							className="gap-y-1 py-2.5 pr-10 shadow-lg"
						>
							<Icon aria-hidden />
							{/* Programme and deadline share the title line: two short
							    facts that would otherwise cost two rows of a card
							    deliberately kept small. */}
							<AlertTitle className="text-[0.9375rem]">
								{model.programme}
								{model.deadlineLabel ? (
									<span className="font-normal text-muted-foreground">
										{" · "}
										{model.deadlineLabel}
									</span>
								) : null}
							</AlertTitle>
							<AlertDescription className="gap-0.5">
								<span>{model.message}</span>
								{model.action ? (
									<CardCta
										label={model.action.label}
										url={model.action.href}
										isExternal={model.action.isExternal}
										className={cn(
											"text-sm",
											urgent && "text-destructive hover:text-destructive/80",
										)}
									/>
								) : null}
							</AlertDescription>

							<button
								type="button"
								onClick={onCollapse}
								aria-label={ALERT_BAR_COLLAPSE_LABEL}
								className={cn(
									"absolute top-2 right-2 rounded-sm p-1 opacity-70",
									"hover:bg-accent hover:text-accent-foreground hover:opacity-100",
									"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
								)}
							>
								<X className="size-4" aria-hidden />
							</button>
						</Alert>
					</animated.div>
				),
			)}
		</div>
	)
}

export { AlertBarBanner }
