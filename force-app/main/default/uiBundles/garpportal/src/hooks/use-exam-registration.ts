import { useCallback, useMemo, useState } from "react"
import { keepPreviousData, useQuery } from "@tanstack/react-query"

import type {
	ExamRegistrationLoad,
	StudyMaterialView,
} from "@/api/registration/exam-types"
import {
	examFeesQueryOptions,
	examRegistrationQueryOptions,
} from "@/api/registration/query-options"
import { useDebouncedValue } from "@/hooks/use-debounced-value"
import {
	buildFeesRequest,
	emptySelection,
	type ExamSelectionState,
	type RegistrationAddress,
} from "@/lib/registration-payloads"
import {
	findAdmin,
	findPart,
	findSite,
	isOstaRequired,
	isOutOfOrder,
	isPart1Active,
	isPart2Active,
	resolvePartSelection,
	sortAdmins,
	visibleStudyMaterials,
} from "@/lib/registration-presentation"

/** A study material plus the candidate's cart tick. */
export type SelectableMaterial = StudyMaterialView & { selected: boolean }

/** How long the cart sits still before it is re-priced. */
const FEES_DEBOUNCE_MS = 400

/** Opens the form's load query. The form must not mount until this resolves. */
export function useExamRegistrationLoad(
	programType: string,
	regCode?: string,
	courseCode?: string,
) {
	return useQuery(examRegistrationQueryOptions(programType, regCode, courseCode))
}

type ExamRegistrationStateArgs = {
	load: ExamRegistrationLoad
	programType: string
	regCode?: string
	courseCode?: string
	/**
	 * Pricing inputs the form owns (react-hook-form), not this hook.
	 *
	 * These are real fields now, not placeholders: the payment type decides
	 * whether Apex adds the wire/ACH processing fee and computes tax locally,
	 * and the address decides shipping — so a stale value here means a total
	 * that does not match the order.
	 */
	billingCountry: string
	mobilePhoneCode: string
	paymentType: string
	billingAddress: RegistrationAddress
	shippingAddress: RegistrationAddress
	billingAndShippingSame: boolean
	autoRenew: boolean
}

/**
 * Everything the form derives from a resolved load payload: the exam
 * selection, the study-material cart, and the priced total.
 *
 * The selection and cart are plain state rather than form fields because they
 * are not text a candidate types — they are choices with cascading rules (a
 * new sitting invalidates the site, a dropped part drops its books). The typed
 * fields stay with react-hook-form; the pricing inputs it owns are passed in.
 */
