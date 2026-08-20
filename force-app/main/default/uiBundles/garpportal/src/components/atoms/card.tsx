import * as React from "react"
import { animated, useSpring } from "@react-spring/web"
import { Slot } from "radix-ui"

import { cn } from "@/lib/utils"

/**
 * Hover lifts the card; press squashes it. Kept deliberately small so the
 * motion reads as polish, not a jump.
 */
const CARD_MOTION_SPRING = { mass: 0.85, tension: 320, friction: 26 } as const

/**
 * Wait after pointer/key release so the press spring can settle before
 * `onActivate` runs (e.g. route changes that unmount the card).
 */
export const CARD_ACTIVATE_SETTLE_MS = 180

const AnimatedDiv = animated("div")
const AnimatedSlot = animated(Slot.Root)

type CardProps = React.ComponentProps<"div"> & {
	/**
	 * Opt-in clickable motion: spring lift on hover, squash on press.
	 * Off by default so static cards keep a flat surface.
	 */
	interactive?: boolean
	/** Merge card styles onto the child (e.g. TanStack `Link`). */
	asChild?: boolean
	/**
	 * Fires after press/click release + settle delay when `interactive`.
	 * Prefer this over `onClick` for navigation so motion is not cut short.
	 */
	onActivate?: () => void
}

function Card({
	className,
	interactive = false,
	asChild = false,
	onActivate,
	style,
	onClick,
	onPointerEnter,
	onPointerLeave,
	onPointerDown,
	onPointerUp,
	onPointerCancel,
	onFocus,
	onBlur,
	onKeyDown,
	onKeyUp,
	...props
}: CardProps) {
	const [hovered, setHovered] = React.useState(false)
	const [pressed, setPressed] = React.useState(false)
	const activateTimerRef = React.useRef<ReturnType<typeof setTimeout> | null>(
		null,
	)
	const activatePendingRef = React.useRef(false)

	const motion = useSpring({
		y: interactive ? (pressed ? 0.5 : hovered ? -2 : 0) : 0,
		scale: interactive ? (pressed ? 0.992 : 1) : 1,
		borderAlpha: interactive ? (hovered || pressed ? 0.38 : 0.2) : 0.2,
		// Soft elevation that still reads on dark surfaces without a heavy bloom.
		boxShadow: interactive
			? pressed
				? "0 1px 3px rgb(0 0 0 / 0.22)"
				: hovered
					? "0 6px 16px rgb(0 0 0 / 0.32)"
					: "0 2px 4px rgb(0 0 0 / 0.18)"
			: "0 1px 2px rgb(0 0 0 / 0.05)",
		config: CARD_MOTION_SPRING,
	})

	const Comp = asChild ? AnimatedSlot : AnimatedDiv

	const releasePress = () => setPressed(false)

	React.useEffect(
		() => () => {
			if (activateTimerRef.current) clearTimeout(activateTimerRef.current)
		},
		[],
	)

	const scheduleActivate = React.useCallback(() => {
		if (!interactive || !onActivate || activatePendingRef.current) return
		activatePendingRef.current = true
		if (activateTimerRef.current) clearTimeout(activateTimerRef.current)
		activateTimerRef.current = setTimeout(() => {
			activatePendingRef.current = false
			onActivate()
		}, CARD_ACTIVATE_SETTLE_MS)
	}, [interactive, onActivate])

	return (
		<Comp
			data-slot="card"
			data-interactive={interactive ? "true" : undefined}
			className={cn(
				// `border-primary/20` over the bare neutral `border` token — every card
				// reads as part of this app's brand, not a generic gray box.
				// Interactive owns border + shadow via spring — skip Tailwind shadow
				// so it cannot fight the animated elevation (esp. dark surfaces).
				"flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground",
				!interactive && "border-primary/20 shadow-sm",
				interactive &&
					"relative z-0 cursor-pointer outline-none will-change-transform focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 data-[hovered=true]:z-10",
				className,
			)}
			data-hovered={interactive && hovered ? "true" : undefined}
			style={
				interactive
					? {
							...style,
							y: motion.y,
							scale: motion.scale,
							borderColor: motion.borderAlpha.to(
								(a) =>
									`color-mix(in oklab, var(--primary) ${Math.round(a * 100)}%, transparent)`,
							),
							boxShadow: motion.boxShadow,
						}
					: style
			}
			{...props}
			onPointerEnter={
				interactive
					? (event) => {
							setHovered(true)
							onPointerEnter?.(event)
						}
					: onPointerEnter
			}
			onPointerLeave={
				interactive
					? (event) => {
							setHovered(false)
							releasePress()
							onPointerLeave?.(event)
						}
					: onPointerLeave
			}
			onPointerDown={
				interactive
					? (event) => {
							setPressed(true)
							onPointerDown?.(event)
						}
					: onPointerDown
			}
			onPointerUp={
				interactive
					? (event) => {
							releasePress()
							onPointerUp?.(event)
						}
					: onPointerUp
			}
			onPointerCancel={
				interactive
					? (event) => {
							releasePress()
							onPointerCancel?.(event)
						}
					: onPointerCancel
			}
			onFocus={
				interactive
					? (event) => {
							setHovered(true)
							onFocus?.(event)
						}
					: onFocus
			}
			onBlur={
				interactive
					? (event) => {
							setHovered(false)
							releasePress()
							onBlur?.(event)
						}
					: onBlur
			}
			onClick={
				interactive && onActivate
					? (event) => {
							event.preventDefault()
							scheduleActivate()
							onClick?.(event)
						}
					: onClick
			}
			onKeyDown={
				interactive
					? (event) => {
							if (
								event.key === " " ||
								event.key === "Spacebar"
							) {
								event.preventDefault()
							}
							if (
								!event.repeat &&
								(event.key === "Enter" ||
									event.key === " " ||
									event.key === "Spacebar")
							) {
								setPressed(true)
							}
							onKeyDown?.(event)
						}
					: onKeyDown
			}
			onKeyUp={
				interactive
					? (event) => {
							if (
								event.key === "Enter" ||
								event.key === " " ||
								event.key === "Spacebar"
							) {
								releasePress()
								if (onActivate) {
									event.preventDefault()
									scheduleActivate()
								}
							}
							onKeyUp?.(event)
						}
					: onKeyUp
			}
		/>
	)
}

