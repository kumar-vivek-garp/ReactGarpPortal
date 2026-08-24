import type { ReactNode } from "react"
import { animated, useSpring, useTransition } from "@react-spring/web"
import { CircleCheck } from "lucide-react"

import { Badge } from "@/components/atoms/badge"
import {
	Card,
	CardAction,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import {
	ACCOUNT_SECTION_META,
	type AccountSection,
} from "@/config/account-sections"
import { cn } from "@/lib/utils"

/** Matches the app's panel/detail-enter feel. */
const SPOTLIGHT_SPRING = { mass: 0.9, tension: 320, friction: 26 }
const SAVE_SPRING = { mass: 0.8, tension: 380, friction: 28 }
/** Slow breathing pulse while a save is in flight. */
const PULSE_SPRING = { mass: 1, tension: 90, friction: 24 }

/**
 * Autosave feedback state. The inline cards (chapters / directory / expertise)
 * write on change, so without this the only signal is a global toast.
 */
export type AccountSaveState = "idle" | "saving" | "saved"

/**
 * The bento slots every Account Information card forwards. Kept as one type so
 * a new card cannot forget half of the pair.
 */
type AccountCardSlotProps = {
	/** Reorder grip, leading the card title. */
	handle?: ReactNode
}

type AccountSectionCardBaseProps = AccountCardSlotProps & {
	/** Overrides the section blurb when the copy is conditional (membership). */
	subtitle?: string
	/** Extreme-right control in the title row (e.g. Edit). */
	action?: ReactNode
	saveState?: AccountSaveState
	/** Flashes a ring when the card is jumped to from the completeness strip. */
	spotlight?: boolean
	/** Count badge in the header, e.g. profile fields still to fill in. */
	missingCount?: number
	children: ReactNode
	className?: string
}

/**
 * Two heading modes:
 * - `section` — the My Account bento, which takes its DOM anchor, icon and
 *   label from `ACCOUNT_SECTION_META` so the header and the completeness
 *   jump-to cannot drift apart.
 * - `title` — a plain heading, for the panels outside My Account that reuse
 *   this card (contact preferences, program exam overview).
 */
type AccountSectionCardProps = AccountSectionCardBaseProps &
	(
		| { section: AccountSection; title?: never }
		| { title: string; section?: never }
	)

function SaveIndicator({ state }: { state: AccountSaveState }) {
	const transitions = useTransition(state, {
		from: { opacity: 0, transform: "translateY(-4px)" },
		enter: { opacity: 1, transform: "translateY(0px)" },
		leave: { opacity: 0, transform: "translateY(-4px)" },
		config: SAVE_SPRING,
		exitBeforeEnter: true,
	})

	const pulse = useSpring({
		from: { opacity: 0.45 },
		to: { opacity: 1 },
		loop: { reverse: true },
		pause: state !== "saving",
		config: PULSE_SPRING,
	})

	return transitions((style, current) => {
		if (current === "idle") return null

		return (
			<animated.span
				style={style}
				className={cn(
					"inline-flex items-center gap-1 text-xs font-semibold",
					current === "saved" ? "text-success-green" : "text-muted-foreground",
				)}
				role="status"
			>
				{current === "saved" ? (
					<>
						<CircleCheck className="size-3.5" aria-hidden />
						Saved
					</>
				) : (
					<animated.span style={pulse}>Saving…</animated.span>
				)}
			</animated.span>
		)
	})
}

/**
 * One card in the Account Information bento.
 *
 * Deliberately not clickable as a whole — the header action and the controls
 * inside are the only hit targets, so there is no card-level hover state to
 * imply otherwise (same rule as `ProgramCard`).
 */
function AccountSectionCard({
	section,
	title,
	subtitle,
	action,
	saveState = "idle",
	spotlight = false,
	missingCount = 0,
	handle,
	children,
	className,
}: AccountSectionCardProps) {
	const meta = section ? ACCOUNT_SECTION_META[section] : null
	const Icon = meta?.icon
	const heading = meta?.label ?? title
	const blurb = subtitle ?? meta?.blurb

	const spotlightStyle = useSpring({
		opacity: spotlight ? 1 : 0,
		config: SPOTLIGHT_SPRING,
	})

	return (
		<Card
			id={meta?.domId}
			className={cn(
				// A real card surface — the flat muted panel gave every section the
				// same visual weight. `relative` positions the spotlight ring overlay.
				"relative h-full gap-4 bg-card py-5",
				className,
			)}
		>
			<animated.span
				className="pointer-events-none absolute inset-0 rounded-xl ring-2 ring-primary ring-inset"
				style={spotlightStyle}
				aria-hidden
			/>

			{/*
			 * Title / description / action must be direct CardHeader children so the
			 * shadcn grid places the action in column 2 (not beside the subtitle).
			 */}
			<CardHeader className="gap-1.5">
				<CardTitle className="flex min-w-0 items-center gap-2 font-heading text-lg tracking-wide">
					{handle}
					{Icon ? (
						<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
							<Icon className="size-4.5" aria-hidden />
						</span>
					) : null}
					<span className="min-w-0 truncate">{heading}</span>
					{missingCount > 0 ? (
						<Badge
							variant="outline"
							className="shrink-0 border-primary/40 bg-primary/5 font-semibold text-primary"
						>
							{missingCount} left
						</Badge>
					) : null}
				</CardTitle>
				{blurb ? <CardDescription>{blurb}</CardDescription> : null}
				<CardAction className="flex items-center gap-2">
					<SaveIndicator state={saveState} />
					{action}
				</CardAction>
			</CardHeader>

			<CardContent className="flex flex-1 flex-col gap-2.5">
				{children}
			</CardContent>
		</Card>
	)
}

export { AccountSectionCard }
export type { AccountCardSlotProps }
