import type { ExternalNavLink, SocialLink } from "./types"

export const FOOTER_TAGLINE =
	"We are a not-for-profit organization and the leading globally recognized membership association for risk managers."

export const FOOTER_CONTACT_LINK: ExternalNavLink = {
	title: "Contact Us",
	url: "https://www.garp.org/about/contact-us",
}

// Order and mix of link/QR entries mirrors the live footer's social_icons
// block exactly (garpApp2's footer.component.html): WeChat and Xiaohongshu
// (RED) open a QR-code dialog there instead of linking out, since neither
// platform has a browsable profile URL for a non-app audience.
export const FOOTER_SOCIAL_LINKS: SocialLink[] = [
	{
		name: "WeChat",
		kind: "qr",
		qrImageUrl: "https://www.garp.org/hubfs/Website/China/Images/GARP-China-QR-code.jpg",
		qrAlt: "WeChat QR code",
	},
	{ name: "Facebook", kind: "link", url: "https://www.facebook.com/GARPRisk" },
	{ name: "X", kind: "link", url: "https://x.com/GARP_Risk" },
	{
		name: "LinkedIn",
		kind: "link",
		url: "https://www.linkedin.com/company/global-association-of-risk-professionals",
	},
	{
		name: "Xiaohongshu",
		kind: "qr",
		qrImageUrl: "https://www.garp.org/hubfs/Website/China/Images/RED-QR-Code.jpg",
		qrAlt: "Xiaohongshu (RED) QR code",
	},
	{ name: "Instagram", kind: "link", url: "https://www.instagram.com/garp_risk/" },
	{
		name: "Weibo",
		kind: "link",
		url: "https://passport.weibo.com/visitor/visitor?entry=miniblog&a=enter&url=https%3A%2F%2Fweibo.com%2Fgarpfrm&domain=weibo.com&ua=Mozilla%2F5.0&_rand=1727725587146",
	},
	{ name: "YouTube", kind: "link", url: "https://www.youtube.com/user/GARPvideo" },
]

export const FOOTER_LEGAL_LINKS: ExternalNavLink[] = [
	{ title: "Important Notices", url: "https://www.garp.org/important-notices" },
	{ title: "Bylaws", url: "https://www.garp.org/bylaws" },
	{ title: "Code of Conduct", url: "https://www.garp.org/code-of-conduct" },
	{ title: "Privacy Notice", url: "https://www.garp.org/privacy-notice" },
	{ title: "Terms of Use", url: "https://www.garp.org/terms-of-use" },
]

export const FOOTER_COPYRIGHT = "© 2026 Global Association of Risk Professionals"
