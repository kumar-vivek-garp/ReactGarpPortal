import { describe, expect, it } from "vitest"

import {
	coverCropSquare,
	profilePhotoOutputEdge,
	PROFILE_PHOTO_EDGE_PX,
} from "./resize-profile-photo"

describe("coverCropSquare", () => {
	it("returns full frame for already-square images", () => {
		expect(coverCropSquare(360, 360)).toEqual({ sx: 0, sy: 0, size: 360 })
	})

	it("center-crops landscape images", () => {
		expect(coverCropSquare(400, 200)).toEqual({ sx: 100, sy: 0, size: 200 })
	})

	it("center-crops portrait images", () => {
		expect(coverCropSquare(200, 400)).toEqual({ sx: 0, sy: 100, size: 200 })
	})
})

describe("profilePhotoOutputEdge", () => {
	it("caps at PROFILE_PHOTO_EDGE_PX", () => {
		expect(profilePhotoOutputEdge(360)).toBe(PROFILE_PHOTO_EDGE_PX)
	})

	it("does not upscale smaller sources", () => {
		expect(profilePhotoOutputEdge(64)).toBe(64)
	})

	it("never returns zero", () => {
		expect(profilePhotoOutputEdge(0)).toBe(1)
	})
})
