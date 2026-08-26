import { useCallback } from "react"
import { animated, useSpring } from "@react-spring/web"
import { Info, TriangleAlert } from "lucide-react"

import { Button } from "@/components/atoms/button"
import type { AlertTone } from "@/config/alert-bar"
import { ALERT_BAR_COLLAPSED_LABEL, ALERT_BAR_EXPAND_LABEL } from "@/config/alert-bar"
import { useAlertBar } from "@/hooks/use-alert-bar"
import { ALERT_LANDING_SPRING } from "@/lib/alert-bar-flight"
import { cn } from "@/lib/utils"
import { type AlertBarPlacement, useAlertBarStore } from "@/store/alert-bar-store"

/** Small enough to read as "not there", large enough to spring out of. */
const HIDDEN_SCALE = 0.6

type TriggerVariant = "toolbar" | "sheet"

/**
 * Two tones across two chrome backgrounds, so four appearances.
 *
 * Held as a table rather than assembled from conditions in `cn()`: the cross
 * product is exactly the shape that turns into an unreadable chain of `&&`s,
 * and each cell here is one legible answer to "what does this look like there".
 *
 * `toolbar` is the nav bar surface — white in light, dark card in dark, per
 * www.garp.org — so it is tinted from `--toolbar-foreground` rather than from
 * the page's foreground, keeping it legible whatever the bar is painted.
 * `sheet` is the light panel the mobile bar switches to when its menu opens.
 *
 * Colour is reserved for urgency: a notice-tone alert is outlined, not tinted
 * with a hue that would compete with the nav's own state colours.
 */
const TRIGGER_TONE: Record<TriggerVariant, Record<AlertTone, string>> = {
	toolbar: {
		// Same destructive-on-surface recipe the sheet variant already uses on
		// light chrome, so urgency reads on the toolbar in both themes.
		urgent:
			"border-destructive/60 bg-destructive/15 text-destructive hover:bg-destructive/25 hover:text-destructive",
		notice:
			"border-toolbar-foreground/30 bg-toolbar-foreground/10 text-toolbar-foreground hover:bg-toolbar-foreground/20 hover:text-toolbar-foreground",
	},
	sheet: {
		urgent:
			"border-destructive/50 bg-destructive/10 text-destructive hover:bg-destructive/20 hover:text-destructive",
		notice:
			"border-border bg-accent text-accent-foreground hover:bg-accent/80 hover:text-accent-foreground",
	},
}

type AlertBarTriggerProps = {
	placement: AlertBarPlacement
	/** Outlined on the toolbar surface; sheet when the mobile panel uses light chrome. */
	variant?: TriggerVariant
	/** Runs before the card comes back — the mobile bar closes its panel here. */
	onActivate?: () => void
	className?: string
}

/**
 * The minimised alert, parked in the toolbar.
 *
 * It is the card's other half rather than a second alert: exactly one of the
 * two is ever visible, and the card flies into this control's centre on the way
 * out and grows back out of it on the way in.
 *
 * Which means the slot is held for as long as an alert exists, even while the
 * card is open and this is invisible. Springing the width open instead would
 * move this element's own left edge during the flight, so the card would be
 * aiming at a rect that no longer existed by the time it arrived. The reserved
 * space costs nothing visually — it is indistinguishable from the empty bar
 * already sitting between the nav and the right-hand controls.
 */
function AlertBarTrigger({
	placement,
	variant = "toolbar",
	onActivate,
	className,
}: AlertBarTriggerProps) {
	const { model, phase, restore } = useAlertBar()
	const setAnchor = useAlertBarStore((state) => state.setAnchor)

	const registerAnchor = useCallback(
		(element: HTMLDivElement | null) => setAnchor(placement, element),
		[setAnchor, placement],
	)

	const shown = phase === "minimised"
	const style = useSpring({
		opacity: shown ? 1 : 0,
		scale: shown ? 1 : HIDDEN_SCALE,
		config: ALERT_LANDING_SPRING,
	})

	if (!model) return null

	const urgent = model.tone === "urgent"
	const Icon = urgent ? TriangleAlert : Info

	return (
		<animated.div
			ref={registerAnchor}
			className={cn("shrink-0", className)}
			style={{ ...style, pointerEvents: shown ? "auto" : "none" }}
			aria-hidden={!shown}
		>
			<Button
				type="button"
				variant="ghost"
				size="sm"
				tabIndex={shown ? 0 : -1}
				aria-label={ALERT_BAR_EXPAND_LABEL}
				onClick={() => {
					onActivate?.()
					restore()
				}}
				// `ghost` is the one variant with no background of its own to
				// fight; the border and fill come from the tone table.
				className={cn("rounded-full border", TRIGGER_TONE[variant][model.tone])}
			>
				<Icon className="size-4" aria-hidden />
				{ALERT_BAR_COLLAPSED_LABEL}
			</Button>
		</animated.div>
	)
}

export { AlertBarTrigger }
