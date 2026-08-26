import { AlertCircle, GraduationCap, Info } from "lucide-react"

import type { ExamAdminView } from "@/api/registration/exam-types"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Label } from "@/components/atoms/label"
import { RadioGroup, RadioGroupItem } from "@/components/atoms/radio-group"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { FieldError } from "@/components/molecules/form-field"
import { EXAM_REGISTRATION_COPY } from "@/config/registration"
import { formatMoney } from "@/lib/account-format"
import { sortSites } from "@/lib/registration-presentation"

/** "November 14 – 20, 2026" plus "Standard registration · $800.00". */
function sittingLabel(admin: ExamAdminView) {
	const window = [admin.priceWindow, "registration"].filter(Boolean).join(" ")
	const amount = admin.amount != null ? formatMoney(admin.amount, "USD") : null
	return {
		primary: admin.examDates || admin.name || "Exam sitting",
		secondary: amount ? `${window} · ${amount}` : window,
	}
}

type PartBlockProps = {
	which: 1 | 2
	title: string
	admins: ExamAdminView[]
	selectedRateId: string
	selectedSiteId: string
	onSelectAdmin: (rateId: string) => void
	onSelectSite: (siteId: string) => void
	outOfOrder: boolean
	disabled?: boolean
}

/**
 * One part's sitting and exam centre.
 *
 * The centre list belongs to the chosen sitting, so it only appears once one
 * is picked and is replaced whenever it changes — a centre from a different
 * sitting would price against somewhere that sitting does not run.
 */
