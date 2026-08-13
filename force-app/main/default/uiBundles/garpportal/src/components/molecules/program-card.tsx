import type {
	CompletedProgram,
	EnrolledProgram,
	OtherProgram,
	ProgramInformation,
} from "@/api/programs"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { formatLongDate } from "@/lib/account-format"
import { stripProgramFormalName } from "@/lib/program-formal-name"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

type ProgramCardVariant = "inProgress" | "completed" | "other"

type ProgramCardProps = {
	variant: ProgramCardVariant
	program: EnrolledProgram | CompletedProgram | OtherProgram
	className?: string
}

function displayName(info: ProgramInformation | null | undefined): string {
	return (
		stripProgramFormalName(info?.formalName) ||
		info?.informalName?.trim() ||
		info?.abbrevName?.trim() ||
		"Program"
	)
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

function adminLines(program: EnrolledProgram | CompletedProgram | OtherProgram) {
	if (!("adminPartIName" in program)) return []
	return [program.adminPartIName, program.adminPartIIName].filter(
		(line): line is string => Boolean(line?.trim()),
	)
}

function nextOpenCopy(program: OtherProgram): string | null {
	if (program.isRegistrationOpen) return null
	const date =
		formatLongDate(program.nextRegistrationOpenDate?.slice(0, 10)) ??
		null
	const admin = program.nextRegistrationOpenAdminName?.trim()
	if (admin && date) return `${admin} registration will open on ${date}`
	if (date) return `Registration will open on ${date}`
	if (admin) return `${admin} registration is not open yet.`
	return null
}

function ProgramCard({ variant, program, className }: ProgramCardProps) {
	const info = program.programInformation
	const name = displayName(info)
	const logoUrl =
		resolvePortalAssetUrl(info?.myProgramsLogoURL) ??
		info?.myProgramsLogoURL ??
		undefined
	const admins = variant === "inProgress" ? adminLines(program) : []
	const description =
		variant === "other" ? info?.description?.trim() || null : null
	const closedLine =
		variant === "other" && "isRegistrationOpen" in program
			? nextOpenCopy(program)
			: null
	const policyUrl = isSafeHttpUrl(info?.policyURL) ? info.policyURL : null
	const showFooter = variant === "other"

	return (
		<Card
			className={cn(
				"h-full gap-4 overflow-hidden border-border py-0 shadow-none",
				className,
			)}
		>
			<div className="flex h-44 items-center justify-center bg-muted/40 p-4">
				{logoUrl ? (
					<img
						src={logoUrl}
						alt=""
						className="max-h-full max-w-full rounded-xl object-contain"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				) : null}
			</div>

			<CardHeader className="px-5 pt-1">
				<CardTitle className="font-heading text-lg leading-snug tracking-wide text-foreground">
					{name}
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-2 px-5">
				{variant === "completed" ? (
					<p className="text-sm text-muted-foreground">
						Congratulations! You have completed the {name} Program.
					</p>
				) : null}

				{admins.map((line) => (
					<p key={line} className="text-sm text-muted-foreground">
						{line}
					</p>
				))}

				{description ? (
					<p className="text-sm text-muted-foreground">{description}</p>
				) : null}

				{closedLine ? (
					<p className="text-sm text-muted-foreground">{closedLine}</p>
				) : null}
			</CardContent>

			{showFooter ? (
				<CardFooter className="mt-auto flex flex-wrap items-center gap-x-6 gap-y-2 px-5 pb-5">
					<CardCta
						label="Register Now"
						url="#"
						isExternal={false}
						disabled
					/>
					{policyUrl ? (
						<CardCta
							label="Learn More"
							url={policyUrl}
							isExternal
							newWindow
						/>
					) : null}
				</CardFooter>
			) : (
				<div className="pb-5" />
			)}
		</Card>
	)
}

export { ProgramCard }
