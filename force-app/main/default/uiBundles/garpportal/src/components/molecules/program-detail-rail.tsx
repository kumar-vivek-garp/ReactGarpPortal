import { Link } from "@tanstack/react-router"
import {
	Bell,
	BookOpen,
	CalendarClock,
	ExternalLink,
	IdCard,
} from "lucide-react"

import type {
	ExamDeadline,
	ExamResources,
	ProgramDetail,
	ProgramExamNotification,
} from "@/api/programs"
import {
	Accordion,
	AccordionContent,
	AccordionItem,
	AccordionTrigger,
} from "@/components/atoms/accordion"
import { Button } from "@/components/atoms/button"
import { AccountFieldGrid } from "@/components/molecules/account-field-grid"
import { formatLongDate } from "@/lib/account-format"
import {
	programLearnMoreUrl,
	programTypeSlug,
	resolveExperienceHref,
} from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

type DeadlineItem = {
	key: string
	date: string
	labels: string[]
	urgent: boolean
}

function parseIsoDate(value: string): Date | null {
	const [year, month, day] = value.slice(0, 10).split("-").map(Number)
	if (!year || !month || !day) return null
	return new Date(year, month - 1, day)
}

function daysUntil(iso: string): number | null {
	const date = parseIsoDate(iso)
	if (!date) return null
	const today = new Date()
	today.setHours(0, 0, 0, 0)
	return Math.ceil((date.getTime() - today.getTime()) / 86_400_000)
}

/** Flatten + sort deadlines soonest-first; merge labels sharing a date. */
export function flattenDeadlines(
	deadlines: ExamDeadline[] | null | undefined,
): DeadlineItem[] {
	const byDate = new Map<string, DeadlineItem>()

	for (const dl of deadlines ?? []) {
		const push = (iso: string | null | undefined, label: string) => {
			if (!iso?.trim()) return
			const key = iso.slice(0, 10)
			const existing = byDate.get(key)
			const urgent = (daysUntil(key) ?? 999) <= 14
			if (existing) {
				if (!existing.labels.includes(label)) existing.labels.push(label)
				existing.urgent = existing.urgent || urgent
			} else {
				byDate.set(key, {
					key,
					date: key,
					labels: [label],
					urgent,
				})
			}
		}

		push(dl.ADADeadline, "ADA Application Deadline")
		push(dl.deferalDeadline, "Last Day to Defer")
		push(dl.deferalDeadline, "Last Day to Complete Payment")
		push(dl.schedulingDeadline, "Last Day to Schedule")
	}

	return [...byDate.values()].sort((a, b) => a.date.localeCompare(b.date))
}

function DeadlinesBlock({ items }: { items: DeadlineItem[] }) {
	if (items.length === 0) return null
	return (
		<section className="rounded-xl border border-border bg-muted/40 p-5">
			<h2 className="flex items-center gap-2 font-heading text-lg tracking-wide text-foreground">
				<CalendarClock className="size-5 shrink-0 text-primary" aria-hidden />
				Deadlines
			</h2>
			<ul className="mt-4 space-y-4">
				{items.map((item) => (
					<li key={item.key}>
						<p
							className={cn(
								"text-sm font-semibold",
								item.urgent ? "text-accent-vermillion" : "text-foreground",
							)}
						>
							{formatLongDate(item.date)}
							{item.urgent ? (
								<span className="ml-2 text-xs font-medium uppercase tracking-wide">
									Soon
								</span>
							) : null}
						</p>
						{item.labels.map((label) => (
							<p key={label} className="text-sm text-muted-foreground">
								{label}
							</p>
						))}
					</li>
				))}
			</ul>
		</section>
	)
}

