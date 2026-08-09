import { useState } from "react"
import { CircleUser } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { AccountFieldGrid } from "@/components/molecules/account-field-grid"
import { AccountFieldList } from "@/components/molecules/account-field-list"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import type { AccountView } from "@/api/account/types"
import { addressLines, formatLongDate } from "@/lib/account-format"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"

const MEMBERSHIP_UPGRADE_URL = "https://www.garp.org/membership"

type AccountInformationPanelProps = {
	account: AccountView
}

function AccountInformationSkeleton() {
	return (
		<div className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3" aria-busy aria-label="Loading account">
			{[0, 1, 2, 3, 4, 5].map((n) => (
				<div
					key={n}
					className="flex h-full min-h-56 flex-col gap-3 rounded-xl border border-border bg-muted/40 px-6 py-5"
				>
					<Skeleton className="h-5 w-2/5 rounded-sm" />
					{n === 0 ? (
						<div className="flex flex-col gap-4">
							<div className="flex gap-4">
								<Skeleton className="size-28 shrink-0 rounded-full" />
								<div className="grid min-w-0 flex-1 grid-cols-2 gap-3">
									<Skeleton className="h-8 w-full rounded-sm" />
									<Skeleton className="h-8 w-full rounded-sm" />
									<Skeleton className="h-8 w-full rounded-sm" />
									<Skeleton className="h-8 w-full rounded-sm" />
									<Skeleton className="col-span-2 h-8 w-full rounded-sm" />
								</div>
							</div>
							<Skeleton className="h-px w-full" />
							<div className="flex flex-col gap-2">
								<Skeleton className="h-3.5 w-1/3 rounded-sm" />
								<Skeleton className="h-3.5 w-full rounded-sm" />
								<Skeleton className="h-3.5 w-4/5 rounded-sm" />
							</div>
						</div>
					) : (
						<div className="flex flex-1 flex-col gap-2.5">
							<Skeleton className="h-3.5 w-full rounded-sm" />
							<Skeleton className="h-3.5 w-5/6 rounded-sm" />
							<Skeleton className="h-3.5 w-4/6 rounded-sm" />
							<Skeleton className="h-3.5 w-3/4 rounded-sm" />
							{n % 2 === 0 ? (
								<>
									<Skeleton className="mt-1 h-3.5 w-1/3 rounded-sm" />
									<Skeleton className="h-3.5 w-full rounded-sm" />
									<Skeleton className="h-3.5 w-2/3 rounded-sm" />
								</>
							) : (
								<>
									<Skeleton className="mt-1 h-3.5 w-2/5 rounded-sm" />
									<Skeleton className="h-3.5 w-4/5 rounded-sm" />
								</>
							)}
						</div>
					)}
				</div>
			))}
		</div>
	)
}

function AccountInformationError() {
	return (
		<p className="text-sm text-muted-foreground">
			We couldn&apos;t load your account information. Please try again later.
		</p>
	)
}

