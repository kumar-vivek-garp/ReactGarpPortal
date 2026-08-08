import { useLayoutEffect, useRef, useState } from "react"
import { animated, useSpring, useTransition } from "@react-spring/web"
import { ChevronDown } from "lucide-react"

import { MegaMenuPanel } from "@/components/molecules/mega-menu-panel"
import type { TopNavItem } from "@/config/navigation/types"
import { cn } from "@/lib/utils"
import { useNavigationStore } from "@/store/navigation-store"

/** Snappy spring — slight physics feel without a long bounce. */
const PANEL_SPRING = { mass: 0.9, tension: 320, friction: 26 }

function NavMegaMenuItem({ item }: { item: TopNavItem }) {
	const openDesktopNavTitle = useNavigationStore((state) => state.openDesktopNavTitle)
	const openDesktopNav = useNavigationStore((state) => state.openDesktopNav)
	const scheduleCloseDesktopNav = useNavigationStore((state) => state.scheduleCloseDesktopNav)
	const cancelCloseDesktopNav = useNavigationStore((state) => state.cancelCloseDesktopNav)

	const isActive = openDesktopNavTitle === item.title
	const triggerRef = useRef<HTMLButtonElement>(null)
	const [left, setLeft] = useState(20)
	/** Distance from panel's left edge to the caret tip — live uses `--arrow-left`. */
	const [arrowLeft, setArrowLeft] = useState(80)

	const panelTransitions = useTransition(isActive, {
		from: { opacity: 0, transform: "translateY(-8px) scale(0.96)" },
		enter: { opacity: 1, transform: "translateY(0px) scale(1)" },
		leave: { opacity: 0, transform: "translateY(-6px) scale(0.98)" },
		config: PANEL_SPRING,
	})

	const chevronSpring = useSpring({
		rotate: isActive ? 180 : 0,
		config: PANEL_SPRING,
	})

	useLayoutEffect(() => {
		if (!isActive || !triggerRef.current) return
		const rect = triggerRef.current.getBoundingClientRect()
		const buttonCenter = rect.left + rect.width / 2
		const dropdownWidth = item.column3 ? 960 : 720
		const preferredArrowOffset = 80
		const idealLeft = buttonCenter - preferredArrowOffset
		const maxLeft = window.innerWidth - dropdownWidth - 20
		const nextLeft = Math.max(20, Math.min(idealLeft, maxLeft))
		setLeft(nextLeft)
		setArrowLeft(Math.max(20, buttonCenter - nextLeft))
	}, [isActive, item.column3])

	function keepOpen() {
		cancelCloseDesktopNav()
		openDesktopNav(item.title)
	}

	return (
		<div
			className="relative shrink-0"
			onMouseEnter={keepOpen}
			onMouseLeave={scheduleCloseDesktopNav}
		>
			<button
				ref={triggerRef}
				type="button"
				aria-expanded={isActive}
				aria-haspopup="true"
				className={cn(
					// Padding matches live `.dropdown-container button` (extra right space = gap between items).
					"inline-flex cursor-pointer items-center gap-0.5 whitespace-nowrap rounded-[10px] border-none bg-transparent py-2.5 pl-2.5 pr-[30px] text-nav font-bold leading-none text-inherit transition-[font-size,padding,background-color] duration-300 hover:bg-[#1e1e1e]",
					"max-[1200px]:py-2.5 max-[1200px]:pl-2 max-[1200px]:pr-5 max-[1200px]:text-body",
					"max-[1100px]:pl-1.5 max-[1100px]:pr-[15px] max-[1100px]:text-[13px]",
					"max-[1000px]:pl-[5px] max-[1000px]:pr-3 max-[1000px]:text-caption",
					isActive && "bg-[#1e1e1e]"
				)}
				onClick={keepOpen}
			>
				<span className="leading-none">{item.title}</span>
				<animated.span
					className={cn("inline-flex shrink-0", isActive && "text-primary")}
					style={{
						transform: chevronSpring.rotate.to((rotate) => `rotate(${rotate}deg)`),
					}}
				>
					<ChevronDown className="size-6" strokeWidth={2.5} aria-hidden="true" />
				</animated.span>
			</button>

			{panelTransitions((style, show) =>
				show ? (
					/*
					 * Wrapper starts at the toolbar bottom (top-20) so the cursor can travel
					 * through the gap into the panel without hitting the dim overlay.
					 */
					<div
						className="fixed top-20 z-[2000] pt-3"
						style={{ left }}
						onMouseEnter={keepOpen}
						onMouseLeave={scheduleCloseDesktopNav}
					>
						<animated.div
							className="relative w-fit min-w-[350px] max-w-[calc(100vw-40px)] origin-top cursor-default rounded-[10px] border border-surface-gradient-end bg-[#f5f5f5] p-2.5 shadow-[0px_8px_16px_0px_rgba(0,0,0,0.2)]"
							style={{
								...style,
								pointerEvents: isActive ? "auto" : "none",
							}}
						>
							{/* Caret tooltip — mirrors live `.dropdown::after` pointing at the trigger. */}
							<span
								aria-hidden="true"
								className="pointer-events-none absolute top-0 z-10 -translate-x-1/2 -translate-y-full"
								style={{ left: arrowLeft }}
							>
								<span className="block size-0 border-x-[10px] border-b-[10px] border-x-transparent border-b-[#f5f5f5]" />
							</span>
							<MegaMenuPanel item={item} variant="desktop" />
						</animated.div>
					</div>
				) : null
			)}
		</div>
	)
}

export { NavMegaMenuItem }
