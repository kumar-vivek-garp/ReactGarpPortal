import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeAll, describe, expect, it } from "vitest"

// jsdom ships <dialog> without its imperative API.
beforeAll(() => {
	if (typeof HTMLDialogElement.prototype.showModal !== "function") {
		HTMLDialogElement.prototype.showModal = function showModal() {
			this.setAttribute("open", "")
		}
		HTMLDialogElement.prototype.close = function close() {
			this.removeAttribute("open")
		}
	}
})

import { FooterSocialLinks } from "@/components/molecules/footer-social-links"
import type { SocialLink } from "@/config/navigation/types"
import { renderWithProviders } from "@/testing/render"

const LINKS: SocialLink[] = [
	{ name: "LinkedIn", kind: "link", url: "https://www.linkedin.com/company/garp" },
	{
		name: "WeChat",
		kind: "qr",
		qrImageUrl: "/assets/wechat-qr.png",
		qrAlt: "WeChat QR code",
	},
]

describe("the two kinds of social entry", () => {
	it("renders a plain link with a safe new-tab target", () => {
		renderWithProviders(<FooterSocialLinks links={LINKS} />)
		const link = screen.getByRole("link", { name: "LinkedIn" })
		expect(link).toHaveAttribute("href", "https://www.linkedin.com/company/garp")
		expect(link).toHaveAttribute("target", "_blank")
		expect(link).toHaveAttribute("rel", "noopener noreferrer")
	})

	it("keeps the QR image unloaded until the dialog is first opened", async () => {
		const user = userEvent.setup()
		renderWithProviders(<FooterSocialLinks links={LINKS} />)

		expect(screen.queryByAltText("WeChat QR code")).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "WeChat" }))
		const qr = screen.getByAltText("WeChat QR code")
		expect(qr).toHaveAttribute("src", "/assets/wechat-qr.png")

		// Clicking the dialog itself dismisses it; the image stays loaded.
		await user.click(qr)
		expect(qr.closest("dialog")).not.toHaveAttribute("open")
	})
})
