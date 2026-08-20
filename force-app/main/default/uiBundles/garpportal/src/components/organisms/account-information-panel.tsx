import { useEffect, useState } from "react"

import { Skeleton } from "@/components/atoms/skeleton"
import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { AccountFieldGrid } from "@/components/molecules/account-field-grid"
import { AccountFieldList } from "@/components/molecules/account-field-list"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { CompletionRingSkeleton } from "@/components/molecules/completion-ring"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { AccountIdentityHero } from "@/components/organisms/account-identity-hero"
import {
	CareerInformationEditForm,
	DESIGNATION_CODES,
} from "@/components/organisms/career-information-edit-form"
import { DirectorySettingsCard } from "@/components/organisms/directory-settings-card"
import { ExpertiseCard } from "@/components/organisms/expertise-card"
import { MembershipAccountCard } from "@/components/organisms/membership-account-card"
import { PreferredChaptersCard } from "@/components/organisms/preferred-chapters-card"
import { PersonalInfoEditForm } from "@/components/organisms/personal-info-edit-form"
import {
	ACCOUNT_CARD_GRID,
	ACCOUNT_CARD_ORDER,
	ACCOUNT_CARD_SPAN,
	ACCOUNT_SECTION_META,
	type AccountSection,
} from "@/config/account-sections"
import { useSpringScrollTo } from "@/hooks/use-spring-scroll-to"
import type { AccountDesignations, AccountView } from "@/api/account/types"
import {
	missingCountForSection,
	type CareerFocusField,
} from "@/lib/account-presentation"
import { addressLines } from "@/lib/account-format"

/** How long a jumped-to card keeps its ring before fading back. */
const SPOTLIGHT_HOLD_MS = 1800

/**
 * Card row label -> the control the Career dialog should focus when its "Add"
 * affordance is used. Only rows the dialog can actually edit appear here.
 */
const CAREER_ROW_FOCUS: Record<string, CareerFocusField> = {
	"Work status": "workStatus",
	Industry: "industry",
	"In the industry since": "industryStartYear",
	"Current/Last Company": "company",
	"Professional Level": "professionalLevel",
	"Job Function": "jobFunction",
	"In risk management since": "riskStartYear",
	School: "school",
	"Degree Program": "degreeProgram",
	"Year of graduation": "graduationYear",
	"Month of graduation": "graduationMonth",
}

type AccountInformationPanelProps = {
	account: AccountView
	autoRenewSetupComplete?: boolean
}

