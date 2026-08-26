import { createFileRoute, redirect } from "@tanstack/react-router"

import { registrationSearchSchema } from "@/config/registration"

/**
 * The legacy path-segment form of a registration code —
 * `/registration/frm/TEAM24` — still in circulation in team-registration
 * links. GarpAppv1 accepts it alongside `?regCode`, so this route folds the
 * segment into the query form and hands off to the canonical page, keeping
 * the rest of the search (a payment return's `stripe_return`/`oid`/`on`
 * included) intact. A code already present in the query wins: it is the more
 * deliberate of the two.
 */
export const Route = createFileRoute(
	"/_publicFormLayout/registration/$programType/$regCode",
)({
	validateSearch: registrationSearchSchema,
	beforeLoad: ({ params, search }) => {
		throw redirect({
			to: "/registration/$programType",
			params: { programType: params.programType },
			search: {
				...search,
				regCode: search.regCode ?? search.teamCode ?? params.regCode,
			},
			replace: true,
		})
	},
})