function CardHeader({ className, ...props }: React.ComponentProps<"div">) {
	return (
		<div
			data-slot="card-header"
			className={cn(
				"@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6",
				className,
			)}
			{...props}
		/>
	)
}

function CardTitle({ className, ...props }: React.ComponentProps<"div">) {
	return (
		<div
			data-slot="card-title"
			className={cn("leading-none font-semibold", className)}
			{...props}
		/>
	)
}

function CardDescription({ className, ...props }: React.ComponentProps<"div">) {
	return (
		<div
			data-slot="card-description"
			className={cn("text-sm text-muted-foreground", className)}
			{...props}
		/>
	)
}

function CardAction({ className, ...props }: React.ComponentProps<"div">) {
	return (
		<div
			data-slot="card-action"
			className={cn(
				"col-start-2 row-span-2 row-start-1 self-start justify-self-end",
				className,
			)}
			{...props}
		/>
	)
}

function CardContent({ className, ...props }: React.ComponentProps<"div">) {
	return (
		<div
			data-slot="card-content"
			className={cn("px-6", className)}
			{...props}
		/>
	)
}

function CardFooter({ className, ...props }: React.ComponentProps<"div">) {
	return (
		<div
			data-slot="card-footer"
			className={cn("flex items-center px-6 [.border-t]:pt-6", className)}
			{...props}
		/>
	)
}

export {
	Card,
	CardHeader,
	CardFooter,
	CardTitle,
	CardAction,
	CardDescription,
	CardContent,
}
