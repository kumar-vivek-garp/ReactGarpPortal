import { createFileRoute, notFound } from "@tanstack/react-router"

/** No event picker, by decision — see the webcast twin for the full note. */
export const Route = createFileRoute("/_publicFormLayout/registration/event/")({
	beforeLoad: () => {
		throw notFound()
	},
})
