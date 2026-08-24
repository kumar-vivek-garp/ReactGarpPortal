"use client"

import * as React from "react"
import { animated, to, useSpring } from "@react-spring/web"
import { CheckIcon, ChevronRightIcon, CircleIcon } from "lucide-react"
import { DropdownMenu as DropdownMenuPrimitive } from "radix-ui"

import { cn } from "@/lib/utils"

/** Snappy spring — matches Select panel motion. */
const DROPDOWN_SPRING = { mass: 0.9, tension: 320, friction: 26 } as const

const DropdownOpenContext = React.createContext(false)

const dropdownItemClassName =
  "relative flex cursor-default items-center gap-2 rounded-lg text-sm outline-hidden select-none focus:bg-input/30 data-[highlighted]:bg-input/30 data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground dark:focus:bg-input/50 dark:data-[highlighted]:bg-input/50"

function DropdownMenu({
  open: openProp,
  defaultOpen,
  onOpenChange,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Root>) {
  const [mirroredOpen, setMirroredOpen] = React.useState(defaultOpen ?? false)
  const open = openProp ?? mirroredOpen

  return (
    <DropdownOpenContext.Provider value={open}>
      <DropdownMenuPrimitive.Root
        data-slot="dropdown-menu"
        {...props}
        {...(openProp !== undefined ? { open: openProp } : {})}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => {
          if (openProp === undefined) setMirroredOpen(next)
          onOpenChange?.(next)
        }}
      />
    </DropdownOpenContext.Provider>
  )
}

