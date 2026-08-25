"use client"

import * as React from "react"
import { animated, to, useSpring } from "@react-spring/web"
import { Tooltip as TooltipPrimitive } from "radix-ui"

import { cn } from "@/lib/utils"

/** Slightly stiffer than the dropdown — a tooltip should arrive, not unfold. */
const TOOLTIP_SPRING = { mass: 0.7, tension: 380, friction: 26 } as const

/**
 * How long the pointer must rest before a tooltip appears.
 *
 * Radix defaults to 700ms, which is long enough that a member reading a
 * collapsed rail gives up before the label arrives. 0 is worse in the other
 * direction: tooltips fire while the pointer is merely crossing the rail on its
 * way somewhere else. This is the deliberate-hover threshold — long enough to
 * read as intent, short enough not to feel like waiting.
 */
const TOOLTIP_DELAY_MS = 450

/**
 * Once one tooltip has been shown, how long the group stays "warm".
 *
 * Radix's default, kept deliberately: moving from one collapsed row to the next
 * within this window shows the next label immediately, so scanning down the
 * rail costs the delay once rather than once per row.
 */
const TOOLTIP_SKIP_DELAY_MS = 300

function TooltipProvider({
  delayDuration = TOOLTIP_DELAY_MS,
  skipDelayDuration = TOOLTIP_SKIP_DELAY_MS,
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Provider>) {
  return (
    <TooltipPrimitive.Provider
      data-slot="tooltip-provider"
      delayDuration={delayDuration}
      skipDelayDuration={skipDelayDuration}
      {...props}
    />
  )
}

function Tooltip({
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Root>) {
  return <TooltipPrimitive.Root data-slot="tooltip" {...props} />
}

function TooltipTrigger({
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Trigger>) {
  return <TooltipPrimitive.Trigger data-slot="tooltip-trigger" {...props} />
}

/**
 * One animated surface — fill, text, and arrow grow together.
 *
 * Same split as `DropdownAnimatedPanel`: Radix's `Content` stays a transparent
 * positioning shell and this carries the paint, so the spring is never fighting
 * the transform Radix writes onto the positioned element.
 *
 * The arrow lives *inside* this div rather than beside it, which is what makes
 * it animate with the panel instead of popping in at full size next to a
 * growing box. It still lands correctly because `Content` carries no padding —
 * the panel is the same box Radix measured — and `relative` here gives the
 * arrow's absolute positioning that box to resolve against.
 *
 * Scaling from the side the tooltip opened on (`origin-(--radix-…)`, set on
 * `Content`) is what sells it as growing *out of* the trigger; scaling from the
 * centre would read as a card fading in nearby.
 */
function TooltipAnimatedPanel({
  className,
  children,
}: {
  className?: string
  children: React.ReactNode
}) {
  const styles = useSpring({
    from: { opacity: 0, scale: 0.9 },
    to: { opacity: 1, scale: 1 },
    config: TOOLTIP_SPRING,
  })

  return (
    <animated.div
      data-slot="tooltip-panel"
      style={{
        opacity: styles.opacity,
        transform: to(styles.scale, (scale) => `scale(${scale})`),
      }}
      className={cn(
        "relative w-fit rounded-lg bg-foreground px-3 py-1.5 text-xs text-balance text-background shadow-md will-change-transform",
        className
      )}
    >
      {children}
      {/*
       * Radix rotates this per side, so one declaration serves top/right/
       * bottom/left, and it keeps pointing at the trigger's centre even when a
       * collision shifts the panel along its edge — which a hand-placed CSS
       * diamond centred on the panel would get wrong.
       */}
      <TooltipPrimitive.Arrow
        width={11}
        height={5}
        className="fill-foreground"
      />
    </animated.div>
  )
}

function TooltipContent({
  className,
  sideOffset = 6,
  children,
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Content>) {
  return (
    <TooltipPrimitive.Portal>
      <TooltipPrimitive.Content
        data-slot="tooltip-content"
        sideOffset={sideOffset}
        className="z-50 origin-(--radix-tooltip-content-transform-origin) border-0 bg-transparent p-0 shadow-none outline-none"
        {...props}
      >
        <TooltipAnimatedPanel className={className}>
          {children}
        </TooltipAnimatedPanel>
      </TooltipPrimitive.Content>
    </TooltipPrimitive.Portal>
  )
}

export { Tooltip, TooltipTrigger, TooltipContent, TooltipProvider }