function AccountInformationSkeleton() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading account">
			{/* Hero bone — same geometry as AccountIdentityHero. */}
			<div className="rounded-xl border border-border bg-muted/40 p-5 sm:p-6">
				<div className="flex flex-col gap-5 app:flex-row app:items-center app:gap-6">
					<CompletionRingSkeleton />
					<div className="min-w-0 flex-1 space-y-2.5">
						<Skeleton className="h-8 w-3/5 max-w-xs rounded-sm" />
						<div className="flex flex-wrap gap-2">
							<Skeleton className="h-6 w-32 rounded-full" />
							<Skeleton className="h-6 w-24 rounded-full" />
							<Skeleton className="h-6 w-28 rounded-full" />
						</div>
						<Skeleton className="h-3.5 w-2/5 rounded-sm" />
						<Skeleton className="h-3.5 w-1/3 rounded-sm" />
					</div>
					<Skeleton className="h-9 w-full rounded-md app:w-32" />
				</div>
			</div>

			<div className={ACCOUNT_CARD_GRID}>
				{ACCOUNT_CARD_ORDER.map((section, index) => (
					<div
						key={section}
						className={`flex min-h-56 flex-col gap-3 rounded-xl border border-border bg-muted/40 px-6 py-5 ${ACCOUNT_CARD_SPAN[section]}`}
					>
						<div className="flex items-center gap-2">
							<Skeleton className="size-8 shrink-0 rounded-lg" />
							<Skeleton className="h-5 w-2/5 rounded-sm" />
						</div>
						<div className="flex flex-1 flex-col gap-2.5">
							<Skeleton className="h-3.5 w-full rounded-sm" />
							<Skeleton className="h-3.5 w-5/6 rounded-sm" />
							<Skeleton className="h-3.5 w-4/6 rounded-sm" />
							<Skeleton className="h-3.5 w-3/4 rounded-sm" />
							{index % 2 === 0 ? (
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
					</div>
				))}
			</div>
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

function heldDesignationsLabel(designations: AccountDesignations): string | null {
	const held: string[] = DESIGNATION_CODES.filter(
		(code) => designations[code] === true,
	)
	if (designations.Other === true) {
		held.push(
			designations.otherQualifications
				? `Other (${designations.otherQualifications})`
				: "Other",
		)
	}
	return held.length > 0 ? held.join(", ") : null
}

/** One address block — mailing / billing / other share the same shape. */
function AddressBlock({
	title,
	lines,
	emptyMessage,
}: {
	title: string
	lines: string[]
	emptyMessage?: string
}) {
	return (
		<div className="min-w-0 flex-1">
			<p className="font-heading text-sm font-semibold text-foreground">
				{title}
			</p>
			{lines.length > 0 ? (
				<div className="mt-1 text-sm text-foreground">
					{lines.map((line) => (
						<p key={line}>{line}</p>
					))}
				</div>
			) : emptyMessage ? (
				<p className="mt-1 text-sm text-muted-foreground">{emptyMessage}</p>
			) : null}
		</div>
	)
}

function AccountInformationPanel({
	account,
	autoRenewSetupComplete = false,
}: AccountInformationPanelProps) {
	const {
		identity,
		personal,
		designations,
		career,
		academic,
		completeness,
		mailingAddress,
		billingAddress,
		otherAddress,
	} = account

	const [personalEditOpen, setPersonalEditOpen] = useState(false)
	const [careerEditOpen, setCareerEditOpen] = useState(false)
	const [careerFocus, setCareerFocus] = useState<CareerFocusField | undefined>()
	const [spotlight, setSpotlight] = useState<AccountSection | null>(null)
	const scrollToElement = useSpringScrollTo()

	useEffect(() => {
		if (!spotlight) return
		const timer = window.setTimeout(() => setSpotlight(null), SPOTLIGHT_HOLD_MS)
		return () => window.clearTimeout(timer)
	}, [spotlight])

	const jumpTo = (section: AccountSection) => {
		scrollToElement(document.getElementById(ACCOUNT_SECTION_META[section].domId))
		setSpotlight(section)
	}

	/** From a completeness chip: open the Career dialog on the offending field. */
	const fixField = (field: CareerFocusField) => {
		setCareerFocus(field)
		setCareerEditOpen(true)
	}

	const openCareerEdit = (row?: { label: string }) => {
		setCareerFocus(row ? CAREER_ROW_FOCUS[row.label] : undefined)
		setCareerEditOpen(true)
	}

	const careerMissing = missingCountForSection(completeness, "career")

	return (
		<div className="space-y-6">
			<AccountIdentityHero
				account={account}
				onEditPersonal={() => setPersonalEditOpen(true)}
				onFixField={fixField}
				onReviewMissing={() => jumpTo("career")}
			/>

			{/*
			 * Bento. Auto-placement at `xl` gives three rows:
			 * [personal personal][membership] / [career career][chapters] /
			 * [expertise expertise][directory]. Below `xl` it is a single column
			 * in the same DOM order, so identity and standing come first on a phone.
			 */}
			<StaggerReveal
				className={ACCOUNT_CARD_GRID}
				getItemClassName={(index) =>
					ACCOUNT_CARD_SPAN[ACCOUNT_CARD_ORDER[index]]
				}
			>
				<AccountSectionCard
					section="personal"
					spotlight={spotlight === "personal"}
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
					<AccountFieldGrid
						rows={[
							{ label: "First Name", value: personal.firstName },
							{ label: "Last Name", value: personal.lastName },
							{ label: "GARP ID", value: identity.garpId },
							{ label: "Phone", value: personal.phone },
							{ label: "Email", value: personal.email, span: 2 },
						]}
					/>

					<div className="flex flex-col gap-4 border-t border-border pt-3 sm:flex-row sm:justify-between sm:gap-6">
						<AddressBlock
							title="Mailing Address"
							lines={addressLines(mailingAddress)}
							emptyMessage="No mailing address on file."
						/>
						<AddressBlock
							title="Billing Address"
							lines={addressLines(billingAddress)}
							emptyMessage="No billing address on file."
						/>
					</div>

					{!otherAddress.isEmpty ? (
						<AddressBlock
							title="Other Address"
							lines={addressLines(otherAddress)}
						/>
					) : null}
				</AccountSectionCard>

				<MembershipAccountCard
					account={account}
					autoRenewSetupComplete={autoRenewSetupComplete}
				/>

				<AccountSectionCard
					section="career"
					spotlight={spotlight === "career"}
					missingCount={careerMissing}
					action={
						<AccountEditDialog
							title="Edit Career Information"
							description="Update your job, designations, and academic information."
							open={careerEditOpen}
							onOpenChange={(next) => {
								setCareerEditOpen(next)
								if (!next) setCareerFocus(undefined)
							}}
						>
							<CareerInformationEditForm
								// Remount on open so RHF re-seeds `defaultValues` from the
								// freshest account — see the form's own note on why `values`
								// cannot be used instead.
								key={careerEditOpen ? "open" : "closed"}
								account={account}
								focusField={careerFocus}
								onSaved={() => setCareerEditOpen(false)}
							/>
						</AccountEditDialog>
					}
				>
					<p className="font-heading text-sm font-semibold text-foreground">
						Employment Information
					</p>
					<AccountFieldList
						onAdd={openCareerEdit}
						rows={[
							{
								label: "Work status",
								value: career.currentlyWorkingStatus,
								addable: true,
							},
							{
								label: "Industry",
								value: career.areaOfConcentration,
								addable: true,
							},
							{
								label: "In the industry since",
								value: career.industryWorkingYear,
								addable: true,
							},
							{
								label: "Current/Last Company",
								value: career.company,
								addable: true,
							},
							{
								label: "Professional Level",
								value: career.corporateTitle,
								addable: true,
							},
							{ label: "Job Function", value: career.jobFunction, addable: true },
							{
								label: "In risk management since",
								value: career.riskManagementWorkingYear,
								addable: true,
							},
							// No editor exists for company city/country, so these must
							// never offer an "Add" affordance.
							{ label: "Company City", value: career.companyCity },
							{ label: "Company Country", value: career.companyCountry },
							{
								label: "Professional designations",
								value: heldDesignationsLabel(designations),
							},
						]}
						emptyMessage="Add your employment details so we can tailor recommendations."
					/>

					<p className="pt-2 font-heading text-sm font-semibold text-foreground">
						Academic Information
					</p>
					<AccountFieldList
						onAdd={openCareerEdit}
						rows={[
							{ label: "School", value: academic.schoolName, addable: true },
							{
								label: "Degree Program",
								value: academic.highestDegree,
								addable: true,
							},
							// Not editable anywhere yet — display only.
							{ label: "Degree program name", value: academic.degreeProgramName },
							{
								label: "Year of graduation",
								value: academic.expectedGraduationDate,
								addable: true,
							},
							{
								label: "Month of graduation",
								value: academic.expectedGraduationMonth,
								addable: true,
							},
						]}
						emptyMessage="No academic information added yet."
					/>
				</AccountSectionCard>

				<PreferredChaptersCard account={account} />

				<ExpertiseCard />

				<DirectorySettingsCard account={account} />
			</StaggerReveal>
		</div>
	)
}

export {
	AccountInformationPanel,
	AccountInformationSkeleton,
	AccountInformationError,
}
