import { useState } from "react"
import { ExternalLink } from "lucide-react"

import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { ContactPreferencesSkeleton } from "@/components/organisms/contact-preferences-skeleton"
import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { useContactPreferences } from "@/hooks/use-contact-preferences"
import { useSaveState } from "@/hooks/use-save-state"
import { useRequestEmailPreferences } from "@/hooks/use-request-email-preferences"
import { useUpdateSmsPreferences } from "@/hooks/use-update-sms-preferences"
import { cn } from "@/lib/utils"

const EMAIL_SUCCESS =
	"An email has been sent to your account with instructions on how to update your preferences."

type ContactPreferencesPanelProps = {
	enabled?: boolean
	className?: string
}

type SmsDraft = {
	smsPromotional: boolean
	smsRegistration: boolean
}

/**
 * `Mobile_Phone_Code__c` holds `"United States (+1)"` — the dialing code is
 * the parenthesised part. A bare code (older records) is shown with a `+`.
 */
function dialingCode(code: string | null | undefined): string {
	const trimmed = code?.trim() ?? ""
	const match = /\(\+?(\d+)\)/.exec(trimmed)
	if (match) return `+${match[1]}`
	return trimmed ? `+${trimmed.replace(/^\+/, "")}` : ""
}

function formatMobilePhone(
	code: string | null | undefined,
	mobile: string | null | undefined,
): string {
	const prefix = dialingCode(code)
	const trimmedMobile = mobile?.trim() ?? ""
	if (prefix && trimmedMobile) return `${prefix} ${trimmedMobile}`
	return trimmedMobile
}

function ContactPreferencesPanel({
	enabled = true,
	className,
}: ContactPreferencesPanelProps) {
	const prefsQuery = useContactPreferences(enabled)
	const requestEmail = useRequestEmailPreferences()
	const updateSms = useUpdateSmsPreferences()

	const [emailRequested, setEmailRequested] = useState(false)
	const [smsDraft, setSmsDraft] = useState<SmsDraft | null>(null)
	const [contactEditOpen, setContactEditOpen] = useState(false)

	/*
	 * These checkboxes autosave on change, with only a global toast to say so —
	 * easy to miss when the box that changed is still under the cursor. The
	 * header indicator puts the confirmation next to the control, exactly as the
	 * autosaving cards on Account Information already do.
	 */
	const smsSaveState = useSaveState(updateSms)

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
								.mutateAsync()
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

			{/*
			 * Editing runs through the SAME dialog as Account Information rather
			 * than a second, smaller one: `savePersonalInfo` already writes these
			 * exact fields (`Email`, `Mobile_Phone_Code__c`, `MobilePhone`), and a
			 * bespoke editor here would be a second copy of their validation, free
			 * to drift from the first. The save invalidates the composed account
			 * view, which is what this card reads, so the new values land here
			 * without any extra wiring.
			 */}
			<AccountSectionCard
				title="Contact Information"
				className="h-full"
				action={
					<AccountEditDialog
						title="Edit Personal Information"
						description="Update your name, mobile number, photo, billing and mailing address."
						open={contactEditOpen}
						onOpenChange={setContactEditOpen}
					>
						<PersonalInfoEditForm
							onSaved={() => setContactEditOpen(false)}
						/>
					</AccountEditDialog>
				}
			>
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

			<AccountSectionCard title="SMS Preferences" saveState={smsSaveState}>
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
								className="cursor-pointer text-sm font-normal leading-snug text-muted-foreground"
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
								className="cursor-pointer text-sm font-normal leading-snug text-muted-foreground"
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