function NotificationsBlock({
	notifications,
}: {
	notifications: ProgramExamNotification[]
}) {
	const items = notifications.filter(
		(n) => n.notificationTitle?.trim() || n.notificationDetails?.trim(),
	)
	if (items.length === 0) return null

	return (
		<section className="rounded-xl border border-border bg-muted/40 p-5">
			<h2 className="flex items-center gap-2 font-heading text-lg tracking-wide text-foreground">
				<Bell className="size-5 shrink-0 text-primary" aria-hidden />
				Notifications
			</h2>
			<ul className="mt-4 space-y-4">
				{items.map((n, index) => (
					<li
						key={`${n.notificationTitle ?? "n"}-${n.notificationDate ?? index}`}
						className="rounded-lg border border-border/60 bg-background/50 p-3"
					>
						{n.notificationTitle ? (
							<p className="text-sm font-semibold text-foreground">
								{n.notificationTitle}
							</p>
						) : null}
						{n.notificationDetails ? (
							<p className="mt-1 text-sm text-muted-foreground">
								{n.notificationDetails}
							</p>
						) : null}
						{n.notificationDate ? (
							<p className="mt-1 text-xs text-muted-foreground">
								{formatLongDate(n.notificationDate.slice(0, 10)) ??
									n.notificationDate}
							</p>
						) : null}
					</li>
				))}
			</ul>
		</section>
	)
}

function ResourceLinkRow({
	href,
	to,
	label,
	via,
	children,
	external,
}: {
	href?: string
	to?: string
	label: string
	via?: string
	children: string
	external?: boolean
}) {
	const linkClass =
		"inline-flex items-center gap-1 text-sm font-semibold text-primary hover:text-primary/80"

	return (
		<div>
			{to ? (
				<Link to={to} className={linkClass}>
					{label}
				</Link>
			) : (
				<a
					href={href}
					className={linkClass}
					{...(external
						? { target: "_blank", rel: "noreferrer noopener" }
						: {})}
				>
					{label}
					{external ? (
						<ExternalLink className="size-3.5" aria-hidden />
					) : null}
				</a>
			)}
			{via ? (
				<p className="mt-0.5 text-sm font-semibold text-foreground">{via}</p>
			) : null}
			<p className="mt-0.5 text-sm text-muted-foreground">{children}</p>
		</div>
	)
}

function ResourcesBlock({
	resources,
	programType,
}: {
	resources: ExamResources | null | undefined
	programType: string
}) {
	const slug = programTypeSlug(programType)
	const marketing = slug === "riskai" ? "rai" : slug
	const glpUrl = resolveExperienceHref(resources?.eLearningPlatformAccessURL)
	const adaUrl = resolveExperienceHref(resources?.ADAFormAccessURL)
	const errataUrl =
		programLearnMoreUrl(marketing) ?? `https://www.garp.org/${marketing}`
	const via = resources?.eLearningPlatformName?.trim()
		? `via ${resources.eLearningPlatformName.trim()}`
		: undefined

	return (
		<section className="rounded-xl border border-border bg-muted/40 p-5">
			<h2 className="flex items-center gap-2 font-heading text-lg tracking-wide text-foreground">
				<BookOpen className="size-5 shrink-0 text-primary" aria-hidden />
				Exam Resources
			</h2>
			<div className="mt-4 space-y-5">
				{glpUrl ? (
					<ResourceLinkRow
						href={glpUrl}
						label="GARP Learning Platform"
						via={via}
						external
					>
						Practice exams, multimedia content, and more.
					</ResourceLinkRow>
				) : null}
				<ResourceLinkRow to="/study-materials" label="Study Materials">
					Official documents to help you prepare for your Exam
				</ResourceLinkRow>
				<ResourceLinkRow href={errataUrl} label="Submit Errata" external>
					Report an error or discrepancy in the curriculum.
				</ResourceLinkRow>
				{adaUrl ? (
					<div className="rounded-xl border border-primary/25 bg-accent/50 p-4">
						<p className="text-sm font-semibold text-foreground">
							ADA accommodations
						</p>
						<p className="mt-1 text-sm text-muted-foreground">
							Request testing accommodations for your exam.
						</p>
						<Button asChild size="sm" className="mt-3 rounded-full px-5">
							<a
								href={adaUrl}
								target="_blank"
								rel="noreferrer noopener"
							>
								ADA Application
							</a>
						</Button>
					</div>
				) : null}
				<hr className="border-border" />
				<a
					href="https://www.garp.org/exam-prep-providers"
					target="_blank"
					rel="noreferrer noopener"
					className="text-sm font-semibold text-primary hover:text-primary/80"
				>
					Need Help Studying?
				</a>
			</div>
		</section>
	)
}

