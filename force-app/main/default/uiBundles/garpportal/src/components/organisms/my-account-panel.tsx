import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"

import { accountContactToView } from "@/api/account/account-contact-map"
import { Tabs, TabsList, TabsTrigger, pillTabTriggerClassName } from "@/components/atoms/tabs"
import {
	ProfileCompletenessMeter,
	ProfileCompletenessMeterSkeleton,
} from "@/components/molecules/profile-completeness-meter"
import {
	AccountInformationError,
	AccountInformationPanel,
	AccountInformationSkeleton,
} from "@/components/organisms/account-information-panel"
import {
	ContactPreferencesPanel,
	ContactPreferencesSkeleton,
} from "@/components/organisms/contact-preferences-panel"
import { OrderHistoryPanel } from "@/components/organisms/order-history-panel"
import { useAccount } from "@/hooks/use-account"
import { useAccountContact } from "@/hooks/use-account-contact"
import { useCurrentUser } from "@/hooks/use-current-user"
import type { MyAccountTab } from "@/config/my-account"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

const TAB_ITEMS: Array<{ value: MyAccountTab; label: string }> = [
	{ value: "account-information", label: "Account Information" },
	{ value: "contact-preferences", label: "Contact Preferences" },
	{ value: "order-history", label: "Order History" },
]

type MyAccountPanelProps = {
	tab: MyAccountTab
}

function MyAccountPanel({ tab }: MyAccountPanelProps) {
	const navigate = useNavigate({ from: "/my-account/" })
	const { data: user } = useCurrentUser()
	/** REST: completeness scoring only (+ contactId bootstrap if session Contact is blank). */
	const accountQuery = useAccount()
	const contactId =
		user?.contactId?.trim() ||
		accountQuery.data?.identity.contactId?.trim() ||
		""

	/** GraphQL: Account Information panel fields. */
	const contactQuery = useAccountContact(
		contactId,
		tab === "account-information" && Boolean(contactId),
	)

	const completeness = accountQuery.data?.completeness
	const showMeter = Boolean(completeness && !completeness.isComplete)
	const reserveMeterSlot = accountQuery.isPending || showMeter

	const panelPending =
		tab === "account-information" &&
		((!contactId && accountQuery.isPending) ||
			(Boolean(contactId) && contactQuery.isPending))
	const panelError =
		tab === "account-information" &&
		!panelPending &&
		(accountQuery.isError ||
			(Boolean(contactId) && contactQuery.isError) ||
			!contactId)
	const panelAccount =
		contactQuery.data != null ? accountContactToView(contactQuery.data) : null

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
					search: { tab: value as MyAccountTab },
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			{/* Fixed chrome: heading + progress/tabs — does not scroll. */}
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					My Account
				</h1>

				<div
					className={cn(
						"flex flex-col gap-4",
						reserveMeterSlot && "sm:flex-row sm:items-center sm:justify-between sm:gap-6",
					)}
				>
					{reserveMeterSlot ? (
						<div className="w-full max-w-md sm:min-w-0 sm:flex-1">
							{accountQuery.isPending ? (
								<ProfileCompletenessMeterSkeleton />
							) : showMeter && completeness ? (
								<ProfileCompletenessMeter
									percent={completeness.percentComplete}
									missing={completeness.missing}
								/>
							) : null}
						</div>
					) : null}

					<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
						<TabsList className="h-auto w-max gap-3 bg-transparent p-0">
							{TAB_ITEMS.map((item) => (
								<TabsTrigger
									key={item.value}
									value={item.value}
									className={pillTabTriggerClassName}
								>
									{item.label}
								</TabsTrigger>
							))}
						</TabsList>
					</div>
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
									<AccountInformationPanel account={panelAccount} />
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
							<OrderHistoryPanel enabled={tab === "order-history"} />
						) : null}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export { MyAccountPanel }
