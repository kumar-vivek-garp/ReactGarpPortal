import { useEffect, useState } from "react"

import { AccountEditDialog } from "@/components/molecules/account-edit-dialog"
import { AccountFieldGrid } from "@/components/molecules/account-field-grid"
import { AccountFieldList } from "@/components/molecules/account-field-list"
import { AccountSectionCard } from "@/components/molecules/account-section-card"
import { BentoDragHandle, BentoGrid } from "@/components/molecules/bento-grid"
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
	ACCOUNT_BENTO_SCOPE,
	ACCOUNT_SECTION_META,
	type AccountSection,
} from "@/config/account-sections"
import type {
	BentoRenderItem,
	BentoSlotControls,
} from "@/hooks/use-bento-layout"
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

function AccountInformationError() {
	return (
		<p className="text-sm text-muted-foreground">
			We couldn&apos;t load your account information. Please try again later.
		</p>
	)
}

function heldDesignationsLabel(
	designations: AccountDesignations,
): string | null {
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
	const { scrollTo } = useSpringScrollTo()

	useEffect(() => {
		if (!spotlight) return
		const timer = window.setTimeout(() => setSpotlight(null), SPOTLIGHT_HOLD_MS)
		return () => window.clearTimeout(timer)
	}, [spotlight])

	const jumpTo = (section: AccountSection) => {
		scrollTo(document.getElementById(ACCOUNT_SECTION_META[section].domId))
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

	/**
	 * Slots handed down by `BentoGrid`. Every card renders the same pair in the
	 * same place, so the grip is always in the identical spot as the eye moves
	 * down the grid.
	 */
	const slots = ({ handleProps }: BentoSlotControls) => ({
		handle: handleProps ? <BentoDragHandle handleProps={handleProps} /> : null,
	})

	const item = (
		section: AccountSection,
		render: BentoRenderItem["render"],
	): BentoRenderItem => ({
		id: section,
		label: ACCOUNT_SECTION_META[section].label,
		render,
	})

	const bentoItems: BentoRenderItem[] = [
		item("personal", (controls) => (
			<AccountSectionCard
				section="personal"
				spotlight={spotlight === "personal"}
				{...slots(controls)}
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
		)),

		item("membership", (controls) => (
			<MembershipAccountCard
				account={account}
				autoRenewSetupComplete={autoRenewSetupComplete}
				{...slots(controls)}
			/>
		)),

		item("career", (controls) => (
			<AccountSectionCard
				section="career"
				spotlight={spotlight === "career"}
				missingCount={careerMissing}
				{...slots(controls)}
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
		)),

		item("chapters", (controls) => (
			<PreferredChaptersCard account={account} {...slots(controls)} />
		)),

		item("expertise", (controls) => <ExpertiseCard {...slots(controls)} />),

		item("directory", (controls) => (
			<DirectorySettingsCard account={account} {...slots(controls)} />
		)),
	]

	return (
		<div className="space-y-6">
			<AccountIdentityHero
				account={account}
				onEditPersonal={() => setPersonalEditOpen(true)}
				onFixField={fixField}
				onReviewMissing={() => jumpTo("career")}
			/>

			{/*
			 * Bento. The order and column spans are the member's own — dragged by
			 * the grip in each card header and remembered in localStorage. The
			 * code order below is only the default a first visit starts from.
			 *
			 * Cards are declared as a registry rather than as JSX children so a
			 * card's span travels with its id. The previous shape derived spans by
			 * position (`ACCOUNT_CARD_SPAN[ACCOUNT_CARD_ORDER[index]]`) against
			 * hand-written children, which only lined up by coincidence and broke
			 * the moment either side was reordered.
			 */}
			<BentoGrid scope={ACCOUNT_BENTO_SCOPE} items={bentoItems} />
		</div>
	)
}

export { AccountInformationPanel, AccountInformationError }