export function useExamRegistrationState({
	load,
	programType,
	regCode,
	courseCode,
	billingCountry,
	mobilePhoneCode,
	paymentType,
	billingAddress,
	shippingAddress,
	billingAndShippingSame,
	autoRenew,
}: ExamRegistrationStateArgs) {
	const [selection, setSelection] = useState<ExamSelectionState>(() => {
		const base = emptySelection()
		const available = load.examSelection?.partsAvailable ?? []
		// One option is not a choice — pre-select it and state it, rather than
		// rendering a select with a single entry.
		if (available.length === 1) base.partSelected = available[0]
		return base
	})

	const [materials, setMaterials] = useState<SelectableMaterial[]>(() =>
		(load.studyMaterials ?? []).map((material) => ({
			...material,
			selected: false,
		})),
	)

	const part1Active = isPart1Active(selection.partSelected)
	const part2Active = isPart2Active(selection.partSelected)

	const part1 = findPart(load.examSelection?.parts, "part1")
	const part2 = findPart(load.examSelection?.parts, "part2")
	const part1Admins = useMemo(() => sortAdmins(part1?.admins ?? []), [part1])
	const part2Admins = useMemo(() => sortAdmins(part2?.admins ?? []), [part2])

	// What is actually in force, defaults applied — never the raw clicks. The
	// cart, the sections and the payload all read this, so they cannot disagree.
	const effective = useMemo(
		() => ({
			partSelected: selection.partSelected,
			part1: resolvePartSelection(part1Active, selection.part1, part1Admins),
			part2: resolvePartSelection(part2Active, selection.part2, part2Admins),
		}),
		[selection, part1Active, part2Active, part1Admins, part2Admins],
	)

	const admin1 = findAdmin(part1, effective.part1.rateId)
	const admin2 = findAdmin(part2, effective.part2.rateId)
	const site1 = findSite(admin1, effective.part1.siteId)
	const site2 = findSite(admin2, effective.part2.siteId)

	const outOfOrder = isOutOfOrder(part1Active, part2Active, admin1, admin2)
	const ostaRequired = isOstaRequired(site1, site2)

	const visibleMaterials = useMemo(
		() => visibleStudyMaterials(materials, part1Active, part2Active),
		[materials, part1Active, part2Active],
	)

	/**
	 * Switching parts drops the other part's choice AND its study materials —
	 * otherwise a Part II book stays in the cart and the server prices a book
	 * for an exam that is no longer being registered for.
	 */
	const selectPart = useCallback((partSelected: string) => {
		const nextPart1Active = isPart1Active(partSelected)
		const nextPart2Active = isPart2Active(partSelected)

		setSelection((prev) => ({
			partSelected,
			part1: nextPart1Active ? prev.part1 : { rateId: "", siteId: "" },
			part2: nextPart2Active ? prev.part2 : { rateId: "", siteId: "" },
		}))

		setMaterials((prev) =>
			prev.map((material) => {
				if (material.relatedPart === "Part 1" && !nextPart1Active) {
					return { ...material, selected: false }
				}
				if (material.relatedPart === "Part 2" && !nextPart2Active) {
					return { ...material, selected: false }
				}
				return material
			}),
		)
	}, [])

	/**
	 * Change sitting, and drop the site with it. Whether the new one fills a
	 * site back in is `resolvePartSelection`'s call, not this one's.
	 */
	const selectAdmin = useCallback((which: 1 | 2, rateId: string) => {
		const next = { rateId, siteId: "" }
		setSelection((prev) =>
			which === 1 ? { ...prev, part1: next } : { ...prev, part2: next },
		)
	}, [])

	const selectSite = useCallback((which: 1 | 2, siteId: string) => {
		setSelection((prev) =>
			which === 1
				? { ...prev, part1: { ...prev.part1, siteId } }
				: { ...prev, part2: { ...prev.part2, siteId } },
		)
	}, [])

	const toggleMaterial = useCallback((productCode: string) => {
		setMaterials((prev) =>
			prev.map((material) =>
				material.productCode === productCode
					? { ...material, selected: !material.selected }
					: material,
			),
		)
	}, [])

	/**
	 * A card order shows no address card, so the Location select is the only
	 * country there is — fall back to it rather than pricing against a blank.
	 */
	const pricedBilling: RegistrationAddress = useMemo(
		() => ({
			...billingAddress,
			country: billingAddress.country || billingCountry,
		}),
		[billingAddress, billingCountry],
	)

	const feesRequest = useMemo(
		() =>
			buildFeesRequest({
				type: programType,
				courseCode,
				regCode,
				contactId: load.contact?.id ?? null,
				selection: effective,
				materials,
				paymentType,
				billingAddress: pricedBilling,
				shippingAddress: billingAndShippingSame
					? pricedBilling
					: shippingAddress,
				billingAndShippingSame,
				autoRenew,
				// FRM has no membership upsell and no Risk.net add-on — both are
				// course/membership programme concerns.
				membershipSelected: false,
				riskNetSelected: false,
				mobilePhoneCode,
			}),
		[
			programType,
			courseCode,
			regCode,
			load.contact?.id,
			effective,
			materials,
			paymentType,
			pricedBilling,
			shippingAddress,
			billingAndShippingSame,
			autoRenew,
			mobilePhoneCode,
		],
	)

	const debouncedRequest = useDebouncedValue(feesRequest, FEES_DEBOUNCE_MS)

	/**
	 * `keepPreviousData` holds the last total on screen while the next one is
	 * in flight, so the figure updates rather than blinking away between every
	 * keystroke and every tick.
	 */
	const feesQuery = useQuery({
		...examFeesQueryOptions(debouncedRequest),
		placeholderData: keepPreviousData,
	})

	return {
		/** Resolved, with defaults applied — what the sections should render. */
		selection: effective,
		selectPart,
		selectAdmin,
		selectSite,
		materials,
		visibleMaterials,
		toggleMaterial,
		part1,
		part2,
		part1Active,
		part2Active,
		part1Admins,
		part2Admins,
		admin1,
		admin2,
		site1,
		site2,
		outOfOrder,
		ostaRequired,
		fees: feesQuery.data ?? null,
		/** True while a newer cart is being priced and an older total is shown. */
		isPricing: feesQuery.isFetching,
	}
}
