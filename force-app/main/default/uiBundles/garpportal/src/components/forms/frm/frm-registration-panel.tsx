import { AppError } from "@/api/client"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import {
	Card,
	CardContent,
	CardHeader,
} from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { FrmRegistrationForm } from "@/components/forms/frm/frm-registration-form"
import { useCurrentUser } from "@/hooks/use-current-user"
import { useExamRegistrationLoad } from "@/hooks/use-exam-registration"
import { usePersonalInfoEditData } from "@/hooks/use-personal-info-edit-data"
import { cn } from "@/lib/utils"

type FrmRegistrationPanelProps = {
	programType: string
	regCode?: string
	/** Plays the page exit before Back navigates. */
	onNavigateBack: (run: () => void) => void
}

/**
 * The page's own shape, greyed out.
 *
 * Mirrors the real layout field for field — two columns, the same card
 * boundaries, the same header bar — so the form does not jump or reflow when
 * the data lands. A generic block skeleton loads faster to write and then
 * makes every arrival feel like a lurch.
 */
function SkeletonField({ className }: { className?: string }) {
	return (
		<div className={cn("flex flex-col gap-2", className)}>
			<Skeleton className="h-4 w-24" />
			<Skeleton className="h-9 w-full rounded-xl" />
		</div>
	)
}

function SkeletonCard({
	rows,
	className,
}: {
	rows: React.ReactNode
	className?: string
}) {
	return (
		<Card className={className}>
			<CardHeader>
				<Skeleton className="h-5 w-40" />
			</CardHeader>
			<CardContent>{rows}</CardContent>
		</Card>
	)
}

function RegistrationSkeleton() {
	return (
		<div className="flex flex-col gap-6" aria-busy aria-live="polite">
			<span className="sr-only">Loading your registration…</span>

			{/* The header bar: back link, title, total, submit. */}
			<div className="flex flex-wrap items-center justify-between gap-4 py-3">
				<div className="flex items-center gap-4">
					<Skeleton className="h-6 w-28" />
					<Skeleton className="h-6 w-64" />
				</div>
				<div className="flex items-center gap-4">
					<Skeleton className="h-10 w-24" />
					<Skeleton className="h-11 w-40 rounded-xl" />
				</div>
			</div>

			<div className="grid grid-cols-1 gap-6 lg:grid-cols-10">
				<div className="flex flex-col gap-6 lg:col-span-7">
					<SkeletonCard
						rows={
							<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
								<SkeletonField />
								<SkeletonField />
								<SkeletonField />
								<SkeletonField />
								<SkeletonField className="sm:col-span-2" />
							</div>
						}
					/>
					<SkeletonCard
						rows={
							<div className="flex flex-col gap-4">
								<SkeletonField />
								<Skeleton className="h-32 w-full rounded-xl" />
							</div>
						}
					/>
				</div>

				<div className="flex flex-col gap-4 lg:col-span-3">
					<SkeletonCard
						rows={
							<div className="flex flex-col gap-2">
								<Skeleton className="h-20 w-full rounded-xl" />
								<Skeleton className="h-20 w-full rounded-xl" />
							</div>
						}
					/>
					<SkeletonCard
						rows={
							<div className="flex flex-col gap-3">
								{Array.from({ length: 4 }).map((_, index) => (
									<Skeleton key={index} className="h-5 w-full rounded-lg" />
								))}
							</div>
						}
					/>
				</div>
			</div>
		</div>
	)
}

/**
 * Owns the two reads the form needs, and decides whether there is a form to
 * show at all.
 *
 * The registration payload answers three different things over one request:
 * the form data, a refusal (`isEligible: false` — a closed window, or a reg
 * code that resolved to nothing, both HTTP 200), and an actual failure. The
 * refusal carries its own sentence, so it is shown as a message rather than an
 * error state.
 *
 * The profile read is separate and deliberately non-blocking in spirit — but
 * the form still waits for it, because seeding react-hook-form after mount
 * does not reach the Radix selects.
 */
function FrmRegistrationPanel({
	programType,
	regCode,
	onNavigateBack,
}: FrmRegistrationPanelProps) {
	const load = useExamRegistrationLoad(programType, regCode)
	const currentUser = useCurrentUser()
	const contactId = currentUser.data?.contactId ?? ""
	const profile = usePersonalInfoEditData(contactId, Boolean(contactId))

	if (load.isPending || profile.isPending) return <RegistrationSkeleton />

	if (load.isError) {
		return (
			<Alert variant="destructive">
				<AlertTitle>Unable to open registration</AlertTitle>
				<AlertDescription>
					{AppError.fromUnknown(load.error).messages[0]}
				</AlertDescription>
			</Alert>
		)
	}

	const data = load.data
	if (data.eligibility?.isEligible === false) {
		return (
			<Alert>
				<AlertTitle>Registration unavailable</AlertTitle>
				<AlertDescription>
					{data.eligibility.message ??
						"Registration is not currently open for this exam."}
				</AlertDescription>
			</Alert>
		)
	}

	return (
		<FrmRegistrationForm
			load={data}
			programType={programType}
			regCode={regCode}
			onNavigateBack={onNavigateBack}
			// A missing profile is not fatal — the form renders empty and the
			// member fills it in, which beats blocking registration on a
			// secondary read.
			profile={profile.data ?? null}
		/>
	)
}

export { FrmRegistrationPanel }