function MemberDetailsBlock({ detail }: { detail: ProgramDetail }) {
	const phone = [detail.phoneCode, detail.phoneNumber]
		.filter(Boolean)
		.join(" ")
		.trim()

	const idRows = [
		{ label: "Name", value: detail.IDName },
		{ label: "ID type", value: detail.IDType },
		{ label: "ID number", value: detail.IDNumber },
		{ label: "ID location", value: detail.IDLocation },
		{
			label: "ID expiry",
			value: detail.IDExpireDate
				? formatLongDate(detail.IDExpireDate.slice(0, 10))
				: null,
		},
		{ label: "Phone", value: phone || null, span: 2 as const },
	]

	const ostaRows =
		detail.isOSTACandidate === true
			? [
					{ label: "Name (Chinese)", value: detail.OSTANameInChinese },
					{
						label: "Date of birth",
						value: detail.OSTADateOfBirth
							? formatLongDate(detail.OSTADateOfBirth.slice(0, 10))
							: null,
					},
					{ label: "Gender", value: detail.OSTAGender },
					{ label: "Phone", value: detail.OSTAPhoneNumber },
					{ label: "Working status", value: detail.OSTAWorkingStatus },
					{ label: "Company", value: detail.OSTACompany },
					{
						label: "Educational status",
						value: detail.OSTAEducationalStatus,
					},
					{ label: "School", value: detail.OSTAEducationalSchool },
					{ label: "Program", value: detail.OSTAEducationalProgram },
				]
			: []

	const hasId = idRows.some((r) => r.value)
	const hasOsta = ostaRows.some((r) => r.value)
	if (!hasId && !hasOsta) return null

	return (
		<section className="rounded-xl border border-border bg-muted/40 p-5">
			<h2 className="flex items-center gap-2 font-heading text-lg tracking-wide text-foreground">
				<IdCard className="size-5 shrink-0 text-primary" aria-hidden />
				Member details
			</h2>
			{hasId ? (
				<div className="mt-4">
					<p className="mb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
						ID information
					</p>
					<AccountFieldGrid rows={idRows} emptyMessage="No ID on file." />
				</div>
			) : null}
			{hasOsta ? (
				<div className="mt-5">
					<p className="mb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
						OSTA details
					</p>
					<AccountFieldGrid rows={ostaRows} />
				</div>
			) : null}
		</section>
	)
}

type ProgramDetailRailProps = {
	detail: ProgramDetail
	/**
	 * `full` — desktop rail (default).
	 * `urgent` — notifications + deadlines only (mobile priority zone).
	 * `secondary` — resources + member details only (mobile accordion).
	 */
	variant?: "full" | "urgent" | "secondary"
	className?: string
}

function ProgramDetailRail({
	detail,
	variant = "full",
	className,
}: ProgramDetailRailProps) {
	const deadlines = flattenDeadlines(detail.examDeadlines)
	const notifications = detail.examNotifications ?? []

	if (variant === "urgent") {
		return (
			<div className={cn("space-y-5", className)}>
				<NotificationsBlock notifications={notifications} />
				<DeadlinesBlock items={deadlines} />
			</div>
		)
	}

	const secondary = (
		<>
			<ResourcesBlock
				resources={detail.examResources}
				programType={detail.programType ?? ""}
			/>
			<MemberDetailsBlock detail={detail} />
		</>
	)

	if (variant === "secondary") {
		return (
			<div className={cn(className)}>
				<Accordion
					type="multiple"
					defaultValue={["resources"]}
					className="rounded-xl border border-border px-4"
				>
					<AccordionItem value="resources">
						<AccordionTrigger>
							Exam resources & member details
						</AccordionTrigger>
						<AccordionContent className="space-y-5">
							{secondary}
						</AccordionContent>
					</AccordionItem>
				</Accordion>
			</div>
		)
	}

	return (
		<aside className={cn("flex flex-col gap-5", className)}>
			<NotificationsBlock notifications={notifications} />
			<DeadlinesBlock items={deadlines} />
			{secondary}
		</aside>
	)
}

export { ProgramDetailRail }
