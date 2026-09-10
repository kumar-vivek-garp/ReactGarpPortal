import { PillTabs } from "@/components/atoms/pill-tabs"
import {
	HELP_CENTER_TAB_ITEMS,
	type HelpCenterTab,
} from "@/config/help-center"
import { PAGE_SHELL, PAGE_STICKY_HEADER } from "@/components/molecules/page-shell"
import { cn } from "@/lib/utils"

// Lives apart from help-center-panel.tsx on purpose: the route pending
// skeleton shares this chrome and is eager, and importing it from the panel
// file would drag the support-case form into the entry chunk.

/**
 * Full-height panel shell shared with the pending skeleton so the chrome
 * cannot drift — same shape as Programs / My Account / Events.
 */
const HELP_CENTER_SHELL =
	PAGE_SHELL
const HELP_CENTER_SCROLL =
	""
const GET_HELP_GRID =
	"grid items-start gap-8 lg:grid-cols-[minmax(0,7fr)_minmax(0,3fr)] lg:gap-10"

/** Fixed chrome above the scroll region — also rendered by the pending shell. */
function HelpCenterHeader({
	tab,
	requestCount,
}: {
	tab: HelpCenterTab
	requestCount?: number
}) {
	return (
		<header className={cn(PAGE_STICKY_HEADER, "space-y-4")}>
			<div>
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-heading">
					Help Center
				</h1>
				<p className="mt-1 max-w-2xl text-sm text-muted-foreground">
					{/*
					 * No longer offers "other contact options": the links that were
					 * those opened the same case this page's own form submits, and
					 * went with the Contact Member Services section (UI/UX request,
					 * Sep 2026).
					 */}
					Open a support case with Member Services, track requests you have
					already raised, or browse the FAQs.
				</p>
			</div>

			<PillTabs
				items={HELP_CENTER_TAB_ITEMS.map((item) =>
					item.value === "requests" && requestCount !== undefined
						? { ...item, count: requestCount }
						: item,
				)}
				value={tab}
			/>
		</header>
	)
}

export {
	GET_HELP_GRID,
	HELP_CENTER_SCROLL,
	HELP_CENTER_SHELL,
	HelpCenterHeader,
}
