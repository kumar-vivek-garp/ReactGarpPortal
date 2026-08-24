"use client"

import * as React from "react"
import { animated, to, useSpring } from "@react-spring/web"
import { CheckIcon, ChevronDownIcon, ChevronUpIcon } from "lucide-react"
import { Select as SelectPrimitive } from "radix-ui"

import { cn } from "@/lib/utils"

/** Snappy spring — slight physics feel without a long bounce. */
const SELECT_SPRING = { mass: 0.9, tension: 320, friction: 26 } as const

const SelectOpenContext = React.createContext(false)

function Select({
  open: openProp,
  defaultOpen,
  onOpenChange,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Root>) {
  const [mirroredOpen, setMirroredOpen] = React.useState(defaultOpen ?? false)
  const open = openProp ?? mirroredOpen

  return (
    <SelectOpenContext.Provider value={open}>
      <SelectPrimitive.Root
        data-slot="select"
        {...props}
        {...(openProp !== undefined ? { open: openProp } : {})}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => {
          if (openProp === undefined) setMirroredOpen(next)
          onOpenChange?.(next)
        }}
      />
    </SelectOpenContext.Provider>
  )
}

function SelectGroup({
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Group>) {
  return <SelectPrimitive.Group data-slot="select-group" {...props} />
}

function SelectValue({
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Value>) {
  return <SelectPrimitive.Value data-slot="select-value" {...props} />
}

function SelectTrigger({
  className,
  size = "default",
  children,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Trigger> & {
  size?: "sm" | "default"
}) {
  const open = React.useContext(SelectOpenContext)
  const chevronSpring = useSpring({
    rotate: open ? 180 : 0,
    config: SELECT_SPRING,
  })

  return (
    <SelectPrimitive.Trigger
      data-slot="select-trigger"
      data-size={size}
      className={cn(
        "relative z-10 flex w-fit items-center justify-between gap-2 rounded-xl border border-input bg-transparent px-3 py-2 text-sm whitespace-nowrap outline-none transition-[background-color,border-color,border-radius] hover:bg-input/30 focus-visible:border-primary disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive data-[placeholder]:text-muted-foreground data-[state=open]:rounded-b-none data-[state=open]:border-b-transparent data-[state=open]:bg-input/30 data-[size=default]:h-9 data-[size=sm]:h-8 *:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-2 dark:bg-input/30 dark:hover:bg-input/50 dark:data-[state=open]:bg-input/50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground",
        className
      )}
      {...props}
    >
      {children}
      <SelectPrimitive.Icon asChild>
        <animated.span
          className="inline-flex size-4 shrink-0 opacity-50"
          style={{
            transform: chevronSpring.rotate.to(
              (rotate) => `rotate(${rotate}deg)`
            ),
          }}
        >
          <ChevronDownIcon className="size-4" />
        </animated.span>
      </SelectPrimitive.Icon>
    </SelectPrimitive.Trigger>
  )
}

/**
 * One animated surface for border, fill, shadow, and options — avoids the
 * outer shell appearing before the list fades in.
 */
function SelectAnimatedPanel({
  className,
  children,
}: {
  className?: string
  children: React.ReactNode
}) {
  const styles = useSpring({
    from: { opacity: 0, y: -4, scale: 0.98 },
    to: { opacity: 1, y: 0, scale: 1 },
    config: SELECT_SPRING,
  })

  return (
    <animated.div
      data-slot="select-panel"
      style={{
        opacity: styles.opacity,
        transform: to(
          [styles.y, styles.scale],
          (y, scale) => `translateY(${y}px) scale(${scale})`
        ),
      }}
      className={cn(
        "origin-top overflow-x-hidden overflow-y-auto rounded-b-xl border border-input bg-popover text-popover-foreground shadow-md [scrollbar-width:thin] will-change-transform",
        "group-data-[side=bottom]/select-content:-mt-px group-data-[side=bottom]/select-content:rounded-t-none group-data-[side=bottom]/select-content:border-t-0",
        "group-data-[side=top]/select-content:-mb-px group-data-[side=top]/select-content:rounded-t-xl group-data-[side=top]/select-content:rounded-b-none group-data-[side=top]/select-content:border-b-0",
        className
      )}
    >
      {children}
    </animated.div>
  )
}

function SelectContent({
  className,
  children,
  position = "popper",
  align = "start",
  sideOffset = 0,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Content>) {
  const isPopper = position === "popper"

  return (
    <SelectPrimitive.Portal>
      <SelectPrimitive.Content
        data-slot="select-content"
        className={cn(
          "group/select-content relative z-50 min-w-[8rem] overflow-visible border-0 bg-transparent p-0 shadow-none outline-none",
          isPopper &&
            "w-[var(--radix-select-trigger-width)] min-w-[var(--radix-select-trigger-width)]",
          className
        )}
        position={position}
        align={align}
        sideOffset={sideOffset}
        {...props}
      >
        <SelectAnimatedPanel
          className={cn(
            "max-h-[min(15rem,var(--radix-select-content-available-height))]",
            isPopper && "w-full min-w-[var(--radix-select-trigger-width)]"
          )}
        >
          {!isPopper ? <SelectScrollUpButton /> : null}
          <SelectPrimitive.Viewport className="p-1">{children}</SelectPrimitive.Viewport>
          {!isPopper ? <SelectScrollDownButton /> : null}
        </SelectAnimatedPanel>
      </SelectPrimitive.Content>
    </SelectPrimitive.Portal>
  )
}

function SelectLabel({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Label>) {
  return (
    <SelectPrimitive.Label
      data-slot="select-label"
      className={cn("px-2 py-1.5 text-xs text-muted-foreground", className)}
      {...props}
    />
  )
}

function SelectItem({
  className,
  children,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Item>) {
  return (
    <SelectPrimitive.Item
      data-slot="select-item"
      className={cn(
        "relative flex w-full cursor-default items-center gap-2 rounded-lg py-1.5 pr-8 pl-2 text-sm outline-hidden select-none focus:bg-input/30 data-[highlighted]:bg-input/30 data-[state=checked]:bg-input/30 data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground *:[span]:last:flex *:[span]:last:items-center *:[span]:last:gap-2 dark:focus:bg-input/50 dark:data-[highlighted]:bg-input/50 dark:data-[state=checked]:bg-input/50",
        className
      )}
      {...props}
    >
      <span
        data-slot="select-item-indicator"
        className="absolute right-2 flex size-3.5 items-center justify-center"
      >
        <SelectPrimitive.ItemIndicator>
          <CheckIcon className="size-4" />
        </SelectPrimitive.ItemIndicator>
      </span>
      <SelectPrimitive.ItemText>{children}</SelectPrimitive.ItemText>
    </SelectPrimitive.Item>
  )
}

function SelectSeparator({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Separator>) {
  return (
    <SelectPrimitive.Separator
      data-slot="select-separator"
      className={cn("pointer-events-none -mx-1 my-1 h-px bg-border", className)}
      {...props}
    />
  )
}

function SelectScrollUpButton({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.ScrollUpButton>) {
  return (
    <SelectPrimitive.ScrollUpButton
      data-slot="select-scroll-up-button"
      className={cn(
        "flex cursor-default items-center justify-center py-1",
        className
      )}
      {...props}
    >
      <ChevronUpIcon className="size-4" />
    </SelectPrimitive.ScrollUpButton>
  )
}

function SelectScrollDownButton({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.ScrollDownButton>) {
  return (
    <SelectPrimitive.ScrollDownButton
      data-slot="select-scroll-down-button"
      className={cn(
        "flex cursor-default items-center justify-center py-1",
        className
      )}
      {...props}
    >
      <ChevronDownIcon className="size-4" />
    </SelectPrimitive.ScrollDownButton>
  )
}

export {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectScrollDownButton,
  SelectScrollUpButton,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
}
