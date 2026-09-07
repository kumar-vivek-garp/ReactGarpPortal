import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

// No HTTP boundary — jsdom's hostname is `localhost`, which would flip
// `resolvePortalAssetUrl` into its local-Vite branch and rewrite photo URLs.
vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

import { AccountIdentityHero } from "@/components/organisms/account-identity-hero"
import { VISIBLE_MISSING_CHIPS } from "@/lib/account-presentation"
import { accountView } from "@/testing/factories/account"
import { renderWithProviders } from "@/testing/render"
import { skipSpringAnimations } from "@/testing/springs"

/*
 * The chips reveal on a `useTrail`, so springs jump to their end state; the
 * assertions here are about which chips exist, not how they arrived.
 */
skipSpringAnimations()

/** Every field `GARP_Portal_Core.PROFILE_RULES` scores, worst case. */
const ALL_MISSING = [
	"Employment status",
	"Area of concentration",
	"Years in the industry",
	"Current/last company",
	"Professional level",
	"Job function",
	"Years in risk management",
	"School name",
	"Highest degree",
	"Expected graduation year",
	"Expected graduation month",
]

function renderHero(missing: string[]) {
	const onFixField = vi.fn()
	renderWithProviders(
		<AccountIdentityHero
			account={accountView({
				completeness: {
					missing,
					isComplete: missing.length === 0,
					percentComplete: 20,
				},
			})}
			onEditPersonal={vi.fn()}
			onFixField={onFixField}
			onReviewMissing={vi.fn()}
		/>,
	)
	return { onFixField }
}

/** Field chips only — the header and the toggle are buttons too. */
function chipLabels() {
	return ALL_MISSING.filter((label) =>
		screen.queryByRole("button", { name: label }),
	)
}

describe("AccountIdentityHero — the missing-profile strip", () => {
	it("shows only the first few chips and offers the rest behind a count", () => {
		renderHero(ALL_MISSING)

		expect(chipLabels()).toHaveLength(VISIBLE_MISSING_CHIPS)
		expect(
			screen.getByRole("button", {
				name: `+${ALL_MISSING.length - VISIBLE_MISSING_CHIPS} more`,
			}),
		).toBeInTheDocument()
		// The count in the header is the real total, not what fits on screen.
		expect(screen.getByText(/11 items left/i)).toBeInTheDocument()
	})

	it("expanding reveals every chip and offers the way back", async () => {
		const user = userEvent.setup()
		renderHero(ALL_MISSING)

		await user.click(screen.getByRole("button", { name: /\+7 more/ }))

		expect(chipLabels()).toHaveLength(ALL_MISSING.length)
		await user.click(screen.getByRole("button", { name: "Show less" }))
		expect(chipLabels()).toHaveLength(VISIBLE_MISSING_CHIPS)
	})

	it("a chip hidden behind the toggle still opens its own field once revealed", async () => {
		const user = userEvent.setup()
		const { onFixField } = renderHero(ALL_MISSING)

		await user.click(screen.getByRole("button", { name: /\+7 more/ }))
		await user.click(screen.getByRole("button", { name: "Highest degree" }))

		// Apex calls it "Highest degree"; the form control is `degreeProgram`.
		expect(onFixField).toHaveBeenCalledWith("degreeProgram")
	})

	it("does not collapse a single chip over the cap — the toggle would cost its row", () => {
		renderHero(ALL_MISSING.slice(0, VISIBLE_MISSING_CHIPS + 1))

		expect(chipLabels()).toHaveLength(VISIBLE_MISSING_CHIPS + 1)
		expect(screen.queryByRole("button", { name: /more/ })).not.toBeInTheDocument()
	})

	it("renders no strip at all for a complete profile", () => {
		renderHero([])

		expect(screen.queryByText(/complete your profile/i)).not.toBeInTheDocument()
	})
})
