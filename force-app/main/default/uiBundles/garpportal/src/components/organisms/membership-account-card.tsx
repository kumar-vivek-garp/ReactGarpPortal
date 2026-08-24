import type { ReactNode } from "react"
import { Link } from "@tanstack/react-router"

import type { AccountView } from "@/api/account/types"
import { Button } from "@/components/atoms/button"
import { AccountFieldList } from "@/components/molecules/account-field-list"
import {
	AccountSectionCard,
	type AccountCardSlotProps,
} from "@/components/molecules/account-section-card"
import { StatusBadge } from "@/components/molecules/status-badge"
import { MEMBERSHIP_REGISTRATION_URL } from "@/config/membership-account"
import {
	useTurnOffMembershipAutoRenew,
	useTurnOnMembershipAutoRenew,
} from "@/hooks/use-membership-auto-renew"
import { buildMembershipPresentation } from "@/lib/account-presentation"
import { cn } from "@/lib/utils"

type MembershipAccountCardProps = AccountCardSlotProps & {
	account: AccountView
	autoRenewSetupComplete: boolean
}

/** Tokenised notice block — never a raw colour, always a declared pairing. */
function Callout({
	tone,
	title,
	children,
}: {
	tone: "danger" | "success" | "pending"
	title: string
	children: ReactNode
}) {
	return (
		<div
			className={cn(
				"rounded-lg border p-3 text-sm text-foreground",
				tone === "danger" && "border-destructive/50 bg-destructive/10",
				tone === "success" && "border-success-green/50 bg-success-green/15",
				tone === "pending" && "border-garp-saffron/50 bg-garp-saffron/15",
			)}
		>
			<p className="font-heading font-semibold">{title}</p>
			{children}
		</div>
	)
}

function MembershipAccountCard({
	account,
	autoRenewSetupComplete,
	handle,
}: MembershipAccountCardProps) {
	const contactId = account.identity.contactId
	const turnOff = useTurnOffMembershipAutoRenew(contactId)
	const turnOn = useTurnOnMembershipAutoRenew(contactId)
	const busy = turnOff.isPending || turnOn.isPending

	const membership = buildMembershipPresentation(
		account,
		autoRenewSetupComplete,
	)

	return (
		<AccountSectionCard
			section="membership"
			subtitle={membership.intro}
			handle={handle}
		>
			{membership.statusText ? (
				<div className="flex flex-wrap items-center gap-2">
					<StatusBadge
						label={membership.statusText}
						tone={membership.statusTone}
					/>
				</div>
			) : null}

			<AccountFieldList
				rows={[
					{ label: "GARP ID", value: membership.garpId },
					{ label: "Member Type", value: membership.memberType },
				]}
			/>

			{membership.showTurnOnCallout ? (
				<Callout tone="danger" title="Auto Renew">
					<p>
						Auto renew is off. Turn on to ensure you don&apos;t lose access to
						your Individual Membership benefits
						{membership.expiryLabel ? (
							<>
								{" "}
								on <strong>{membership.expiryLabel}</strong>
							</>
						) : null}
						.
					</p>
					<Button
						type="button"
						variant="link"
						className="h-auto px-0"
						disabled={busy}
						onClick={() => turnOn.mutate()}
					>
						Turn On Auto-Renew
					</Button>
				</Callout>
			) : null}

			{membership.showOnCallout ? (
				<Callout tone="success" title="Auto Renew">
					<p>
						GARP will automatically renew my Individual Membership at the
						prevailing rate (USD {membership.renewAmount})
						{membership.expiryLabel ? (
							<>
								{" "}
								on <strong>{membership.expiryLabel}</strong>
							</>
						) : null}{" "}
						using the same previously used credit card.
					</p>
				</Callout>
			) : null}

			{membership.isAutoRenewPending ? (
				<Callout tone="pending" title="Auto Renew">
					<p>Auto-Renew is being setup, please check back later.</p>
				</Callout>
			) : null}

			<div className="mt-auto flex flex-wrap gap-2 pt-1">
				{membership.showUpgrade ? (
					<Button asChild className="w-fit">
						<a href={MEMBERSHIP_REGISTRATION_URL}>Upgrade</a>
					</Button>
				) : null}
				{membership.showViewOrder && membership.pendingOrderId ? (
					<Button asChild className="w-fit">
						<Link
							to="/my-account/orders/$orderNumber"
							params={{ orderNumber: membership.pendingOrderId }}
						>
							View Order
						</Link>
					</Button>
				) : null}
				{membership.showDisable ? (
					<Button
						type="button"
						variant="outline"
						className="w-fit"
						disabled={busy}
						onClick={() => turnOff.mutate()}
					>
						Disable Auto Renew
					</Button>
				) : null}
				{membership.showRenewNow ? (
					membership.isAutoRenewPending || busy ? (
						<Button type="button" className="w-fit" disabled>
							Renew Now
						</Button>
					) : (
						<Button asChild className="w-fit">
							<a href={MEMBERSHIP_REGISTRATION_URL}>Renew Now</a>
						</Button>
					)
				) : null}
			</div>
		</AccountSectionCard>
	)
}

export { MembershipAccountCard }
