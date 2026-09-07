import { useState, type ReactNode } from "react"
import { Link } from "@tanstack/react-router"
import { Award } from "lucide-react"

import type { AccountView } from "@/api/account/types"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import { AccountFieldList } from "@/components/molecules/account-field-list"
import {
	AccountSectionCard,
	type AccountCardSlotProps,
} from "@/components/molecules/account-section-card"
import { DisableAutoRenewDialog } from "@/components/molecules/disable-auto-renew-dialog"
import { StatusBadge } from "@/components/molecules/status-badge"
import {
	buildAutoRenewReturnUrl,
	MEMBERSHIP_REGISTRATION_LINK,
} from "@/config/membership-account"
import { useTurnOnMembershipAutoRenew } from "@/hooks/use-membership-auto-renew"
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

/**
 * The Membership card on My Account. The branching lives in
 * `buildMembershipPresentation` (GarpAppv1's `MembershipInfoCard` rules);
 * this renders it.
 *
 * Switching auto-renew ON is one hop: the server opens the Stripe setup
 * session and the browser leaves for it, returning to this page with
 * `?status=autorenewsetupcomplete`. Switching it OFF asks first, in
 * `DisableAutoRenewDialog`, because it stops a recurring payment.
 */
function MembershipAccountCard({
	account,
	autoRenewSetupComplete,
	handle,
}: MembershipAccountCardProps) {
	const turnOn = useTurnOnMembershipAutoRenew()
	const [confirmingOff, setConfirmingOff] = useState(false)

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
			{membership.statusText || membership.isCertHolder ? (
				<div className="flex flex-wrap items-center gap-2">
					{membership.statusText ? (
						<StatusBadge
							label={membership.statusText}
							tone={membership.statusTone}
						/>
					) : null}
					{membership.isCertHolder ? (
						<Badge variant="secondary">
							<Award aria-hidden />
							Certification holder
						</Badge>
					) : null}
				</div>
			) : null}

			<AccountFieldList
				rows={[
					{ label: "GARP ID", value: membership.garpId },
					{ label: "Member Type", value: membership.memberType },
					{ label: "Member Since", value: membership.memberSince },
				]}
			/>

			{membership.showTurnOnCallout ? (
				<Callout tone="danger" title="Auto Renew">
					<p>
						Auto renew is off. Turn it on to make sure you don&apos;t lose access
						to your Individual Membership benefits
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
						disabled={turnOn.isPending}
						onClick={() => turnOn.mutate(buildAutoRenewReturnUrl(window.location))}
					>
						{turnOn.isPending ? "Opening Stripe…" : "Turn On Auto-Renew"}
					</Button>
				</Callout>
			) : null}

			{membership.showOnCallout ? (
				<Callout tone="success" title="Auto Renew">
					<p>
						GARP will automatically renew your Individual Membership at the
						prevailing rate (USD {membership.renewAmount})
						{membership.expiryLabel ? (
							<>
								{" "}
								on <strong>{membership.expiryLabel}</strong>
							</>
						) : null}{" "}
						using the same credit card you used previously.
					</p>
				</Callout>
			) : null}

			{membership.pendingOrderText ? (
				<Callout tone="pending" title="Payment pending">
					<p>{membership.pendingOrderText}</p>
				</Callout>
			) : null}

			{membership.showCardSaved ? (
				<Callout tone="success" title="Card saved">
					<p>
						Auto-renew takes effect once the payment is confirmed. This card will
						update shortly — nothing has been charged.
					</p>
				</Callout>
			) : null}

			<div className="mt-auto flex flex-wrap gap-2 pt-1">
				{membership.action === "viewOrder" && membership.pendingOrderId ? (
					<Button asChild className="w-fit">
						<Link
							to="/my-account/orders/$orderNumber"
							params={{ orderNumber: membership.pendingOrderId }}
						>
							View Order
						</Link>
					</Button>
				) : null}
				{membership.action === "upgrade" ? (
					<Button asChild className="w-fit">
						<Link {...MEMBERSHIP_REGISTRATION_LINK}>Upgrade</Link>
					</Button>
				) : null}
				{membership.action === "disable" ? (
					<Button
						type="button"
						variant="outline"
						className="w-fit"
						onClick={() => setConfirmingOff(true)}
					>
						Disable Auto Renew
					</Button>
				) : null}
				{membership.action === "renewNow" ? (
					<Button asChild className="w-fit">
						<Link {...MEMBERSHIP_REGISTRATION_LINK}>Renew Now</Link>
					</Button>
				) : null}
			</div>

			<DisableAutoRenewDialog
				open={confirmingOff}
				onOpenChange={setConfirmingOff}
			/>
		</AccountSectionCard>
	)
}

export { MembershipAccountCard }
