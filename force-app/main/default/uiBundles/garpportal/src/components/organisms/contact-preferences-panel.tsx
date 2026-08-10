import { useState } from "react"
import { ExternalLink } from "lucide-react"

import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { Skeleton } from "@/components/atoms/skeleton"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
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

function PrefsSectionSkeleton({
	titleWidth,
	lines = 2,
	extra,
}: {
	titleWidth: string
	lines?: number
	extra?: "link" | "checks" | "fields"
}) {
	return (
		<Skeleton className="gap-4 rounded-xl border border-border bg-muted/40 py-5">
			<div className="px-6">
				<Skeleton className={cn("h-5", titleWidth)} />
			</div>
			<div className="space-y-3 px-6">
				{Array.from({ length: lines }, (_, i) => (
					<Skeleton
						key={i}
						className={cn("h-3.5", i === lines - 1 ? "w-4/5" : "w-full")}
					/>
				))}
				{extra === "link" ? (
					<Skeleton className="mt-1 h-4 w-52" />
				) : null}
				{extra === "checks" ? (
					<div className="mt-2 space-y-5">
						{[0, 1].map((key) => (
							<div key={key} className="space-y-2">
								<Skeleton className="h-4 w-40" />
								<div className="flex items-start gap-2.5">
									<Skeleton className="mt-0.5 size-4 shrink-0 rounded-sm" />
									<div className="min-w-0 flex-1 space-y-1.5">
										<Skeleton className="h-3 w-full" />
										<Skeleton className="h-3 w-5/6" />
									</div>
								</div>
							</div>
						))}
					</div>
				) : null}
				{extra === "fields" ? (
					<div className="space-y-3 pt-1">
						<Skeleton className="h-3.5 w-3/4" />
						<Skeleton className="h-3.5 w-2/3" />
					</div>
				) : null}
			</div>
		</Skeleton>
	)
}

function ContactPreferencesSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-[minmax(0,1fr)_minmax(16rem,20rem)] sm:items-start"
			aria-busy
			aria-label="Loading contact preferences"
		>
			<div className="space-y-6">
				<PrefsSectionSkeleton titleWidth="w-44" lines={2} extra="link" />
				<PrefsSectionSkeleton titleWidth="w-40" lines={1} extra="checks" />
			</div>
			<PrefsSectionSkeleton titleWidth="w-48" lines={0} extra="fields" />
		</div>
	)
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
		<div
			className={cn(
				"grid gap-6 sm:grid-cols-[minmax(0,1fr)_minmax(16rem,20rem)] sm:items-start",
				className,
			)}
		>
			<div className="space-y-6">
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
			</div>

			<AccountSectionCard title="Contact Information">
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
		</div>
	)
}

export { ContactPreferencesPanel, ContactPreferencesSkeleton }
