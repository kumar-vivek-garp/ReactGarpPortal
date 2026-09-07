import type { ApexStudyMaterialsPayload } from "@/api/study-materials/types"
import {
	apexMaterial,
	comingSoon,
	garpLearning,
	myEBooksWithKey,
	outOfStock,
	ownedWithReg,
	purchasable,
	studyMaterialsPayload,
	unpaidOrder,
} from "@/testing/factories/study-materials"
import { programsListData } from "./payloads"

/**
 * One material per card state, spread over four programmes:
 *
 *   FRM  — GARP Learning (access + a pending practice-exam add-on, Part 1),
 *          owned Part I eBooks with two vendor titles (Part 1),
 *          the Part II books for sale at USD 295 (Part 2)
 *   SCR  — an unpaid order for the printed book
 *   RAI  — a coming-soon book with a Notify me link
 *   FRR  — an out-of-stock handbook
 */
export function studyMaterialsData(): ApexStudyMaterialsPayload {
	return studyMaterialsPayload({
		frmStudyMaterials: [garpLearning("pending"), ownedWithReg(), purchasable()],
		scrStudyMaterials: [
			unpaidOrder({ title: "2026 SCR Book", productCode: "SCRH" }),
		],
		raiStudyMaterials: [comingSoon()],
		frrStudyMaterials: [outOfStock()],
	})
}

/** The frm-only variant, for specs that want one programme and no pills. */
export function singleProgramData(): ApexStudyMaterialsPayload {
	return studyMaterialsPayload({
		frmStudyMaterials: [apexMaterial({ title: "FRM Study Guide", productCode: "SM-1" })],
	})
}

/**
 * Every memberportal action the listing fires. `programs` feeds the sidebar's
 * CPD gate on every _appLayout page; `myEBooks` is the archive gate the page
 * now asks on load.
 */
export function studyMaterialsActions(
	payload: ApexStudyMaterialsPayload = studyMaterialsData(),
): Record<string, unknown> {
	return {
		studyMaterials: payload,
		myEBooks: myEBooksWithKey(),
		programs: programsListData(),
	}
}
