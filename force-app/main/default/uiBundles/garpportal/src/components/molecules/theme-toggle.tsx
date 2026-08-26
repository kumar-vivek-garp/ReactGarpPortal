import { animated, to, useSpring } from "@react-spring/web"
import { Moon, Sun } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { cn } from "@/lib/utils"
import { useThemeStore } from "@/store/theme-store"

const TOGGLE_SPRING = { mass: 0.85, tension: 340, friction: 22 }

type ThemeToggleProps = {
	className?: string
	/** Ghost on the toolbar surface; sheet when mobile panel uses light chrome. */
	variant?: "toolbar" | "sheet"
}

/**
 * Light/dark appearance toggle — physics crossfade via `@react-spring/web`.
 * Palette selection (blue/red/green) stays out of v1; use `setPalette` later.
 */
function ThemeToggle({ className, variant = "toolbar" }: ThemeToggleProps) {
	const toggleMode = useThemeStore((s) => s.toggleMode)
	const isDark = useThemeStore((s) => s.resolved === "dark")

	const sunSpring = useSpring({
		opacity: isDark ? 0 : 1,
		rotate: isDark ? -90 : 0,
		scale: isDark ? 0.4 : 1,
		config: TOGGLE_SPRING,
	})

	const moonSpring = useSpring({
		opacity: isDark ? 1 : 0,
		rotate: isDark ? 0 : 90,
		scale: isDark ? 1 : 0.4,
		config: TOGGLE_SPRING,
	})

	return (
		<Button
			type="button"
			variant="ghost"
			size="icon"
			aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}
			title={isDark ? "Light mode" : "Dark mode"}
			className={cn(
				"relative size-9 shrink-0 cursor-pointer overflow-hidden",
				variant === "toolbar" &&
					"text-toolbar-foreground hover:bg-toolbar-foreground/10 hover:text-toolbar-foreground",
				variant === "sheet" && "text-foreground hover:bg-accent",
				className,
			)}
			onClick={() => toggleMode()}
		>
			<animated.span
				className="absolute inset-0 flex items-center justify-center"
				style={{
					opacity: sunSpring.opacity,
					transform: to(
						[sunSpring.rotate, sunSpring.scale],
						(rotate, scale) => `rotate(${rotate}deg) scale(${scale})`,
					),
				}}
				aria-hidden="true"
			>
				<Sun className="size-5" strokeWidth={2.25} />
			</animated.span>
			<animated.span
				className="absolute inset-0 flex items-center justify-center"
				style={{
					opacity: moonSpring.opacity,
					transform: to(
						[moonSpring.rotate, moonSpring.scale],
						(rotate, scale) => `rotate(${rotate}deg) scale(${scale})`,
					),
				}}
				aria-hidden="true"
			>
				<Moon className="size-5" strokeWidth={2.25} />
			</animated.span>
		</Button>
	)
}

export { ThemeToggle }
