import { animated, useSpring } from "@react-spring/web"
import { Link } from "@tanstack/react-router"
import { Monitor } from "lucide-react"

import { examResultsRouteSlug } from "@/lib/exam-results-presentation"
import { programResultsPath } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

/** Quick and slightly springy — it arrives after the card, so it should read as arriving. */
const CHIP_SPRING = { mass: 0.7, tension: 380, friction: 22 }

type ProgramResultsChipProps = {
	programType: string
	className?: string
}

/**
 * "Results" chip in a programme card's badge row.
 *
 * The listing used to carry a full exam-results card, which previewed rows the
 * member was going to leave the page to read anyway. This is the entry point
 * without the preview: it costs no page height, it sits on the programme it
 * belongs to, and it needs no rule about which tabs may show it — it appears
 * wherever its card appears.
 *
 * It mounts only once the results query resolves, so the spring doubles as the
 * signal that something arrived rather than being decoration on a static page.
 */
function ProgramResultsChip({ programType, className }: ProgramResultsChipProps) {
	const enter = useSpring({
		from: { opacity: 0, scale: 0.8 },
		to: { opacity: 1, scale: 1 },
		config: CHIP_SPRING,
	})

	const slug = examResultsRouteSlug(programType)
	// Belt and braces: the caller already filtered on the same rule.
	if (!slug || !programResultsPath(programType)) return null

	return (
		<animated.span className="inline-flex" style={enter}>
			<Link
				to="/programs/$programType/results"
				params={{ programType: slug }}
				aria-label={`View exam results for ${programType}`}
				className={cn(
					"inline-flex items-center gap-1.5 rounded-md border border-primary/30 bg-primary/10 px-2 py-0.5",
					"text-xs font-bold tracking-wide text-primary",
					"hover:bg-primary hover:text-primary-foreground",
					className,
				)}
			>
				<Monitor className="size-3.5 shrink-0" aria-hidden />
				Results
			</Link>
		</animated.span>
	)
}

export { ProgramResultsChip }
