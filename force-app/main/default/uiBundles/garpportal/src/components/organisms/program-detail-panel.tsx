import { animated, useSpring } from "@react-spring/web"

import type { ExamPartInfo, ProgramDetail } from "@/api/programs"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { CardCta } from "@/components/molecules/card-cta"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { formatDateTime, formatLongDate } from "@/lib/account-format"
import { programRegistrationHref } from "@/lib/program-card-links"
import { stripProgramFormalName } from "@/lib/program-formal-name"
import { useProgramDetail } from "@/hooks/use-program-detail"

/** Forward-nav feel when opening `/programs/$programType` from the listing. */
const DETAIL_ENTER_SPRING = { mass: 0.9, tension: 320, friction: 26 }

type ProgramDetailPanelProps = {
	programType: string
}

function isSafeHttpUrl(url: string | null | undefined): url is string {
	if (!url?.trim()) return false
	try {
		const parsed = new URL(url.trim())
		return parsed.protocol === "http:" || parsed.protocol === "https:"
	} catch {
		return false
	}
}

function displayProgramName(detail: ProgramDetail | null | undefined): string {
	const info = detail?.programInformation
	return (
		stripProgramFormalName(info?.formalName) ||
		info?.informalName?.trim() ||
		info?.abbrevName?.trim() ||
		detail?.programType?.trim() ||
		"Program"
	)
}

function humanizePartState(state: string | null | undefined): string | null {
	if (!state?.trim()) return null
	return state
		.replace(/([a-z])([A-Z])/g, "$1 $2")
		.replace(/_/g, " ")
		.trim()
}

function ProgramDetailSkeleton() {
	return (
		<div className="space-y-6" aria-busy aria-label="Loading program details">
			<div className="space-y-3">
				<Skeleton className="h-4 w-28" />
				<Skeleton className="h-9 w-2/3 max-w-md" />
			</div>
			<Skeleton className="h-40 w-full rounded-xl" />
			<Skeleton className="h-40 w-full rounded-xl" />
		</div>
	)
}

function CompletedSection({
	detail,
	name,
}: {
	detail: ProgramDetail
	name: string
}) {
	const completedOn = formatLongDate(
		detail.programCompletedDate?.slice(0, 10),
	)
	const badgeUrl = isSafeHttpUrl(detail.digitalBadgheURL)
		? detail.digitalBadgheURL.trim()
		: null
	const certUrl = isSafeHttpUrl(detail.certificateDownloadURL)
		? detail.certificateDownloadURL.trim()
		: null

	return (
		<section className="space-y-4">
			<Card className="gap-4 border-border py-5 shadow-none">
				<CardHeader className="px-5">
					<CardTitle className="font-heading text-xl tracking-wide">
						Congratulations
					</CardTitle>
				</CardHeader>
				<CardContent className="space-y-2 px-5">
					<p className="text-sm text-muted-foreground">
						You have completed the {name} Program
						{completedOn ? ` on ${completedOn}` : ""}.
					</p>
				</CardContent>
				{(badgeUrl || certUrl) && (
					<CardFooter className="flex flex-wrap gap-x-6 gap-y-2 px-5">
						{badgeUrl ? (
							<CardCta
								label="View digital badge"
								url={badgeUrl}
								isExternal
								newWindow
							/>
						) : null}
						{certUrl ? (
							<CardCta
								label="Download certificate"
								url={certUrl}
								isExternal
								newWindow
							/>
						) : null}
						<CardCta
							label="Directory settings"
							url="/membership?tab=directory"
							isExternal={false}
						/>
					</CardFooter>
				)}
				{!badgeUrl && !certUrl ? (
					<CardFooter className="px-5">
						<CardCta
							label="Directory settings"
							url="/membership?tab=directory"
							isExternal={false}
						/>
					</CardFooter>
				) : null}
			</Card>
		</section>
	)
}

