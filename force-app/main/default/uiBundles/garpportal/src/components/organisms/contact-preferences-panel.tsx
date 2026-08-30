import { useState } from "react"
import { ExternalLink } from "lucide-react"

import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { ContactPreferencesSkeleton } from "@/components/organisms/contact-preferences-skeleton"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { useContactPreferences } from "@/hooks/use-contact-preferences"
import { useRequestEmailPreferences } from "@/hooks/use-request-email-preferences"
import { useUpdateSmsPreferences } from "@/hooks/use-update-sms-preferences"
import { cn } from "@/lib/utils"

const EMAIL_SUCCESS =
	"An email has been sent to your account with instructions on how to update your preferences."

type ContactPreferencesPanelProps = {
	contactId: string
	enabled?: boolean
	className?: string
}

type SmsDraft = {
	smsPromotional: boolean
	smsRegistration: boolean
}

function formatMobilePhone(
	code: string | null | undefined,
	mobile: string | null | undefined,
): string {
	const trimmedCode = code?.trim() ?? ""
	const trimmedMobile = mobile?.trim() ?? ""
	if (trimmedCode && trimmedMobile) return `+${trimmedCode} ${trimmedMobile}`
	return trimmedMobile
}

function ContactPreferencesPanel({
	contactId,
	enabled = true,
	className,
}: ContactPreferencesPanelProps) {
	const prefsQuery = useContactPreferences(contactId, enabled)
	const requestEmail = useRequestEmailPreferences()
	const updateSms = useUpdateSmsPreferences()

	const [emailRequested, setEmailRequested] = useState(false)
	const [smsDraft, setSmsDraft] = useState<SmsDraft | null>(null)

	const isBusy = requestEmail.isPending || updateSms.isPending
	const data = prefsQuery.data
	const smsPromotional = smsDraft?.smsPromotional ?? data?.smsPromotional ?? false
	const smsRegistration = smsDraft?.smsRegistration ?? data?.smsRegistration ?? false

	const saveSms = (next: SmsDraft) => {
		const previous = {
			smsPromotional,
			smsRegistration,
		}
		setSmsDraft(next)
		void updateSms
			.mutateAsync({
				contactId,
				smsPromotional: next.smsPromotional,
				smsRegistration: next.smsRegistration,
			})
			.then(() => {
				setSmsDraft(null)
			})
			.catch(() => {
				setSmsDraft(previous)
			})
	}

	if (prefsQuery.isLoading) {
		return <ContactPreferencesSkeleton />
	}

	if (prefsQuery.isError || !data) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your contact preferences. Please try again later.
			</p>
		)
	}

	const mobileDisplay = formatMobilePhone(data.mobilePhoneCode, data.mobilePhone)

	return (
		<StaggerReveal
			className={cn(
				"grid gap-6 sm:grid-cols-[minmax(0,1fr)_minmax(16rem,20rem)] sm:items-start",
				className,
			)}
			itemClassName="h-full"
			getItemClassName={(index) => (index === 1 ? "sm:row-span-2" : undefined)}
		>
			{/* DOM order = trail order: top-left → top-right → bottom-left */}
			<AccountSectionCard title="Email Preferences">
				<p className="text-sm text-muted-foreground">
					Personalize your GARP email experience, stay informed by opting into
					our newsletters, and more by clicking the link below.
				</p>
				{emailRequested ? (
					<p className="mt-3 text-sm text-foreground">{EMAIL_SUCCESS}</p>
				) : (
					<button
						type="button"
						disabled={isBusy}
						className="mt-3 inline-flex cursor-pointer items-center gap-1.5 text-sm font-semibold text-deep-purple hover:underline disabled:pointer-events-none disabled:opacity-50"
						onClick={() => {
							void requestEmail
								.mutateAsync(contactId)
								.then(() => {
									setEmailRequested(true)
								})
								.catch(() => {
									// Toast via MutationCache.
								})
						}}
					>
						{requestEmail.isPending
							? "Processing your request…"
							: "Manage Email Preferences"}
						{!requestEmail.isPending ? (
							<ExternalLink className="size-3.5" aria-hidden />
						) : null}
					</button>
				)}
			</AccountSectionCard>

			<AccountSectionCard title="Contact Information" className="h-full">
				<dl className="space-y-3 text-sm">
					<div>
						<dt className="inline font-semibold text-foreground">Email: </dt>
						<dd className="inline text-muted-foreground">{data.email ?? "—"}</dd>
					</div>
					<div>
						<dt className="inline font-semibold text-foreground">Mobile Phone: </dt>
						<dd className="inline text-muted-foreground">
							{mobileDisplay || "—"}
						</dd>
					</div>
				</dl>
			</AccountSectionCard>

			<AccountSectionCard title="SMS Preferences">
				<p className="text-xs text-muted-foreground">
					Note: Standard text messaging rates may apply.
				</p>

				<div className="mt-4 space-y-5">
					<div className="space-y-2">
						<p className="text-sm font-semibold text-foreground">
							Registration Updates
						</p>
						<div className="flex items-start gap-2.5">
							<Checkbox
								id="sms-registration"
								checked={smsRegistration}
								disabled={isBusy}
								onCheckedChange={(checked) => {
									saveSms({
										smsPromotional,
										smsRegistration: checked === true,
									})
								}}
							/>
							<Label
								htmlFor="sms-registration"
								className="text-sm font-normal leading-snug text-muted-foreground"
							>
								I agree to receive time-sensitive information about my upcoming
								exam/event via text message.
							</Label>
						</div>
					</div>

					<div className="space-y-2">
						<p className="text-sm font-semibold text-foreground">Promotions</p>
						<div className="flex items-start gap-2.5">
							<Checkbox
								id="sms-promotional"
								checked={smsPromotional}
								disabled={isBusy}
								onCheckedChange={(checked) => {
									saveSms({
										smsPromotional: checked === true,
										smsRegistration,
									})
								}}
							/>
							<Label
								htmlFor="sms-promotional"
								className="text-sm font-normal leading-snug text-muted-foreground"
							>
								I agree to receive future marketing and promotional text
								messages.
							</Label>
						</div>
					</div>
				</div>
			</AccountSectionCard>
		</StaggerReveal>
	)
}

export { ContactPreferencesPanel }
