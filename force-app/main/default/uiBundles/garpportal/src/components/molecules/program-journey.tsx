import { animated, useSprings, type SpringValue } from "@react-spring/web"
import { Circle, CircleDot, OctagonAlert } from "lucide-react"

import { Card } from "@/components/atoms/card"
import { usePrefersReducedMotion } from "@/hooks/use-prefers-reduced-motion"
import type { JourneyMilestone } from "@/lib/program-detail-presentation"
import { cn } from "@/lib/utils"

type ProgramJourneyProps = {
	milestones: JourneyMilestone[]
	className?: string
}

const STATUS_ICON = {
	current: CircleDot,
	upcoming: Circle,
	blocked: OctagonAlert,
} as const

const STATUS_CLASS = {
	complete: "bg-success-green/15 text-success-green",
	current: "bg-primary/15 text-primary",
	upcoming: "bg-muted text-muted-foreground",
	blocked: "bg-pink text-pink-foreground",
} as const

/** The node lands with a little overshoot — it reads as arriving, not fading. */
const NODE_SPRING = { mass: 0.7, tension: 300, friction: 20 }
/** The segment travels; softer so the reach between nodes is legible. */
const LINE_SPRING = { mass: 1, tension: 170, friction: 26 }

/** Node lands, then its tick strokes on. */
const NODE_STEP_MS = 170
/** Tick finishes, then the line sets off for the next node. */
const LINE_STEP_MS = 260

/**
 * Lucide's own `Check` path, inlined so the stroke can be drawn.
 * `pathLength={1}` normalises the dash maths to 0–1 regardless of the
 * geometry — same trick as `completion-ring`.
 */
function DrawnCheck({ draw }: { draw: SpringValue<number> }) {
	return (
		<svg
			viewBox="0 0 24 24"
			fill="none"
			stroke="currentColor"
			strokeWidth={3}
			strokeLinecap="round"
			strokeLinejoin="round"
			className="size-4"
			aria-hidden
		>
			<animated.path
				d="M20 6 9 17l-5-5"
				pathLength={1}
				strokeDasharray={1}
				strokeDashoffset={draw.to((v) => 1 - v)}
			/>
		</svg>
	)
}