function EnrollmentExpiredSection({
	detail,
	name,
}: {
	detail: ProgramDetail
	name: string
}) {
	const regOpen = detail.currentRegistrationIsOpen === true
	const registrationUrl = regOpen
		? programRegistrationHref(
				detail.programInformation?.registrationPath,
				detail.programType ?? name,
				false,
			)
		: null
	const nextDate = formatLongDate(
		detail.nextRegistrationOpenDate?.slice(0, 10),
	)
	const nextAdmin = detail.nextRegistrationAdminName?.trim()

	return (
		<section className="space-y-4">
			<Card className="gap-4 border-border py-5 shadow-none">
				<CardHeader className="px-5">
					<CardTitle className="font-heading text-xl tracking-wide">
						Enrollment expired
					</CardTitle>
				</CardHeader>
				<CardContent className="space-y-2 px-5">
					<p className="text-sm text-muted-foreground">
						Your {name} enrollment is no longer active.
					</p>
					{!regOpen && (nextAdmin || nextDate) ? (
						<p className="text-sm text-muted-foreground">
							{nextAdmin && nextDate
								? `${nextAdmin} registration will open on ${nextDate}.`
								: nextDate
									? `Registration will open on ${nextDate}.`
									: `${nextAdmin} registration is not open yet.`}
						</p>
					) : null}
				</CardContent>
				{registrationUrl ? (
					<CardFooter className="px-5">
						<CardCta
							label="Register Now"
							url={registrationUrl}
							isExternal
						/>
					</CardFooter>
				) : null}
			</Card>
		</section>
	)
}

function CvSubmissionSection({ detail }: { detail: ProgramDetail }) {
	const status = detail.cvStatus?.trim()
	return (
		<section>
			<Card className="gap-4 border-border py-5 shadow-none">
				<CardHeader className="px-5">
					<CardTitle className="font-heading text-xl tracking-wide">
						Work experience
					</CardTitle>
				</CardHeader>
				<CardContent className="space-y-2 px-5">
					<p className="text-sm text-muted-foreground">
						You have passed your exams. Next, submit your work
						experience for review.
					</p>
					{status ? (
						<p className="text-sm text-muted-foreground">
							Current status: {status}
						</p>
					) : null}
					<p className="text-sm text-muted-foreground">
						Online submission from this portal is not available yet.
					</p>
				</CardContent>
			</Card>
		</section>
	)
}

function ExamPartCard({ part, label }: { part: ExamPartInfo; label: string }) {
	const admin = part.examAttemptAdminName?.trim()
	const stateLabel = humanizePartState(part.examPartState)
	const payBy = formatLongDate(part.unpaidOrderPayByDate?.slice(0, 10))
	const examWhen = formatDateTime(part.schedulingExamDateTimeSelected)
	const resultsWhen = formatDateTime(part.resultsAvailableDateTime)
	const accessUrl = isSafeHttpUrl(part.schedulingExamAccessURL)
		? part.schedulingExamAccessURL.trim()
		: null
	const badgeUrl = isSafeHttpUrl(part.badgePageURL ?? part.badgeURL)
		? (part.badgePageURL ?? part.badgeURL)!.trim()
		: null

	const lines: string[] = []
	if (stateLabel) lines.push(stateLabel)
	if (part.unpaidOrderId) {
		lines.push(
			payBy
				? `You have an unpaid order. Please pay by ${payBy}.`
				: "You have an unpaid order for this exam part.",
		)
	}
	if (part.deferredAdminName?.trim()) {
		lines.push(`Deferred to ${part.deferredAdminName.trim()}.`)
	}
	if (part.schedulingExamProviderName?.trim()) {
		lines.push(`Provider: ${part.schedulingExamProviderName.trim()}`)
	}
	if (part.schedulingExamLocationSelected?.trim()) {
		lines.push(`Site: ${part.schedulingExamLocationSelected.trim()}`)
	}
	if (examWhen) {
		const tz = part.schedulingExamDateTimeZoneSelected?.trim()
		lines.push(tz ? `Exam: ${examWhen} (${tz})` : `Exam: ${examWhen}`)
	}
	if (part.resultsAvailableStatement?.trim()) {
		lines.push(part.resultsAvailableStatement.trim())
	} else if (resultsWhen) {
		lines.push(`Results available: ${resultsWhen}`)
	}
	if (part.result?.trim()) {
		lines.push(`Result: ${part.result.trim()}`)
	}

	return (
		<Card className="gap-4 border-border py-5 shadow-none">
			<CardHeader className="px-5">
				<CardTitle className="font-heading text-xl tracking-wide">
					{admin || label}
				</CardTitle>
			</CardHeader>
			<CardContent className="space-y-2 px-5">
				{lines.length > 0 ? (
					lines.map((line) => (
						<p key={line} className="text-sm text-muted-foreground">
							{line}
						</p>
					))
				) : (
					<p className="text-sm text-muted-foreground">
						No exam details are available for this part yet.
					</p>
				)}
			</CardContent>
			{(accessUrl || badgeUrl) && (
				<CardFooter className="flex flex-wrap gap-x-6 gap-y-2 px-5">
					{accessUrl ? (
						<CardCta
							label="Visit exam provider"
							url={accessUrl}
							isExternal
							newWindow
						/>
					) : null}
					{badgeUrl ? (
						<CardCta
							label="View badge"
							url={badgeUrl}
							isExternal
							newWindow
						/>
					) : null}
				</CardFooter>
			)}
		</Card>
	)
}

