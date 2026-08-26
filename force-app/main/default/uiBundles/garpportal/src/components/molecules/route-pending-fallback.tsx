import { GarpLogoFull } from "@/components/atoms/garp-logo-full"
import { GARP_AUTH_BG } from "@/config/navigation/garp-logos"

/**
 * Same branded wait as the HTML `#boot-splash` (logo + sliding bar).
 * Used as layout `pendingComponent` so cold auth/chunk waits match pre-JS boot.
 * Bar motion uses `.boot-bar` from `public/boot.css` (loaded from index.html).
 */
function BootSplashScreen() {
	return (
		<div
			className="flex min-h-screen flex-col items-center justify-center gap-6 bg-[#081a31] bg-cover bg-fixed bg-center bg-no-repeat px-4 py-8"
			style={{ backgroundImage: `url('${GARP_AUTH_BG}')` }}
			role="status"
			aria-busy="true"
			aria-label="Loading GARP"
		>
			{/* Always on the dark backdrop image, so it is pinned to the knockout
			    colour — the mode-invariant corporate-navy pairing, not
			    `--toolbar-foreground`, which follows the light nav now. */}
			<GarpLogoFull className="h-auto w-full max-w-80 text-corporate-navy-foreground" />
			<div className="boot-bar" aria-hidden="true">
				<span />
			</div>
		</div>
	)
}

/** Layout pending aliases — identical shell for app and auth cold loads. */
const AppRoutePending = BootSplashScreen
const AuthRoutePending = BootSplashScreen

export { AppRoutePending, AuthRoutePending, BootSplashScreen }
