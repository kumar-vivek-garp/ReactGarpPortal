import { getRouteApi } from "@tanstack/react-router"

import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { OrderHistorySkeleton } from "@/components/molecules/page-pending/order-history-skeleton"
import { AccountInformationSkeleton } from "@/components/organisms/account-information-skeleton"
import { ContactPreferencesSkeleton } from "@/components/organisms/contact-preferences-skeleton"
import type { MyAccountTab } from "@/config/my-account"
import { DEFAULT_MY_ACCOUNT_TAB, MY_ACCOUNT_TAB_ITEMS } from "@/config/my-account"
import { PAGE_SHELL, PAGE_STICKY_HEADER } from "@/components/molecules/page-shell"

const routeApi = getRouteApi("/_appLayout/my-account/")

function TabBodySkeleton({ tab }: { tab: MyAccountTab }) {
	if (tab === "contact-preferences") return <ContactPreferencesSkeleton />
	if (tab === "order-history") return <OrderHistorySkeleton />
	return <AccountInformationSkeleton />
}

type MyAccountPendingProps = {
	tab?: MyAccountTab
}

function MyAccountPendingShell({
	tab = DEFAULT_MY_ACCOUNT_TAB,
}: MyAccountPendingProps) {
	return (
		<Tabs
			value={tab}
			className={PAGE_SHELL}
		>
			{/* Same single-row chrome as the loaded panel, so nothing shifts. */}
			<header className={PAGE_STICKY_HEADER}>
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-heading">
						My Account
					</h1>
					<PillTabs items={MY_ACCOUNT_TAB_ITEMS} value={tab} />
				</div>
			</header>
			<div>
				<div className="pb-2">
					<TabBodySkeleton tab={tab} />
				</div>
			</div>
		</Tabs>
	)
}

/** Route pending — reads destination `?tab=`. */
function MyAccountPending() {
	const { tab } = routeApi.useSearch()
	return <MyAccountPendingShell tab={tab} />
}

export { MyAccountPending, MyAccountPendingShell }
