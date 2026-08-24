import { MobileBrowseTile } from "@/components/molecules/mobile-browse-tile"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { TOP_NAV_ITEMS } from "@/config/navigation/top-nav-items"
import type { TopNavItem } from "@/config/navigation/types"

/**
 * The mobile "Browse & Explore" surface. A tile grid rather than a list of rows,
 * so the six garp.org sections read as somewhere to go exploring — and so they
 * are visibly a different kind of thing from the account destinations above,
 * which are in-app routes.
 */
function MobileBrowseGrid({ onSelect }: { onSelect: (item: TopNavItem) => void }) {
	return (
		<StaggerReveal className="grid grid-cols-2 gap-3" itemClassName="h-full">
			{TOP_NAV_ITEMS.map((item) => (
				<MobileBrowseTile key={item.title} item={item} onSelect={() => onSelect(item)} />
			))}
		</StaggerReveal>
	)
}

export { MobileBrowseGrid }
