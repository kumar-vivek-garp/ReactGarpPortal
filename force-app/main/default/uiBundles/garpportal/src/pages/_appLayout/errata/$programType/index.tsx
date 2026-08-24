import { createFileRoute, redirect } from "@tanstack/react-router"

/**
 * The legacy errata path, kept as a redirect.
 *
 * `/errata/{programType}` is what MyGarp used and what existing links and
 * emails already point at, so it has to keep resolving — the same reasoning
 * that keeps `/order-details/{orderNumber}`. The page itself nests under the
 * programme, with every other programme subpage.
 */
export const Route = createFileRoute("/_appLayout/errata/$programType/")({
	beforeLoad: ({ params }) => {
		const slug = params.programType.trim().toLowerCase()
		throw redirect({
			to: "/programs/$programType/errata",
			params: { programType: slug === "rai" ? "riskai" : slug },
			replace: true,
		})
	},
})
