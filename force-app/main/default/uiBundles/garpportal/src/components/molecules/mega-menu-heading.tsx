import type { MegaMenuHeading } from "@/config/navigation/types"

function MegaMenuHeadingText({ heading }: { heading: MegaMenuHeading }) {
	if (heading.highlightToken === "rai-split") {
		return (
			<>
				{heading.prefix}
				<span className="text-rai-orange">R</span>
				<span className="text-rai-blue">
					AI
					{heading.symbol ? <sup>{heading.symbol}</sup> : null}
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
				{heading.symbol ? <sup>{heading.symbol}</sup> : null}
			</span>
			{heading.suffix}
		</>
	)
}

export { MegaMenuHeadingText }
