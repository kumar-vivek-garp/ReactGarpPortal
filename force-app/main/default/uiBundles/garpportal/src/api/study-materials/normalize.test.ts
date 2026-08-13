import { describe, expect, it } from "vitest"

import { normalizeStudyMaterialsPayload } from "./normalize"
import type { ApexStudyMaterialsPayload } from "./types"

describe("normalizeStudyMaterialsPayload", () => {
	it("maps program buckets and owned entitlements", () => {
		const payload: ApexStudyMaterialsPayload = {
			statusCode: 200,
			statusMessage: "Success",
			studyMaterialsInfo: {
				frmStudyMaterials: [],
				raijStudyMaterials: [],
				frrStudyMaterials: [],
				scrStudyMaterials: [
					{
						title: "2026 SCR Book",
						productCode: "SCRH",
						materialType: "Book",
						shortDescription: "Printed book",
						imageURL: "https://example.com/book.png",
						isOwned: true,
						isAvailable: true,
						price: 100,
						canPurchase: true,
						sortCode: "1A",
					},
					{
						title: "2026 SCR Study Guide",
						productCode: "SCRSG",
						materialType: "Download",
						downloadURL: "https://example.com/guide.pdf",
						shortDescription: "Guide PDF",
						isOwned: false,
						isAvailable: true,
					},
				],
				raiStudyMaterials: [
					{
						title: "2026 GARP Learning RAI",
						productCode: "RAIBP",
						materialType: "GARP Learning",
						GARPLearningAccessURL: "/BenchPrepSSO?prog=RAI",
						isOwned: true,
						isAvailable: true,
						isCompWithReg: true,
						eBook: {
							keyStatus: "Taken",
							expireDate: "2027-08-11",
						},
					},
				],
			},
		}

		const view = normalizeStudyMaterialsPayload(payload)

		expect(view.programs.map((p) => p.key)).toEqual(["scr", "rai"])
		expect(view.programs[0]?.materials).toHaveLength(2)
		expect(view.programs[0]?.materials[0]?.title).toBe("2026 SCR Book")
		expect(view.programs[0]?.materials[0]?.costNote).toBe("$100")
		expect(view.programs[0]?.materials[1]?.isDownload).toBe(true)

		expect(view.myEntitlements).toHaveLength(2)
		expect(view.myEntitlements[0]?.id).toBe("SCRH")
		expect(view.myEntitlements[1]?.accessUrl).toBe("/BenchPrepSSO?prog=RAI")
		expect(view.myEntitlements[1]?.expirationDate).toBe("2027-08-11")
		expect(view.myEntitlements[1]?.status).toBe("Taken")
	})

	it("returns empty when studyMaterialsInfo is missing", () => {
		expect(normalizeStudyMaterialsPayload({})).toEqual({
			programs: [],
			myEntitlements: [],
		})
	})
})
