import type { MegaMenuHeading } from "@/lib/navigation/types"

function MegaMenuHeadingText({ heading }: { heading: MegaMenuHeading }) {
	if (heading.highlightToken === "rai-split") {
		return (
			<>
				{heading.prefix}
				<span className="text-rai-orange">R</span>
				<span className="text-rai-blue">
					AI
					<sup>{heading.symbol}</sup>
				</span>
				{heading.suffix}
			</>
		)
	}

	const highlightClass =
		heading.highlightToken === "garp-cyan" ? "text-garp-cyan" : "text-garp-saffron"

	return (
		<>
			{heading.prefix}
			<span className={highlightClass}>
				{heading.highlight}
				<sup>{heading.symbol}</sup>
			</span>
			{heading.suffix}
		</>
	)
}

export { MegaMenuHeadingText }