function ExamAttemptSection({ detail }: { detail: ProgramDetail }) {
	const parts: Array<{ part: ExamPartInfo; label: string }> = []
	if (detail.examPart1Info) {
		parts.push({ part: detail.examPart1Info, label: "Exam part 1" })
	}
	if (detail.examPart2Info) {
		parts.push({ part: detail.examPart2Info, label: "Exam part 2" })
	}

	if (parts.length === 0) {
		return (
			<p className="text-sm text-muted-foreground">
				No exam attempt details are available for this program yet.
			</p>
		)
	}

	return (
		<section className="space-y-4">
			{parts.map(({ part, label }) => (
				<ExamPartCard
					key={part.examAttemptId ?? label}
					part={part}
					label={label}
				/>
			))}
		</section>
	)
}

function DetailBody({ detail, name }: { detail: ProgramDetail; name: string }) {
	const state = detail.programState

	if (state === "Completed") {
		return <CompletedSection detail={detail} name={name} />
	}
	if (state === "EnrollmentExpired") {
		return <EnrollmentExpiredSection detail={detail} name={name} />
	}
	if (state === "CVSubmission") {
		return <CvSubmissionSection detail={detail} />
	}

	return <ExamAttemptSection detail={detail} />
}

function ProgramDetailPanelView({ programType }: ProgramDetailPanelProps) {
	const { data, isLoading, isError, error } = useProgramDetail(programType)
	const detail = data?.programsDetailInfo ?? null
	const title =
		!isLoading && detail
			? displayProgramName(detail)
			: programType.trim().toUpperCase() || "Program"

	const enter = useSpring({
		from: { opacity: 0, transform: "translateX(18px)" },
		to: { opacity: 1, transform: "translateX(0px)" },
		config: DETAIL_ENTER_SPRING,
	})

	return (
		<animated.div
			style={enter}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<ProgramsSubpageHeader title={title} />

			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <ProgramDetailSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						{error instanceof Error && error.message
							? error.message
							: "We couldn't load this program. Please try again later."}
					</p>
				) : null}

				{!isLoading && !isError && !detail ? (
					<p className="text-sm text-muted-foreground">
						No details were returned for this program.
					</p>
				) : null}

				{!isLoading && !isError && detail ? (
					<div className="pb-2">
						<DetailBody
							detail={detail}
							name={displayProgramName(detail)}
						/>
					</div>
				) : null}
			</div>
		</animated.div>
	)
}

/** Remount on type change so the enter spring re-runs between programs. */
function ProgramDetailPanel({ programType }: ProgramDetailPanelProps) {
	return (
		<ProgramDetailPanelView
			key={programType.trim().toLowerCase()}
			programType={programType}
		/>
	)
}

export { ProgramDetailPanel }
