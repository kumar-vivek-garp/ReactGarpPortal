import { useEffect, useState } from "react"
import { animated, useSpring } from "@react-spring/web"
import { ArrowUp } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { usePrefersReducedMotion } from "@/hooks/use-prefers-reduced-motion"
import { getAppScroller } from "@/lib/app-scroll"

const SHOW_AFTER_PX = 280
const RING_R = 10
const RING_C = 2 * Math.PI * RING_R
const SHELL_SPRING = { mass: 0.9, tension: 320, friction: 26 }
const PROGRESS_SPRING = { mass: 0.8, tension: 280, friction: 26 }
const SCROLL_SPRING = { mass: 1, tension: 170, friction: 28, clamp: true }

/*
 * The shell's main column scrolls, not the document — and this button lives at
 * the bottom of that same column, so it reads and drives the element it is
 * inside of. Falling back to the document keeps it honest if it is ever
 * rendered outside a shell.
 */
function scrollTarget() {
	return getAppScroller() ?? document.documentElement
}

function pageScrollProgress(el: HTMLElement) {
	const max = el.scrollHeight - el.clientHeight
	if (max <= 0) return 0
	return Math.min(1, Math.max(0, el.scrollTop / max))
}

function FooterBackToTop() {
	const reduceMotion = usePrefersReducedMotion()
	const [visible, setVisible] = useState(false)
	const [progress, setProgress] = useState(0)

	useEffect(() => {
		const el = scrollTarget()
		const onScroll = () => {
			setVisible(el.scrollTop > SHOW_AFTER_PX)
			setProgress(pageScrollProgress(el))
		}
		onScroll()
		el.addEventListener("scroll", onScroll, { passive: true })
		return () => el.removeEventListener("scroll", onScroll)
	}, [])

	const shell = useSpring({
		opacity: visible ? 1 : 0,
		y: visible ? 0 : 20,
		config: SHELL_SPRING,
		immediate: reduceMotion,
	})

	const ring = useSpring({
		p: progress,
		config: PROGRESS_SPRING,
		immediate: reduceMotion,
	})

	const [, scrollApi] = useSpring(() => ({
		y: 0,
		config: SCROLL_SPRING,
	}))

	useEffect(() => {
		const interrupt = () => {
			scrollApi.stop()
		}
		window.addEventListener("wheel", interrupt, { passive: true })
		window.addEventListener("touchstart", interrupt, { passive: true })
		return () => {
			window.removeEventListener("wheel", interrupt)
			window.removeEventListener("touchstart", interrupt)
		}
	}, [scrollApi])

	function handleClick() {
		const el = scrollTarget()
		const from = el.scrollTop
		if (from <= 0) return
		if (reduceMotion) {
			el.scrollTop = 0
			return
		}
		void scrollApi.start({
			from: { y: from },
			to: { y: 0 },
			onChange: ({ value }) => {
				if (typeof value.y === "number") {
					el.scrollTop = value.y
				}
			},
		})
	}

	return (
		<animated.div
			className="fixed right-5 bottom-5 z-[900] sm:right-8 sm:bottom-8"
			style={{
				...shell,
				pointerEvents: visible ? "auto" : "none",
				paddingBottom: "env(safe-area-inset-bottom)",
			}}
			aria-hidden={!visible}
		>
			<Button
				type="button"
				size="sm"
				className="shadow-md"
				tabIndex={visible ? 0 : -1}
				onClick={handleClick}
			>
				<span className="relative inline-flex size-6 items-center justify-center">
					<svg
						viewBox="0 0 24 24"
						className="absolute inset-0 size-6 -rotate-90"
						aria-hidden
					>
						<circle
							cx="12"
							cy="12"
							r={RING_R}
							fill="none"
							stroke="currentColor"
							strokeOpacity="0.28"
							strokeWidth="1.75"
						/>
						<animated.circle
							cx="12"
							cy="12"
							r={RING_R}
							fill="none"
							stroke="currentColor"
							strokeWidth="1.75"
							strokeLinecap="round"
							strokeDasharray={RING_C}
							strokeDashoffset={ring.p.to((p) => RING_C * (1 - p))}
						/>
					</svg>
					<ArrowUp className="size-3.5" />
				</span>
				Back to top
			</Button>
		</animated.div>
	)
}

export { FooterBackToTop }
