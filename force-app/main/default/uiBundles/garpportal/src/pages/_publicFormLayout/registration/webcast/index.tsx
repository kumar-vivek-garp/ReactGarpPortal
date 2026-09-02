import { createFileRoute, notFound } from "@tanstack/react-router"

/**
 * `/registration/webcast` with no event id is not a page — there is no event
 * picker, by decision. Without this static index the bare path would fall into
 * `/registration/$programType` and render a bogus "WEBCAST Registration" exam
 * placeholder; instead it throws to the session-aware 404
 * (`notFoundMode: "root"` sends it to `NotFoundPage`).
 */
export const Route = createFileRoute("/_publicFormLayout/registration/webcast/")({
	beforeLoad: () => {
		throw notFound()
	},
})
