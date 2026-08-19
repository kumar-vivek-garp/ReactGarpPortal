"use client"

import * as React from "react"
import { animated, useTransition } from "@react-spring/web"
import { XIcon } from "lucide-react"
import { Dialog as DialogPrimitive } from "radix-ui"

import { cn } from "@/lib/utils"
import { Button } from "@/components/atoms/button"

const DialogOpenContext = React.createContext(false)

/** Quiet, slightly heavy — no bounce, reads as a professional overlay. */
const DIALOG_SPRING = { mass: 0.85, tension: 340, friction: 30 } as const

const overlayClassName =
  "fixed inset-0 z-50 bg-overlay supports-backdrop-filter:backdrop-blur-xs"

function Dialog({
  open: openProp,
  defaultOpen = false,
  onOpenChange,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Root>) {
  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen)
  const open = openProp ?? uncontrolledOpen

  return (
    <DialogOpenContext.Provider value={open}>
      <DialogPrimitive.Root
        data-slot="dialog"
        {...props}
        open={open}
        onOpenChange={(next) => {
          if (openProp === undefined) setUncontrolledOpen(next)
          onOpenChange?.(next)
        }}
      />
    </DialogOpenContext.Provider>
  )
}

function DialogTrigger({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Trigger>) {
  return <DialogPrimitive.Trigger data-slot="dialog-trigger" {...props} />
}

function DialogPortal({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Portal>) {
  return <DialogPrimitive.Portal data-slot="dialog-portal" {...props} />
}

function DialogClose({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Close>) {
  return <DialogPrimitive.Close data-slot="dialog-close" {...props} />
}

function DialogOverlay({
  className,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Overlay>) {
  return (
    <DialogPrimitive.Overlay
      data-slot="dialog-overlay"
      className={cn(overlayClassName, className)}
      {...props}
    />
  )
}

function DialogContent({
  className,
  children,
  showCloseButton = true,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Content> & {
  showCloseButton?: boolean
}) {
  const open = React.useContext(DialogOpenContext)
  const transitions = useTransition(open, {
    from: { overlayOpacity: 0, opacity: 0, scale: 0.97 },
    enter: { overlayOpacity: 1, opacity: 1, scale: 1 },
    leave: { overlayOpacity: 0, opacity: 0, scale: 0.985 },
    config: DIALOG_SPRING,
  })

  return transitions((spring, show) =>
    show ? (
      <DialogPortal forceMount data-slot="dialog-portal">
        <DialogPrimitive.Overlay asChild forceMount>
          <animated.div
            data-slot="dialog-overlay"
            className={overlayClassName}
            style={{ opacity: spring.overlayOpacity }}
          />
        </DialogPrimitive.Overlay>
        <DialogPrimitive.Content asChild forceMount {...props}>
          <animated.div
            data-slot="dialog-content"
            className={cn(
              "fixed top-1/2 left-1/2 z-50 grid w-full max-w-[calc(100%-2rem)] origin-center gap-4 overflow-hidden rounded-2xl border bg-background p-6 shadow-lg outline-none will-change-transform sm:max-w-lg",
              className
            )}
            style={{
              opacity: spring.opacity,
              transform: spring.scale.to(
                (scale) => `translate(-50%, -50%) scale(${scale})`
              ),
            }}
          >
            {children}
            {showCloseButton ? (
              <DialogPrimitive.Close
                data-slot="dialog-close"
                className="absolute top-4 right-4 rounded-xs opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:ring-2 focus:ring-ring focus:ring-offset-2 focus:outline-hidden disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
              >
                <XIcon />
                <span className="sr-only">Close</span>
              </DialogPrimitive.Close>
            ) : null}
          </animated.div>
        </DialogPrimitive.Content>
      </DialogPortal>
    ) : null
  )
}

function DialogHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dialog-header"
      className={cn("flex flex-col gap-2 text-center sm:text-left", className)}
      {...props}
    />
  )
}

function DialogFooter({
  className,
  showCloseButton = false,
  children,
  ...props
}: React.ComponentProps<"div"> & {
  showCloseButton?: boolean
}) {
  return (
    <div
      data-slot="dialog-footer"
      className={cn(
        "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end",
        className
      )}
      {...props}
    >
      {children}
      {showCloseButton && (
        <DialogPrimitive.Close asChild>
          <Button variant="outline">Close</Button>
        </DialogPrimitive.Close>
      )}
    </div>
  )
}

function DialogTitle({
  className,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Title>) {
  return (
    <DialogPrimitive.Title
      data-slot="dialog-title"
      className={cn("text-lg leading-none font-semibold", className)}
      {...props}
    />
  )
}

function DialogDescription({
  className,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Description>) {
  return (
    <DialogPrimitive.Description
      data-slot="dialog-description"
      className={cn("text-sm text-muted-foreground", className)}
      {...props}
    />
  )
}

export {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogOverlay,
  DialogPortal,
  DialogTitle,
  DialogTrigger,
}
