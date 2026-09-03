import { describe, expect, it } from "vitest"

import { courseDetailQueryOptions, coursesQueryKeys } from "@/api/courses/query-options"

describe("courseDetailQueryOptions", () => {
	it("keys by the uppercased trimmed course type", () => {
		const options = courseDetailQueryOptions(" frr ")
		expect(options.queryKey).toEqual(["courses", "detail", "FRR"])
		expect(options.queryKey).toEqual(coursesQueryKeys.detail("frr"))
		expect(options.enabled).toBe(true)
		expect(options.meta).toMatchObject({ toastError: true })
	})

	it("disables itself for a blank course type", () => {
		expect(courseDetailQueryOptions("   ").enabled).toBe(false)
	})
})
