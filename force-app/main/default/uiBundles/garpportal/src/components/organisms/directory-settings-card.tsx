import type { AccountView } from "@/api/account/types"
import type { AccountProfileValues } from "@/api/account/save-profile"
import { Checkbox } from "@/components/atoms/checkbox"
import { Label } from "@/components/atoms/label"
import {
	AccountSectionCard,
	type AccountCardSlotProps,
} from "@/components/molecules/account-section-card"
import { useSaveDirectorySettings } from "@/hooks/use-save-account-profile"
import { useSaveState } from "@/hooks/use-save-state"
import { cn } from "@/lib/utils"

type DirectorySettingsCardProps = AccountCardSlotProps & {
	account: AccountView
}

type DirectoryDraft = {
	optedIn: boolean
	showJobInformation: boolean
	showProfessionalBackground: boolean
	connectFeature: boolean
	showAdditionalDetail: boolean
}

function asBool(value: boolean | null | undefined): boolean {
	return value === true
}

function profileValues(draft: DirectoryDraft): AccountProfileValues {
	return {
		GARP_Directory_Opt_In__c: draft.optedIn,
		GARP_Dir_Privacy_Job_Information__c: draft.showJobInformation,
		GARP_Dir_Privacy_Prof_Background__c: draft.showProfessionalBackground,
		GARP_Directory_Connect_Feature__c: draft.connectFeature,
		GARP_Dir_Privacy_Additional_Detail__c: draft.showAdditionalDetail,
	}
}

function DirectoryCheck({
	id,
	label,
	checked,
	disabled,
	onCheckedChange,
}: {
	id: string
	label: string
	checked: boolean
	disabled: boolean
	onCheckedChange: (checked: boolean) => void
}) {
	return (
		<div
			className={cn(
				"flex items-start gap-2.5 rounded-lg border border-border p-3",
				checked && "border-primary/40 bg-primary/5",
				disabled && "opacity-60",
			)}
		>
			<Checkbox
				id={id}
				checked={checked}
				disabled={disabled}
				onCheckedChange={(next) => onCheckedChange(next === true)}
			/>
			<Label
				htmlFor={id}
				className={cn(
					"font-normal leading-snug text-foreground",
					disabled && "pointer-events-none",
				)}
			>
				{label}
			</Label>
		</div>
	)
}

function DirectorySettingsCard({
	account,
	handle,
}: DirectorySettingsCardProps) {
	const { identity, directory } = account
	const saveMutation = useSaveDirectorySettings(identity.contactId)
	const busy = saveMutation.isPending
	const saveState = useSaveState(saveMutation)

	const optedIn = asBool(directory.optedIn)
	const showJobInformation = optedIn && asBool(directory.showJobInformation)
	const showProfessionalBackground =
		optedIn && asBool(directory.showProfessionalBackground)
	const connectFeature = optedIn && asBool(directory.connectFeature)
	const showAdditionalDetail = optedIn && asBool(directory.showAdditionalDetail)

	const save = (next: DirectoryDraft) => {
		const draft = next.optedIn
			? next
			: {
					optedIn: false,
					showJobInformation: false,
					showProfessionalBackground: false,
					connectFeature: false,
					showAdditionalDetail: false,
				}
		saveMutation.mutate(profileValues(draft))
	}

	return (
		<AccountSectionCard
			section="directory"
			saveState={saveState}
			handle={handle}
		>
			<div className="flex flex-col gap-2.5">
				<DirectoryCheck
					id="directory-opt-in"
					label="Member directory opt-in"
					checked={optedIn}
					disabled={busy}
					onCheckedChange={(next) =>
						save({
							optedIn: next,
							showJobInformation,
							showProfessionalBackground,
							connectFeature,
							showAdditionalDetail,
						})
					}
				/>
			</div>

			{/* Dependent on the opt-in above — indented so the cascade is legible. */}
			<div className="flex flex-col gap-2.5 border-l-2 border-border pl-3">
				<DirectoryCheck
					id="directory-org-expertise"
					label="Show my organization type & expertise"
					checked={showJobInformation}
					disabled={busy || !optedIn}
					onCheckedChange={(next) =>
						save({
							optedIn,
							showJobInformation: next,
							showProfessionalBackground,
							connectFeature,
							showAdditionalDetail,
						})
					}
				/>
				<DirectoryCheck
					id="directory-job-company"
					label="Show my job title and company"
					checked={showProfessionalBackground}
					disabled={busy || !optedIn}
					onCheckedChange={(next) =>
						save({
							optedIn,
							showJobInformation,
							showProfessionalBackground: next,
							connectFeature,
							showAdditionalDetail,
						})
					}
				/>
				<DirectoryCheck
					id="directory-connect"
					label="Allow other members to contact me"
					checked={connectFeature}
					disabled={busy || !optedIn}
					onCheckedChange={(next) =>
						save({
							optedIn,
							showJobInformation,
							showProfessionalBackground,
							connectFeature: next,
							showAdditionalDetail,
						})
					}
				/>
			</div>
		</AccountSectionCard>
	)
}

export { DirectorySettingsCard }