function AccountInformationPanel({ account }: AccountInformationPanelProps) {
	const {
		identity,
		personal,
		career,
		academic,
		expertise,
		directory,
		chapters,
		mailingAddress,
		billingAddress,
		otherAddress,
	} = account

	const [personalEditOpen, setPersonalEditOpen] = useState(false)
	const expiry = formatLongDate(identity.membershipExpiration)
	const mailingLines = addressLines(mailingAddress)
	const billingLines = addressLines(billingAddress)
	const otherLines = addressLines(otherAddress)
	const photoUrl = resolvePortalAssetUrl(
		personal.photoUrl ?? identity.photoUrl,
	)

	return (
		<div className="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
			<AccountSectionCard
				title="Personal Information"
				action={
					<AccountEditDialog
						title="Edit Personal Information"
						description="Update your name, mobile number, photo, billing and mailing address."
						open={personalEditOpen}
						onOpenChange={setPersonalEditOpen}
					>
						<PersonalInfoEditForm
							contactId={identity.contactId}
							onSaved={() => setPersonalEditOpen(false)}
						/>
					</AccountEditDialog>
				}
			>
				{/* Avatar + 2-col field grid fills width; address sits below. */}
				<div className="flex items-start gap-5">
					<Avatar className="size-28 shrink-0">
						<AvatarImage src={photoUrl} alt="" className="object-cover" />
						<AvatarFallback className="bg-transparent p-0 text-muted-foreground">
							<CircleUser
								className="size-28"
								strokeWidth={1.25}
								absoluteStrokeWidth
								aria-hidden
							/>
						</AvatarFallback>
					</Avatar>

					<AccountFieldGrid
						className="min-w-0 flex-1 pt-0.5"
						rows={[
							{ label: "First Name", value: personal.firstName },
							{ label: "Last Name", value: personal.lastName },
							{ label: "GARP ID", value: identity.garpId },
							{ label: "Phone", value: personal.phone },
							{ label: "Email", value: personal.email, span: 2 },
						]}
					/>
				</div>

				<div className="flex justify-between gap-6 border-t border-border pt-3">
					<div className="min-w-0 flex-1">
						<p className="font-heading text-sm font-semibold text-foreground">
							Mailing Address
						</p>
						{mailingLines.length > 0 ? (
							<div className="mt-1 text-sm text-foreground">
								{mailingLines.map((line) => (
									<p key={line}>{line}</p>
								))}
							</div>
						) : (
							<p className="mt-1 text-sm text-muted-foreground">
								No mailing address on file.
							</p>
						)}
					</div>
					<div className="min-w-0 flex-1">
						<p className="font-heading text-sm font-semibold text-foreground">
							Billing Address
						</p>
						{billingLines.length > 0 ? (
							<div className="mt-1 text-sm text-foreground">
								{billingLines.map((line) => (
									<p key={line}>{line}</p>
								))}
							</div>
						) : (
							<p className="mt-1 text-sm text-muted-foreground">
								No billing address on file.
							</p>
						)}
					</div>
				</div>

				{!otherAddress.isEmpty ? (
					<div>
						<p className="font-heading text-sm font-semibold text-foreground">Other Address</p>
						<div className="mt-1 text-sm text-foreground">
							{otherLines.map((line) => (
								<p key={line}>{line}</p>
							))}
						</div>
					</div>
				) : null}
			</AccountSectionCard>

			<AccountSectionCard title="Career Information">
				<p className="font-heading text-sm font-semibold text-foreground">Employment Information</p>
				<AccountFieldList
					rows={[
						{ label: "Current/Last Company", value: career.company },
						{ label: "Professional Level", value: career.corporateTitle },
						{ label: "Job Function", value: career.jobFunction },
						{ label: "Company City", value: career.companyCity },
						{ label: "Company Country", value: career.companyCountry },
						{ label: "In the industry since", value: career.industryWorkingYear },
					]}
					emptyMessage="Add your employment details so we can tailor recommendations."
				/>

				<p className="pt-2 font-heading text-sm font-semibold text-foreground">
					Academic Information
				</p>
				<AccountFieldList
					rows={[
						{ label: "Highest Degree", value: academic.highestDegree },
						{ label: "School", value: academic.schoolName },
						{ label: "Degree Program", value: academic.degreeProgramName },
					]}
					emptyMessage="No academic information added yet."
				/>
			</AccountSectionCard>

			<AccountSectionCard title="Membership">
				{identity.isIndividualMember ? (
					<p className="text-sm text-foreground">
						Your Individual Membership unlocks every Member benefit, the Member Directory, and
						preferential pricing on products and events.
					</p>
				) : (
					<p className="text-sm text-foreground">
						Upgrade to Individual Membership to get exclusive access to premium content and
						professional learning resources, special Career Center features, networking
						opportunities through our GARP Member Directory, and preferential pricing on products
						and events.
					</p>
				)}

				<AccountFieldList
					rows={[
						{ label: "GARP ID", value: identity.garpId },
						{ label: "Member Type", value: identity.membershipType },
						{
							label: "Status",
							value: identity.membershipStatus
								? expiry
									? `${identity.membershipStatus} (until ${expiry})`
									: identity.membershipStatus
								: null,
						},
						{ label: "Auto-renew", value: identity.autoRenew ? "On" : "Off" },
					]}
				/>

				{!identity.isIndividualMember ? (
					<Button asChild className="mt-1 w-fit">
						<a href={MEMBERSHIP_UPGRADE_URL} target="_blank" rel="noreferrer noopener">
							Upgrade
						</a>
					</Button>
				) : null}
			</AccountSectionCard>

			<AccountSectionCard
				title="Preferred Chapters"
				subtitle="Stay on the cutting edge of risk management and make new connections by participating in your local chapter. As a member of the GARP community, you may attend our chapter meetings anywhere in the world and will always be welcome."
			>
				<AccountFieldList
					rows={[
						{ label: "Primary Chapter", value: chapters.primary },
						{ label: "Secondary Chapter", value: chapters.secondary },
					]}
					emptyMessage="No chapter selected yet."
				/>
				<p className="text-xs text-muted-foreground">
					Chapter membership is managed through your chapter — contact us to change your primary
					chapter.
				</p>
			</AccountSectionCard>

			<AccountSectionCard
				title="Directory Settings"
				subtitle="These settings control what appears in your GARP Directory entry. Professional background and job information are only visible to other members."
			>
				<AccountFieldList
					rows={[
						{ label: "Listed in the directory", value: directory.optedIn ? "Yes" : "No" },
						{
							label: "Contactable by members",
							value: directory.connectFeature ? "Yes" : "No",
						},
						{
							label: "Job information shown",
							value: directory.showJobInformation ? "Yes" : "No",
						},
						{
							label: "Professional background shown",
							value: directory.showProfessionalBackground ? "Yes" : "No",
						},
					]}
				/>
			</AccountSectionCard>

			<AccountSectionCard
				title="Expertise"
				subtitle="Complete this if you have experience as a Subject Matter Expert in one or more areas of financial risk management and would like to collaborate with GARP on delivering risk intelligence."
			>
				<AccountFieldList
					rows={[
						{ label: "Area of Expertise", value: expertise.riskSpecialty },
						{ label: "Topics", value: expertise.topicsOrExpertise },
					]}
					emptyMessage="No areas of expertise selected yet."
				/>
			</AccountSectionCard>
		</div>
	)
}

export {
	AccountInformationPanel,
	AccountInformationSkeleton,
	AccountInformationError,
}
