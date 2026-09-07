import { useLayoutEffect, useRef } from "react"
import { animated, useSpring } from "@react-spring/web"
import { ArrowRight, ChevronUp, Info, TriangleAlert } from "lucide-react"

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
	// One hue carries the whole tone: the icon chip, the deadline and the link.
	// Everything else on the card is neutral, so the hue is the only thing
	// competing for the eye.
	//
	// Spelled out in full per tone: Tailwind's scanner only sees literal class
	// strings, so nothing here may be assembled from fragments.
	const toneText = urgent ? "text-inverse-urgent" : "text-inverse-notice"
	const toneChip = urgent
		? "bg-inverse-urgent/15 text-inverse-urgent"
		: "bg-inverse-notice/15 text-inverse-notice"

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
				{/*
				 * The card is the page's opposite — dark on the light theme, white
				 * on the dark one — so it cannot blend into the cards around it.
				 * The atom's own variants both sit on `bg-card`, which is exactly
				 * the surface this has to stand apart from, so the tone is painted
				 * here from the `inverse-*` tokens instead of picked by variant.
				 */}
				<Alert
					// The atom hardcodes role="alert". That is right for an
					// urgent rung and too interrupting for a soft nudge.
					role={urgent ? "alert" : "status"}
					className={cn(
						"gap-x-3 gap-y-1.5 rounded-xl border-0 bg-inverse py-4 pr-10",
						"text-inverse-foreground shadow-lg",
						// The atom sizes column one from a *direct* svg child, and
						// ours is wrapped in its chip, so the track is set here.
						"grid-cols-[auto_1fr]",
					)}
				>
					{/*
					 * The tone accent is a contained chip, not a slab down the
					 * card's edge. A coloured left border is the house style of
					 * every framework alert of the last decade and reads as one
					 * on sight; the tinted tile is what the rest of this app
					 * already uses to badge a row (see `order-row`).
					 */}
					<span
						className={cn(
							// Spans both text rows rather than sitting in the title's own:
							// a 36px chip in row one stretches that row and opens a gap
							// between the programme and the deadline under it.
							"col-start-1 row-start-1 row-span-2 grid size-9 shrink-0 place-items-center rounded-lg",
							toneChip,
						)}
						aria-hidden
					>
						<Icon className="size-5" />
					</span>
					<AlertTitle className="text-base font-semibold tracking-normal">
						{model.programme}
					</AlertTitle>
					<AlertDescription className="gap-0 text-inverse-muted-foreground">
						{/* The deadline is the reason the card exists, so it takes
						    the tone colour and sits directly under the programme. */}
						{model.deadlineLabel ? (
							<span className={cn("mb-2 font-medium", toneText)}>
								{model.deadlineLabel}
							</span>
						) : null}
						<span>{model.message}</span>
						{model.action ? (
							<CardCta
								label={model.action.label}
								url={model.action.href}
								isExternal={model.action.isExternal}
								icon={<ArrowRight className="size-4" />}
								className={cn(
									"mt-3 text-sm",
									toneText,
									urgent
										? "hover:text-inverse-urgent/80"
										: "hover:text-inverse-notice/80",
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
							"absolute top-3 right-2 grid size-7 cursor-pointer place-items-center rounded-full text-inverse-muted-foreground",
							"hover:bg-inverse-hover hover:text-inverse-foreground",
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
