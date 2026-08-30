import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"

import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import {
	AccountInformationError,
	AccountInformationPanel,
} from "@/components/organisms/account-information-panel"
import { AccountInformationSkeleton } from "@/components/organisms/account-information-skeleton"
import { ContactPreferencesPanel } from "@/components/organisms/contact-preferences-panel"
import { ContactPreferencesSkeleton } from "@/components/organisms/contact-preferences-skeleton"
import { OrderHistoryPanel } from "@/components/organisms/order-history-panel"
import { useAccount } from "@/hooks/use-account"
import { useCurrentUser } from "@/hooks/use-current-user"
import {
	AUTO_RENEW_SETUP_COMPLETE_STATUS,
	MY_ACCOUNT_TAB_ITEMS,
	type MyAccountTab,
} from "@/config/my-account"
import type { OrderFilter } from "@/config/order-history"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"

type MyAccountPanelProps = {
	tab: MyAccountTab
	status?: string
	/** Order History bucket filter, forwarded from `?orders=`. */
	orders?: OrderFilter
}

function MyAccountPanel({ tab, status, orders }: MyAccountPanelProps) {
	const navigate = useNavigate({ from: "/my-account/" })
	const { data: user } = useCurrentUser()
	/** REST: completeness + Account Information panel. */
	const accountQuery = useAccount()
	const contactId =
		user?.contactId?.trim() ||
		accountQuery.data?.identity.contactId?.trim() ||
		""

	const panelPending = tab === "account-information" && accountQuery.isPending
	const panelError =
		tab === "account-information" &&
		!panelPending &&
		(accountQuery.isError || !accountQuery.data)
	const panelAccount = accountQuery.data ?? null

	const prefsPending =
		tab === "contact-preferences" && !contactId && accountQuery.isPending
	const prefsMissingContact =
		tab === "contact-preferences" &&
		!prefsPending &&
		!contactId

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: (prev) => ({
						...prev,
						tab: value as MyAccountTab,
					}),
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			{/* Fixed chrome: heading + tabs — does not scroll. Completeness now
			    lives in the Account Information hero, next to the identity it
			    describes, rather than as a bare rail above every tab. */}
			<header className="shrink-0">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						My Account
					</h1>

					<PillTabs items={MY_ACCOUNT_TAB_ITEMS} value={tab} />
				</div>
			</header>

			{/* Only this region scrolls; cards stagger in via StaggerReveal inside panels. */}
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{tabTransitions((style, currentTab) => (
					<animated.div
						key={currentTab}
						role="tabpanel"
						style={style}
						className="pb-2"
					>
						{currentTab === "account-information" ? (
							<>
								{panelPending ? <AccountInformationSkeleton /> : null}
								{!panelPending && panelError ? <AccountInformationError /> : null}
								{!panelPending && panelAccount ? (
									<AccountInformationPanel
										account={panelAccount}
										autoRenewSetupComplete={
											status === AUTO_RENEW_SETUP_COMPLETE_STATUS
										}
									/>
								) : null}
							</>
						) : null}
						{currentTab === "contact-preferences" ? (
							<>
								{prefsPending ? <ContactPreferencesSkeleton /> : null}
								{prefsMissingContact ? (
									<p className="text-sm text-muted-foreground">
										We couldn&apos;t load your contact preferences. Please try again
										later.
									</p>
								) : null}
								{!prefsPending && contactId ? (
									<ContactPreferencesPanel
										contactId={contactId}
										enabled={tab === "contact-preferences"}
									/>
								) : null}
							</>
						) : null}
						{currentTab === "order-history" ? (
							<OrderHistoryPanel
								enabled={tab === "order-history"}
								filter={orders}
							/>
						) : null}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export { MyAccountPanel }
