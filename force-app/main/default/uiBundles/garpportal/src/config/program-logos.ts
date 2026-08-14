/**
 * Known HubSpot “My Programs” card art. Preconnecting / preloading these lets
 * the browser discover likely LCP candidates before `/memberportal/programs`
 * returns (logos are not in the initial HTML).
 */
export const GARP_HUB_ORIGIN = "https://www.garp.org"

export const COMMON_PROGRAM_LOGO_URLS = [
	"https://www.garp.org/hubfs/Portal/My%20Programs/SCR.webp",
	"https://www.garp.org/hubfs/Portal/My%20Programs/FRM.png",
	"https://www.garp.org/hubfs/Portal/My%20Programs/RAI.webp",
] as const

export const CRITICAL_FONT_URLS = [
	"https://www.garp.org/hubfs/Website/Common/Fonts/Nunito_Sans/NunitoSans-Regular.ttf",
	"https://www.garp.org/hubfs/Website/Common/Fonts/Nunito_Sans/NunitoSans-Bold.ttf",
] as const