function DropdownMenuPortal({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Portal>) {
  return (
    <DropdownMenuPrimitive.Portal data-slot="dropdown-menu-portal" {...props} />
  )
}

function DropdownMenuTrigger({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Trigger>) {
  return (
    <DropdownMenuPrimitive.Trigger
      data-slot="dropdown-menu-trigger"
      {...props}
    />
  )
}

/** One animated surface — border, fill, shadow, and items move together. */
function DropdownAnimatedPanel({
  className,
  children,
  groupName,
}: {
  className?: string
  children: React.ReactNode
  groupName: "dropdown-content" | "dropdown-sub-content"
}) {
  const styles = useSpring({
    from: { opacity: 0, y: -4, scale: 0.98 },
    to: { opacity: 1, y: 0, scale: 1 },
    config: DROPDOWN_SPRING,
  })

  return (
    <animated.div
      data-slot="dropdown-menu-panel"
      style={{
        opacity: styles.opacity,
        transform: to(
          [styles.y, styles.scale],
          (y, scale) => `translateY(${y}px) scale(${scale})`
        ),
      }}
      className={cn(
        "origin-top overflow-x-hidden overflow-y-auto rounded-xl border border-input bg-popover p-1 text-popover-foreground shadow-md [scrollbar-width:thin] will-change-transform",
        groupName === "dropdown-sub-content" &&
          "group-data-[side=right]/dropdown-sub-content:origin-left group-data-[side=left]/dropdown-sub-content:origin-right",
        className
      )}
    >
      {children}
    </animated.div>
  )
}

function DropdownMenuContent({
  className,
  children,
  sideOffset = 4,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Content>) {
  return (
    <DropdownMenuPrimitive.Portal>
      <DropdownMenuPrimitive.Content
        data-slot="dropdown-menu-content"
        sideOffset={sideOffset}
        className={cn(
          "group/dropdown-content z-50 min-w-[8rem] overflow-visible border-0 bg-transparent p-0 shadow-none outline-none",
          className
        )}
        {...props}
      >
        <DropdownAnimatedPanel
          groupName="dropdown-content"
          className="max-h-(--radix-dropdown-menu-content-available-height)"
        >
          {children}
        </DropdownAnimatedPanel>
      </DropdownMenuPrimitive.Content>
    </DropdownMenuPrimitive.Portal>
  )
}

function DropdownMenuGroup({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Group>) {
  return (
    <DropdownMenuPrimitive.Group data-slot="dropdown-menu-group" {...props} />
  )
}

function DropdownMenuItem({
  className,
  inset,
  variant = "default",
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Item> & {
  inset?: boolean
  variant?: "default" | "destructive"
}) {
  return (
    <DropdownMenuPrimitive.Item
      data-slot="dropdown-menu-item"
      data-inset={inset}
      data-variant={variant}
      className={cn(
        dropdownItemClassName,
        "px-2 py-1.5",
        "data-[inset]:pl-8 data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:data-[highlighted]:bg-destructive/10 data-[variant=destructive]:data-[highlighted]:text-destructive dark:data-[variant=destructive]:focus:bg-destructive/20 dark:data-[variant=destructive]:data-[highlighted]:bg-destructive/20 data-[variant=destructive]:*:[svg]:text-destructive!",
        className
      )}
      {...props}
    />
  )
}

function DropdownMenuCheckboxItem({
  className,
  children,
  checked,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.CheckboxItem>) {
  return (
    <DropdownMenuPrimitive.CheckboxItem
      data-slot="dropdown-menu-checkbox-item"
      className={cn(
        dropdownItemClassName,
        "py-1.5 pr-2 pl-8 data-[state=checked]:bg-input/30 dark:data-[state=checked]:bg-input/50",
        className
      )}
      checked={checked}
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <DropdownMenuPrimitive.ItemIndicator>
          <CheckIcon className="size-4" />
        </DropdownMenuPrimitive.ItemIndicator>
      </span>
      {children}
    </DropdownMenuPrimitive.CheckboxItem>
  )
}

function DropdownMenuRadioGroup({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.RadioGroup>) {
  return (
    <DropdownMenuPrimitive.RadioGroup
      data-slot="dropdown-menu-radio-group"
      {...props}
    />
  )
}

function DropdownMenuRadioItem({
  className,
  children,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.RadioItem>) {
  return (
    <DropdownMenuPrimitive.RadioItem
      data-slot="dropdown-menu-radio-item"
      className={cn(
        dropdownItemClassName,
        "py-1.5 pr-2 pl-8 data-[state=checked]:bg-input/30 dark:data-[state=checked]:bg-input/50",
        className
      )}
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <DropdownMenuPrimitive.ItemIndicator>
          <CircleIcon className="size-2 fill-current" />
        </DropdownMenuPrimitive.ItemIndicator>
      </span>
      {children}
    </DropdownMenuPrimitive.RadioItem>
  )
}

function DropdownMenuLabel({
  className,
  inset,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Label> & {
  inset?: boolean
}) {
  return (
    <DropdownMenuPrimitive.Label
      data-slot="dropdown-menu-label"
      data-inset={inset}
      className={cn(
        "px-2 py-1.5 text-sm font-medium data-[inset]:pl-8",
        className
      )}
      {...props}
    />
  )
}

function DropdownMenuSeparator({
  className,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Separator>) {
  return (
    <DropdownMenuPrimitive.Separator
      data-slot="dropdown-menu-separator"
      className={cn("-mx-1 my-1 h-px bg-border", className)}
      {...props}
    />
  )
}

function DropdownMenuShortcut({
  className,
  ...props
}: React.ComponentProps<"span">) {
  return (
    <span
      data-slot="dropdown-menu-shortcut"
      className={cn(
        "ml-auto text-xs tracking-widest text-muted-foreground",
        className
      )}
      {...props}
    />
  )
}

function DropdownMenuSub({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Sub>) {
  return <DropdownMenuPrimitive.Sub data-slot="dropdown-menu-sub" {...props} />
}

function DropdownMenuSubTrigger({
  className,
  inset,
  children,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.SubTrigger> & {
  inset?: boolean
}) {
  return (
    <DropdownMenuPrimitive.SubTrigger
      data-slot="dropdown-menu-sub-trigger"
      data-inset={inset}
      className={cn(
        dropdownItemClassName,
        "px-2 py-1.5",
        "data-[inset]:pl-8 data-[state=open]:bg-input/30 dark:data-[state=open]:bg-input/50",
        className
      )}
      {...props}
    >
      {children}
      <ChevronRightIcon className="ml-auto size-4" />
    </DropdownMenuPrimitive.SubTrigger>
  )
}

function DropdownMenuSubContent({
  className,
  children,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.SubContent>) {
  return (
    <DropdownMenuPrimitive.SubContent
      data-slot="dropdown-menu-sub-content"
      className={cn(
        "group/dropdown-sub-content z-50 min-w-[8rem] overflow-visible border-0 bg-transparent p-0 shadow-none outline-none",
        className
      )}
      {...props}
    >
      <DropdownAnimatedPanel groupName="dropdown-sub-content">
        {children}
      </DropdownAnimatedPanel>
    </DropdownMenuPrimitive.SubContent>
  )
}

export {
  DropdownMenu,
  DropdownMenuPortal,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuLabel,
  DropdownMenuItem,
  DropdownMenuCheckboxItem,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuSub,
  DropdownMenuSubTrigger,
  DropdownMenuSubContent,
}
