import { animated } from "@react-spring/web"
import type { LucideIcon } from "lucide-react"

import { TabsList, TabsTrigger } from "@/components/atoms/tabs"
import { useSlidingIndicator } from "@/hooks/use-sliding-indicator"
import { useSpringPress } from "@/hooks/use-spring-press"
import { cn } from "@/lib/utils"

export type PillTabItem<T extends string = string> = {
	value: T
	label: string
	icon?: LucideIcon
	/** Rendered as a dimmed suffix, e.g. "In Progress (2)". */
	count?: number
}

type PillTabsProps<T extends string> = {
	items: ReadonlyArray<PillTabItem<T>>
	/**
	 * Active value. Radix does not expose it to descendants, so pass it through —
	 * the indicator needs it to measure. Empty string means "nothing active",
	 * which the pending shells use while data loads.
	 */
	value: T | ""
	className?: string
	/** Extra classes for every trigger. */
	triggerClassName?: string
}

function PillTabTrigger({
	item,
	registerRef,
	className,
}: {
	item: PillTabItem
	registerRef: (value: string, node: HTMLButtonElement | null) => void
	className?: string
}) {
	const { bind, style } = useSpringPress<HTMLButtonElement>()
	const Icon = item.icon

	return (
		<TabsTrigger
			ref={(node) => registerRef(item.value, node)}
			value={item.value}
			// z-10 keeps the label above the sliding indicator; the active
			// background is transparent because the indicator supplies the colour.
			className={cn(
				"relative z-10 h-auto flex-none shrink-0 cursor-pointer gap-1.5 rounded-lg border-0 px-4 py-2 text-sm font-semibold shadow-none",
				"text-foreground/70 hover:text-foreground",
				"data-[state=active]:bg-transparent data-[state=active]:text-primary-foreground",
				"dark:data-[state=active]:border-transparent dark:data-[state=active]:bg-transparent dark:data-[state=active]:text-primary-foreground",
				"after:hidden",
				className,
			)}
			{...bind}
		>
			<animated.span
				className="inline-flex items-center gap-1.5 will-change-transform"
				style={{ scale: style.scale }}
			>
				{Icon ? <Icon className="size-4 shrink-0" aria-hidden /> : null}
				{item.label}
				{item.count !== undefined ? (
					<span className="font-normal text-inherit opacity-80">
						({item.count})
					</span>
				) : null}
			</animated.span>
		</TabsTrigger>
	)
}

/**
 * Segmented pill tab bar with a spring-driven active indicator.
 *
 * Replaces the `TabsList` + `TabsTrigger` + `pillTabTriggerClassName` block that
 * was duplicated across every panel and pending shell, so tab motion is defined
 * once. Render it inside the caller's `<Tabs value onValueChange>` — Radix
 * context still lives there.
 */
function PillTabs<T extends string>({
	items,
	value,
	className,
	triggerClassName,
}: PillTabsProps<T>) {
	const { containerRef, registerRef, indicatorStyle } =
		useSlidingIndicator<HTMLDivElement>({
			axis: "x",
			value,
			itemsKey: items.map((item) => item.value).join("|"),
			scrollActiveIntoView: true,
		})

	return (
		<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
			<TabsList
				ref={containerRef}
				className={cn(
					"relative h-auto w-max gap-1 rounded-xl bg-muted p-1",
					className,
				)}
			>
				<animated.span
					// Inner radius: 8px track - 4px padding = 4px (`rounded-lg`).
					className="pointer-events-none absolute inset-y-1 left-0 rounded-lg bg-primary will-change-transform"
					style={indicatorStyle}
					aria-hidden
				/>
				{items.map((item) => (
					<PillTabTrigger
						key={item.value}
						item={item}
						registerRef={registerRef}
						className={triggerClassName}
					/>
				))}
			</TabsList>
		</div>
	)
}

export { PillTabs }
