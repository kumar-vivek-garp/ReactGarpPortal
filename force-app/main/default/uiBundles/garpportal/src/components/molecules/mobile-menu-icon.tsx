import { animated, to, useSpring } from "@react-spring/web"

import { NAV_PANEL_SPRING } from "@/lib/nav-spring"

const BAR = "absolute top-1/2 left-1/2 -mt-px block h-0.5 w-6 rounded-full bg-current"

/**
 * Hamburger ⇄ close, morphed rather than swapped.
 *
 * Cross-fading two Lucide glyphs pops, because the two icons never share a
 * shape. Three bars that spring into an X read as one continuous object — and
 * this is the most-tapped control on mobile, so it is worth the extra spans.
 */
function MobileMenuIcon({ open }: { open: boolean }) {
	const top = useSpring({ y: open ? 0 : -6, rotate: open ? 45 : 0, config: NAV_PANEL_SPRING })
	const middle = useSpring({ opacity: open ? 0 : 1, scale: open ? 0.3 : 1, config: NAV_PANEL_SPRING })
	const bottom = useSpring({ y: open ? 0 : 6, rotate: open ? -45 : 0, config: NAV_PANEL_SPRING })

	return (
		<span className="relative block size-6" aria-hidden="true">
			<animated.span
				className={BAR}
				style={{
					transform: to(
						[top.y, top.rotate],
						(y, rotate) => `translateX(-50%) translateY(${y}px) rotate(${rotate}deg)`,
					),
				}}
			/>
			<animated.span
				className={BAR}
				style={{
					opacity: middle.opacity,
					transform: middle.scale.to((scale) => `translateX(-50%) scaleX(${scale})`),
				}}
			/>
			<animated.span
				className={BAR}
				style={{
					transform: to(
						[bottom.y, bottom.rotate],
						(y, rotate) => `translateX(-50%) translateY(${y}px) rotate(${rotate}deg)`,
					),
				}}
			/>
		</span>
	)
}

export { MobileMenuIcon }
