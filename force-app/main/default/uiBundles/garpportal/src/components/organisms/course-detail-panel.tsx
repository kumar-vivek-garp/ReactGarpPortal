import { animated } from "@react-spring/web"
import { BookOpen, CalendarClock, ExternalLink } from "lucide-react"

import type { CourseDetail } from "@/api/courses"
import { Card } from "@/components/atoms/card"
import { ProgramDetailHero } from "@/components/molecules/program-detail-hero"
import { ProgramDetailSkeleton } from "@/components/molecules/page-pending"
import { ProgramJourney } from "@/components/molecules/program-journey"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { COURSE_UNAVAILABLE } from "@/config/courses"
import { localizeProgramLogoUrl } from "@/config/program-logos"
import { useCourseDetail } from "@/hooks/use-course-detail"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { formatLongDate } from "@/lib/account-format"
import {
	buildCourseDetailPresentation,
	courseHasExam,
	courseRetakeCopy,
} from "@/lib/course-detail-presentation"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"

function asDate(iso: string | null | undefined): string | null {
	const value = iso?.trim()
	if (!value) return null
	return formatLongDate(value.slice(0, 10))
}

function InfoRow({ label, value }: { label: string; value: string | null }) {
	if (!value) return null
	return (
		<div className="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1 py-2">
			<dt className="text-sm text-muted-foreground">{label}</dt>
			<dd className="text-sm text-foreground">{value}</dd>
		</div>
	)
}

function SectionCard({
	icon: Icon,
	title,
	children,
}: {
	icon: typeof BookOpen
	title: string
	children: React.ReactNode
}) {
	return (
		<Card className="gap-0 px-5 py-4 shadow-none">
			<h2 className="flex items-center gap-2 font-heading text-base font-semibold tracking-wide text-foreground">
				<Icon className="size-4 shrink-0 text-primary" aria-hidden />
				{title}
			</h2>
			<dl className="mt-2 divide-y divide-border/70">{children}</dl>
		</Card>
	)
}

function CourseUnavailable() {
	const Icon = COURSE_UNAVAILABLE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{COURSE_UNAVAILABLE.title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{COURSE_UNAVAILABLE.message}
			</p>
		</div>
	)
}

function CourseBody({ detail }: { detail: CourseDetail }) {
	const presentation = buildCourseDetailPresentation(detail)
	const logoUrl = localizeProgramLogoUrl(
		resolvePortalAssetUrl(detail.programInformation?.myProgramsLogoURL) ??
			detail.programInformation?.myProgramsLogoURL,
	)
	const hasExam = courseHasExam(detail)
	const retake = courseRetakeCopy(
		detail,
		(iso) => formatLongDate(iso.slice(0, 10)) ?? iso,
	)

	return (
		<div className="space-y-6 pb-2">
			<ProgramDetailHero presentation={presentation} logoUrl={logoUrl} />

			<div className="grid items-start gap-6 app:grid-cols-[minmax(0,1fr)_minmax(16rem,22rem)]">
				<div className="flex min-w-0 flex-col gap-5">
					<ProgramJourney milestones={presentation.milestones} />

					<SectionCard icon={BookOpen} title="Your course">
						<InfoRow
							label="Learning platform"
							value={detail.eLearningPlatformName}
						/>
						<InfoRow
							label="Access until"
							value={asDate(detail.eLearningPlatformExpiresOnDate)}
						/>
						<InfoRow label="eBook" value={detail.eBookKey ? "Available" : null} />
						<InfoRow
							label="eBook expires"
							value={asDate(detail.eBookExpireDate)}
						/>
						<InfoRow
							label="Enrolled"
							value={asDate(detail.programRegisteredOnDate)}
						/>
						<InfoRow
							label="Enrolment ends"
							value={asDate(detail.programExpireDate)}
						/>
					</SectionCard>

					{/*
					 * Omitted entirely rather than rendered empty: FFR has no exam at
					 * all, and Apex returns before it ever looks for a sitting.
					 */}
					{hasExam ? (
						<SectionCard icon={CalendarClock} title="Exam">
							<InfoRow label="Provider" value={detail.onlineExamProviderName} />
							<InfoRow
								label="Scheduled"
								value={
									detail.scheduledExamDateTime
										? `${asDate(detail.scheduledExamDateTime)}${
												detail.scheduledExamDateTimeZone
													? ` (${detail.scheduledExamDateTimeZone})`
													: ""
											}`
										: null
								}
							/>
							<InfoRow label="Mode" value={detail.scheduledExamMode} />
							<InfoRow label="Location" value={detail.scheduledExamLocation} />
							<InfoRow label="Sat on" value={asDate(detail.examTakenDate)} />
							<InfoRow label="Result" value={detail.examResult} />
							<InfoRow label="Retake" value={retake} />
						</SectionCard>
					) : null}
				</div>

				<div className="hidden app:block">
					<div className="sticky top-4">
						{detail.onlineExamSchedulingInformationPageURL ? (
							<Card className="gap-2 px-5 py-4 shadow-none">
								<h2 className="font-heading text-base font-semibold tracking-wide text-foreground">
									Exam information
								</h2>
								<a
									href={detail.onlineExamSchedulingInformationPageURL}
									target="_blank"
									rel="noreferrer noopener"
									className="inline-flex items-center gap-1.5 text-sm font-semibold text-primary hover:underline"
								>
									How scheduling works
									<ExternalLink className="size-4" aria-hidden />
								</a>
							</Card>
						) : null}
					</div>
				</div>
			</div>
		</div>
	)
}

function CourseDetailPanelView({ courseType }: { courseType: string }) {
	const { data, isLoading, isError, error } = useCourseDetail(courseType)
	const { style, exit } = useSubpageTransition()

	return (
		<animated.div
			style={style}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<ProgramsSubpageHeader
				title={isLoading || data ? undefined : "Course"}
				onNavigateBack={exit}
			/>

			<div className="mt-4 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <ProgramDetailSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						{error instanceof Error && error.message
							? error.message
							: "We couldn't load this course. Please try again later."}
					</p>
				) : null}

				{/*
				 * Apex answers all three of its refusals — invalid code, no contract,
				 * no sitting — with a payload, which `fetchCourseDetail` turns into
				 * null. None of them is an error the member can act on by retrying.
				 */}
				{!isLoading && !isError && !data ? <CourseUnavailable /> : null}

				{!isLoading && !isError && data ? <CourseBody detail={data} /> : null}
			</div>
		</animated.div>
	)
}

/** Remount on type change so the enter spring re-runs between courses. */
function CourseDetailPanel({ courseType }: { courseType: string }) {
	return (
		<CourseDetailPanelView
			key={courseType.trim().toLowerCase()}
			courseType={courseType}
		/>
	)
}

export { CourseDetailPanel }
