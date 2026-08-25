import { useForm, useWatch } from "react-hook-form"

import type { ExamRegistrationLoad } from "@/api/registration/exam-types"
import type { PersonalInfoEditData } from "@/api/personal-info/types"
import { Button } from "@/components/atoms/button"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import {
	EMPTY_FRM_FORM_VALUES,
	toFrmFormValues,
	type FrmFormValues,
} from "@/components/forms/frm/frm-form-values"
import { AnimatedAmount } from "@/components/forms/frm/animated-amount"
import { RegistrationRail } from "@/components/forms/frm/sections/registration-rail"
import { YourDetailsSection } from "@/components/forms/frm/sections/your-details-section"
import { YourExamSection } from "@/components/forms/frm/sections/your-exam-section"
import { useExamRegistrationState } from "@/hooks/use-exam-registration"
import { submitLabel as submitLabelFor } from "@/lib/registration-presentation"

type FrmRegistrationFormProps = {
	load: ExamRegistrationLoad
	programType: string
	/** The member's own record, used to seed the form. Null while loading. */
	profile: PersonalInfoEditData | null
	regCode?: string
	/** Plays the page exit before Back navigates. */
	onNavigateBack: (run: () => void) => void
}

/**
 * FRM registration.
 *
 * Laid out as a checkout rather than as a stack of cards: the form runs down
 * the main column and the cart is pinned beside it, because every choice
 * re-prices and a total the candidate has to scroll to find is a total nobody
 * checks. The submit sits in the header with the total, so the commitment and
 * its price are always on screen together.
 *
 * Mounted only once both the payload and the profile exist — react-hook-form
 * seeds `defaultValues` at mount, and re-seeding a live form does not reach
 * the Radix selects, which would keep their placeholder and post empty strings
 * over prefilled values.
 */
function FrmRegistrationForm({
	load,
	programType,
	profile,
	regCode,
	onNavigateBack,
}: FrmRegistrationFormProps) {
	const {
		control,
		register,
		formState: { errors },
	} = useForm<FrmFormValues>({
		defaultValues: profile ? toFrmFormValues(profile) : EMPTY_FRM_FORM_VALUES,
		mode: "onSubmit",
	})

	// `useWatch`, not the destructured `watch()` — the latter returns a fresh
	// function each render, which opts the whole component out of memoization.
	const country = useWatch({ control, name: "country" })
	const mobilePhoneCode = useWatch({ control, name: "mobilePhoneCode" })

	const state = useExamRegistrationState({
		load,
		programType,
		regCode,
		billingCountry: country,
		mobilePhoneCode,
	})

	const { fees } = state
	const currency = fees?.currencyCode || "USD"
	const label = submitLabelFor(fees?.hasBilling === true, "")

	return (
		<form
			className="flex flex-col gap-6"
			onSubmit={(event) => event.preventDefault()}
			noValidate
		>
			{/*
			 * One bar: where you came from, what you are doing, what it costs and
			 * the commitment. Folding Back into it keeps all of that on a single
			 * line, leaving the viewport for the form itself.
			 *
			 * Two things here are deliberate and easy to "tidy" back into bugs:
			 * it is fully opaque, because content scrolling under a translucent
			 * bar reads as a rendering fault rather than as depth; and it has no
			 * negative margin, because bleeding it past the container makes it
			 * wider than its scroll parent, which buys a few pixels of horizontal
			 * scroll and clips the back arrow.
			 */}
			<div className="sticky top-0 z-30 flex flex-wrap items-center justify-between gap-x-6 gap-y-3 bg-background py-3">
				<div className="flex min-w-0 items-center gap-4">
					<ProgramsSubpageHeader onNavigateBack={onNavigateBack} />
					<div
						className="hidden h-6 w-px shrink-0 bg-border sm:block"
						aria-hidden
					/>
					<h2 className="truncate font-heading text-xl font-semibold">
						Register for the FRM Exam
					</h2>
				</div>

				<div className="flex items-center gap-4">
					{/*
					 * Always rendered, and pinned to the button's own height.
					 *
					 * Both halves of that matter. Rendering it only once a total
					 * exists made the whole bar grow the moment pricing landed; and
					 * stacked at their natural line heights the label and figure came
					 * to 48px against the button's 40px, so the bar was sized by the
					 * taller of the two. Fixing the height means neither the arrival
					 * of a price nor a longer figure can move anything.
					 */}
					<div
						className="flex h-10 shrink-0 flex-col items-end justify-center text-right"
						aria-live="polite"
						aria-busy={state.isPricing}
					>
						<p className="text-caption leading-none text-muted-foreground">
							{state.isPricing ? "Updating…" : "Total"}
						</p>
						{fees?.total != null ? (
							<AnimatedAmount
								amount={fees.total}
								currency={currency}
								pending={state.isPricing}
								className="text-lg leading-tight font-semibold text-primary"
							/>
						) : (
							<span className="text-lg leading-tight font-semibold text-muted-foreground">
								&mdash;
							</span>
						)}
					</div>
					{/*
					 * Present but inert: submitting needs the address, payment and
					 * consent steps that are not built yet, and a button that looked
					 * ready would misrepresent how far along this is.
					 */}
					<Button type="submit" size="lg" disabled>
						{label}
					</Button>
				</div>
			</div>

			<div className="grid grid-cols-1 gap-6 lg:grid-cols-10">
				<div className="flex flex-col gap-6 lg:col-span-7">
					<YourDetailsSection
						register={register}
						control={control}
						errors={errors}
						countries={load.countries}
					/>

					<YourExamSection
						partsAvailable={load.examSelection?.partsAvailable ?? []}
						partSelected={state.selection.partSelected}
						onSelectPart={state.selectPart}
						part1Title={state.part1?.title || "Part I"}
						part2Title={state.part2?.title || "Part II"}
						part1Admins={state.part1Admins}
						part2Admins={state.part2Admins}
						selection={state.selection}
						part1Active={state.part1Active}
						part2Active={state.part2Active}
						onSelectAdmin={state.selectAdmin}
						onSelectSite={state.selectSite}
						outOfOrder={state.outOfOrder}
					/>
				</div>

				{/*
				 * `h-fit` + `sticky` is what pins the rail: it sizes to its content
				 * and stays put while the main column scrolls past it.
				 */}
				<aside className="lg:sticky lg:top-28 lg:col-span-3 lg:h-fit">
					<RegistrationRail
						materials={state.visibleMaterials}
						onToggleMaterial={state.toggleMaterial}
						fees={fees}
						isPricing={state.isPricing}
					/>
				</aside>
			</div>
		</form>
	)
}

export { FrmRegistrationForm }