function PartBlock({
	which,
	title,
	admins,
	selectedRateId,
	selectedSiteId,
	onSelectAdmin,
	onSelectSite,
	outOfOrder,
	disabled,
}: PartBlockProps) {
	const selectedAdmin = admins.find((admin) => admin.id === selectedRateId)
	const sites = selectedAdmin ? sortSites(selectedAdmin.sites) : []
	const selectedSite = sites.find((site) => site.id === selectedSiteId)

	return (
		<div className="flex flex-col gap-4 rounded-xl border border-border p-4">
			<p className="text-body font-bold">{title}</p>

			<div className="flex flex-col gap-2">
				<Label className="text-caption font-bold text-muted-foreground uppercase">
					Sitting
				</Label>
				{admins.length === 0 ? (
					<p className="text-body text-muted-foreground">
						No exam dates available
					</p>
				) : admins.length === 1 ? (
					<div className="text-body">
						<p className="font-medium">{sittingLabel(admins[0]).primary}</p>
						<p className="text-muted-foreground">
							{sittingLabel(admins[0]).secondary}
						</p>
					</div>
				) : (
					<RadioGroup
						value={selectedRateId}
						onValueChange={onSelectAdmin}
						disabled={disabled}
						className="grid gap-2 sm:grid-cols-2"
					>
						{admins.map((admin) => {
							const label = sittingLabel(admin)
							const id = `part${which}-sitting-${admin.id}`
							return (
								<div
									key={admin.id}
									className="flex items-start gap-3 rounded-lg border border-border p-3"
								>
									<RadioGroupItem id={id} value={admin.id} className="mt-1" />
									<Label htmlFor={id} className="font-normal">
										<span className="block font-medium">{label.primary}</span>
										<span className="block text-muted-foreground">
											{label.secondary}
										</span>
									</Label>
								</div>
							)
						})}
					</RadioGroup>
				)}
				{outOfOrder && which === 2 ? (
					<FieldError message="Part II cannot be taken before Part I." />
				) : null}
			</div>

			{selectedAdmin ? (
				<div className="flex flex-col gap-2">
					<Label
						htmlFor={`part${which}-site`}
						className="text-caption font-bold text-muted-foreground uppercase"
					>
						Where you will sit
					</Label>
					{sites.length === 0 ? (
						<p className="text-body text-muted-foreground">
							No exam centres available
						</p>
					) : sites.length === 1 ? (
						<p className="text-body">{sites[0].name}</p>
					) : (
						<Select
							value={selectedSiteId}
							onValueChange={onSelectSite}
							disabled={disabled}
						>
							<SelectTrigger id={`part${which}-site`} className="w-full">
								<SelectValue placeholder="Select location" />
							</SelectTrigger>
							<SelectContent>
								{sites.map((site) => (
									<SelectItem key={site.id} value={site.id}>
										{site.name}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					)}

					{selectedSite?.isOSTA ? (
						<div
							className="flex items-start gap-2 rounded-lg bg-muted p-3 text-caption text-muted-foreground"
							role="note"
						>
							<Info className="mt-0.5 size-4 shrink-0" aria-hidden />
							<p>{EXAM_REGISTRATION_COPY.ostaSiteNotice}</p>
						</div>
					) : null}
				</div>
			) : null}
		</div>
	)
}

type YourExamSectionProps = {
	partsAvailable: string[]
	partSelected: string
	onSelectPart: (part: string) => void
	part1Title: string
	part2Title: string
	part1Admins: ExamAdminView[]
	part2Admins: ExamAdminView[]
	selection: {
		part1: { rateId: string; siteId: string }
		part2: { rateId: string; siteId: string }
	}
	part1Active: boolean
	part2Active: boolean
	onSelectAdmin: (which: 1 | 2, rateId: string) => void
	onSelectSite: (which: 1 | 2, siteId: string) => void
	outOfOrder: boolean
	disabled?: boolean
}

/** What the candidate is registering for, and where they will sit it. */
function YourExamSection({
	partsAvailable,
	partSelected,
	onSelectPart,
	part1Title,
	part2Title,
	part1Admins,
	part2Admins,
	selection,
	part1Active,
	part2Active,
	onSelectAdmin,
	onSelectSite,
	outOfOrder,
	disabled,
}: YourExamSectionProps) {
	const showPart1 = part1Admins.length > 0 && (part1Active || !partSelected)
	const showPart2 = part2Admins.length > 0 && part2Active

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<GraduationCap className="size-5 text-muted-foreground" aria-hidden />
					Your exam
				</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-4">
				{/*
				 * Only a real choice earns a control. A single-part programme
				 * offers one option — as does FRM when only Part I is open — and
				 * the part block below already carries the exam's name, so
				 * stating it here as well prints nearly the same words twice
				 * under a label asking for a decision nobody has to make.
				 */}
				{partsAvailable.length === 0 ? (
					<p className="text-body text-muted-foreground">No exams available</p>
				) : partsAvailable.length > 1 ? (
					<div className="flex flex-col gap-2">
						<Label htmlFor="examPart" className="font-bold">
							Exam part
							<span className="text-destructive" aria-hidden>
								{" "}
								*
							</span>
						</Label>
						<Select
							value={partSelected}
							onValueChange={onSelectPart}
							disabled={disabled}
						>
							<SelectTrigger id="examPart" className="w-full">
								<SelectValue placeholder="Select exam" />
							</SelectTrigger>
							<SelectContent>
								{partsAvailable.map((part) => (
									<SelectItem key={part} value={part}>
										{part}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					</div>
				) : null}

				{part1Active && part2Active ? (
					<div
						className="flex items-start gap-2 rounded-lg bg-light-yellow p-3 text-caption text-light-yellow-foreground"
						role="note"
					>
						<AlertCircle className="mt-0.5 size-4 shrink-0" aria-hidden />
						<p>{EXAM_REGISTRATION_COPY.bothPartsAlert}</p>
					</div>
				) : null}

				{showPart1 ? (
					<PartBlock
						which={1}
						title={part1Title}
						admins={part1Admins}
						selectedRateId={selection.part1.rateId}
						selectedSiteId={selection.part1.siteId}
						onSelectAdmin={(rateId) => onSelectAdmin(1, rateId)}
						onSelectSite={(siteId) => onSelectSite(1, siteId)}
						outOfOrder={outOfOrder}
						disabled={disabled}
					/>
				) : null}

				{showPart2 ? (
					<PartBlock
						which={2}
						title={part2Title}
						admins={part2Admins}
						selectedRateId={selection.part2.rateId}
						selectedSiteId={selection.part2.siteId}
						onSelectAdmin={(rateId) => onSelectAdmin(2, rateId)}
						onSelectSite={(siteId) => onSelectSite(2, siteId)}
						outOfOrder={outOfOrder}
						disabled={disabled}
					/>
				) : null}
			</CardContent>
		</Card>
	)
}

export { YourExamSection }
