import { getRouteApi } from "@tanstack/react-router"

import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { OrderHistorySkeleton } from "@/components/molecules/page-pending/order-history-skeleton"
import { ProfileCompletenessMeterSkeleton } from "@/components/molecules/profile-completeness-meter"
import { AccountInformationSkeleton } from "@/components/organisms/account-information-panel"
import { ContactPreferencesSkeleton } from "@/components/organisms/contact-preferences-panel"
import type { MyAccountTab } from "@/config/my-account"
import { DEFAULT_MY_ACCOUNT_TAB, MY_ACCOUNT_TAB_ITEMS } from "@/config/my-account"

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
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					My Account
				</h1>
				<div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between sm:gap-6">
					<div className="w-full max-w-md sm:min-w-0 sm:flex-1">
						<ProfileCompletenessMeterSkeleton />
					</div>
					<PillTabs items={MY_ACCOUNT_TAB_ITEMS} value={tab} />
				</div>
			</header>
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
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
