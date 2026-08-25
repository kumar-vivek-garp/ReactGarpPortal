import { useLayoutEffect, useRef } from "react"
import { animated, useSpring } from "@react-spring/web"
import { ChevronUp, Info, TriangleAlert } from "lucide-react"

import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { CardCta } from "@/components/molecules/card-cta"
import { ALERT_BAR_COLLAPSE_LABEL } from "@/config/alert-bar"
import {
	ALERT_FLIGHT_SPRING,
	computeFlightPose,
	flightFade,
	resolveAnchorRect,
} from "@/lib/alert-bar-flight"
import type { AlertBarModel } from "@/lib/alert-bar-presentation"
import { cn } from "@/lib/utils"
import { type AlertBarPhase, useAlertBarStore } from "@/store/alert-bar-store"

/**
 * Floats clear of the page rather than taking a band of it.
 *
 * Bottom-right, above page content but **below** dialogs and sheets (`z-50`),
 * so a modal is never fighting an alert for the foreground. Width is capped so
 * it stays a card and never becomes a full-width banner; the viewport clamp
 * keeps it inside the screen on a phone.
 */
const ANCHOR = "fixed right-4 z-40 w-[min(23rem,calc(100vw-2rem))] sm:right-6"

/**
 * Two other things claim this exact corner and are drawn over us: the "back to
 * top" button once the page is scrolled, and — in DEV only — the TanStack Query
 * devtools button. Either one hides enough of the card to make it look broken,
 * and back-to-top appears on any page long enough to scroll, so the clearance
 * is unconditional rather than a DEV-only workaround.
 */
const CORNER_CLEARANCE = "bottom-20 sm:bottom-24"

/**
 * Home, full size, nothing travelled.
 *
 * `t` is the journey's progress, carried on the same spring as the pose so it
 * cannot drift out of step with it. Opacity is derived from `t` rather than
 * animated alongside it — see `flightFade`.
 */
const AT_REST = { x: 0, y: 0, scale: 1, t: 0 }

/**
 * Mid-flight the card passes *over* the black toolbar to land on its trigger.
 * Underneath it, the last stretch of the journey is invisible and the card
 * reads as vanishing early. Suspending the below-dialogs rule is safe here
 * because a flight only ever starts from a click on this card or on the
 * trigger, and neither is reachable from behind a modal.
 */
function isFlying(phase: AlertBarPhase) {
	return phase === "minimising" || phase === "restoring"
}

type AlertBarCardProps = {
	model: AlertBarModel
	phase: AlertBarPhase
	onMinimise: () => void
	/** The card has landed in the toolbar; the trigger may now appear. */
	onMinimised: () => void
	/** The card is home. */
	onRestored: () => void
	className?: string
}

/**
 * The exam alert, as a floating card that minimises into the toolbar.
 *
 * Presentational only — it renders a resolved `AlertBarModel` and decides
 * nothing about which alert this is, where its button goes, or whether there is
 * one at all. All of that is settled in `alert-bar-presentation`.
 *
 * Minimising shrinks it into the toolbar trigger; it never dismisses. Every
 * alert Apex raises here is a deadline, so the minimised state is a labelled
 * control in the chrome rather than a faint chip that reads as "closed".
 * Losing a deadline behind a stray click is the one outcome to design out.
 *
 * The card stays mounted in every phase. Unmounting it while minimised would
 * mean the restore leg had nothing to measure and no pose to grow out of, and
 * would flash a full-size card for a frame before the spring caught up.
 */
function AlertBarCard({
	model,
	phase,
	onMinimise,
	onMinimised,
	onRestored,
	className,
}: AlertBarCardProps) {
	// The outer element carries the anchoring and is never transformed, so it
	// measures the card's resting rect whatever the spring is currently doing.
	// Measuring the animated element itself would feed each flight the previous
	// flight's end position.
	const restRef = useRef<HTMLDivElement>(null)
	const [style, api] = useSpring(() => ({ ...AT_REST, config: ALERT_FLIGHT_SPRING }))

	// Poses are measured at the moment they are needed: where the trigger sits
	// depends on which toolbar is on screen and how wide the window is now.
	useLayoutEffect(() => {
		function poseAtTrigger() {
			const rest = restRef.current?.getBoundingClientRect()
			if (!rest) return null
			const { anchors } = useAlertBarStore.getState()
			const anchor = resolveAnchorRect([anchors.desktop, anchors.mobile])
			return { ...computeFlightPose(rest, anchor), t: 1 }
		}

		if (phase === "expanded") {
			void api.start({ to: AT_REST })
			return
		}

		// Reached without flying when the layout remounts under a phase the
		// store is still holding — a card at rest here would sit on screen
		// alongside its own toolbar trigger.
		if (phase === "minimised") {
			const away = poseAtTrigger()
			if (away) api.set(away)
			return
		}

		const away = poseAtTrigger()
		if (!away) return

		void api.start({
			// Restoring grows the card out of the trigger; the explicit `from`
			// is what makes it emerge from the toolbar rather than fade in
			// where it already sits.
			...(phase === "restoring" ? { from: away, to: AT_REST } : { to: away }),
			// `onRest` also fires when an animation is interrupted — handing the
			// phase on then would strand the card mid-flight.
			onRest: (result) => {
				if (!result.finished) return
				if (phase === "restoring") onRestored()
				else onMinimised()
			},
		})
	}, [phase, api, onMinimised, onRestored])

	const urgent = model.tone === "urgent"
	const Icon = urgent ? TriangleAlert : Info
	const interactive = phase === "expanded"

	return (
		<div
			ref={restRef}
			className={cn(
				ANCHOR,
				CORNER_CLEARANCE,
				isFlying(phase) && "z-[1001]",
				!interactive && "pointer-events-none",
				className,
			)}
			inert={!interactive}
		>
			<animated.div
				style={{
					x: style.x,
					y: style.y,
					scale: style.scale,
					// Held solid for the first stretch of the journey, so what
					// the eye follows is an object moving rather than one fading.
					opacity: style.t.to(flightFade),
					// The card shrinks toward the toolbar, so the corner nearest
					// it is the one that must stay put under the scale.
					transformOrigin: "top right",
				}}
			>
				<Alert
					variant={urgent ? "destructive" : "default"}
					// The atom hardcodes role="alert". That is right for an
					// urgent rung and too interrupting for a soft nudge.
					role={urgent ? "alert" : "status"}
					className="gap-y-1 rounded-xl py-2.5 pr-10 shadow-lg"
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

					{/* A chevron rather than a cross: it points at where the card
					    is about to go, and nothing here can be dismissed. */}
					<button
						type="button"
						onClick={onMinimise}
						aria-label={ALERT_BAR_COLLAPSE_LABEL}
						className={cn(
							// A circle, so the hover fill and the focus ring both
							// read as one round control rather than a stray square
							// tucked into a `rounded-xl` corner.
							"absolute top-2 right-2 grid size-7 cursor-pointer place-items-center rounded-full opacity-70",
							"hover:bg-accent hover:text-accent-foreground hover:opacity-100",
							"focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
						)}
					>
						<ChevronUp className="size-4" aria-hidden />
					</button>
				</Alert>
			</animated.div>
		</div>
	)
}

export { AlertBarCard }