function ProgramJourney({ milestones, className }: ProgramJourneyProps) {
	const prefersReducedMotion = usePrefersReducedMotion()
	const count = milestones.length
	/*
	 * `milestones` is rebuilt every render, so it cannot be a dep itself —
	 * length plus the status word per step is what the springs actually read.
	 */
	const statusKey = milestones.map((step) => step.status).join("|")
	/*
	 * `Globals.skipAnimation` (set once in `__root.tsx`) flattens the springs
	 * under "reduce motion" but does NOT cancel a `delay`, so the steps would
	 * still trickle in over a couple of seconds. Collapse the stagger too.
	 */
	const nodeDelay = (index: number) =>
		prefersReducedMotion ? 0 : index * (NODE_STEP_MS + LINE_STEP_MS)
	const lineDelay = (index: number) =>
		prefersReducedMotion ? 0 : nodeDelay(index) + NODE_STEP_MS

	const [nodes] = useSprings(
		count,
		(index) => ({
			from: { opacity: 0, scale: 0.55, draw: 0 },
			to: { opacity: 1, scale: 1, draw: 1 },
			delay: nodeDelay(index),
			config: NODE_SPRING,
		}),
		[count, statusKey, prefersReducedMotion],
	)

	const [lines] = useSprings(
		Math.max(count - 1, 0),
		(index) => ({
			from: { p: 0 },
			// A segment only fills once the step it leaves is done; the rest of
			// the journey stays as bare track.
			to: { p: milestones[index]?.status === "complete" ? 1 : 0 },
			delay: lineDelay(index),
			config: LINE_SPRING,
		}),
		[count, statusKey, prefersReducedMotion],
	)

	if (count === 0) return null

	return (
		<Card asChild className={cn("gap-4 py-5 shadow-none", className)}>
			<section aria-label="Program journey">
				<h2 className="px-5 font-heading text-lg tracking-wide text-heading">
					Your journey
				</h2>
				{/*
				 * A rail down the side on a phone, a stepper across the card on a
				 * desktop — the same markup, re-laid-out. Four or five one-word steps
				 * stacked vertically left the right two-thirds of this card empty and
				 * pushed the exam cards below the fold (UI/UX request, Sep 2026).
				 *
				 * `auto-cols-fr` rather than a fixed column count: a journey is four
				 * steps normally and five once it reaches Certification or Work
				 * experience, and the columns have to stay even either way.
				 */}
				<ol className="space-y-0 px-5 app:grid app:grid-flow-col app:auto-cols-fr">
					{milestones.map((step, index) => {
						const node = nodes[index]
						const line = lines[index]
						const isLast = index === milestones.length - 1
						const Icon =
							step.status === "complete"
								? null
								: STATUS_ICON[step.status]
						return (
							<li
								key={step.id}
								className={cn(
									"relative flex gap-3 pb-5 last:pb-0",
									"app:flex-col app:items-center app:gap-2 app:pb-0 app:text-center",
								)}
							>
								{!isLast && line ? (
									/*
									 * Lives ONLY in the gap between two nodes — from this
									 * circle's edge to the next one's. It used to span the
									 * whole column and pass under the icons, which only
									 * works if they are opaque: they are tinted at 15%, so
									 * the line showed straight through and every tick read
									 * as pasted onto one continuous scratch.
									 *
									 * 1.375rem = the circle's radius (size-9 → 1.125rem)
									 * plus a 0.25rem breath.
									 */
									<span
										className={cn(
											"absolute overflow-hidden rounded-full bg-border",
											"top-10 bottom-1 left-4.5 w-1.5 -translate-x-1/2",
											"app:top-4.25 app:bottom-auto app:left-[calc(50%+1.375rem)] app:h-1.5 app:w-[calc(100%-2.75rem)] app:translate-x-0",
										)}
										aria-hidden
									>
										{/*
										 * One spring, two axes: the track is vertical on a
										 * phone and horizontal on a desktop, so each fill
										 * is hidden at the other breakpoint.
										 */}
										<animated.span
											className="absolute left-0 top-0 w-full rounded-full bg-success-green app:hidden"
											style={{
												height: line.p.to(
													(v) => `${v * 100}%`,
												),
											}}
										/>
										<animated.span
											className="absolute left-0 top-0 hidden h-full rounded-full bg-success-green app:block"
											style={{
												width: line.p.to(
													(v) => `${v * 100}%`,
												),
											}}
										/>
									</span>
								) : null}
								<animated.span
									className={cn(
										// `ring-card` paints the Card's own surface, so the
										// node sits ON the rail rather than over it.
										"relative z-10 flex size-9 shrink-0 items-center justify-center rounded-full ring-4 ring-card",
										STATUS_CLASS[step.status],
									)}
									style={
										node
											? { opacity: node.opacity, scale: node.scale }
											: undefined
									}
								>
									{Icon ? (
										<Icon className="size-4" aria-hidden />
									) : node ? (
										<DrawnCheck draw={node.draw} />
									) : null}
								</animated.span>
								{/*
								 * The columns sit flush so the rail can reach across them,
								 * so the breathing room between two steps' text is padding
								 * here rather than a grid gap.
								 */}
								<animated.div
									className="min-w-0 pt-1.5 app:px-2 app:pt-0"
									style={node ? { opacity: node.opacity } : undefined}
								>
									<p className="text-sm font-semibold text-foreground">
										{step.label}
										<span className="sr-only"> — {step.status}</span>
									</p>
									{step.detail ? (
										<p className="mt-0.5 text-sm text-muted-foreground">
											{step.detail}
										</p>
									) : null}
								</animated.div>
							</li>
						)
					})}
				</ol>
			</section>
		</Card>
	)
}

export { ProgramJourney }
