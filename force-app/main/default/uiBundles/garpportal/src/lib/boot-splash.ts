const BOOT_SPLASH_ID = "boot-splash"
const BOOT_SPLASH_DONE_CLASS = "boot-splash--done"
/** Matches `transition` duration in `public/boot.css`. */
const BOOT_SPLASH_FADE_MS = 200

let dismissed = false

/**
 * Fade out and hide the outer HTML boot splash (sibling of `#root`).
 * Idempotent — safe on HMR / layout remount.
 */
function dismissBootSplash(): void {
	if (typeof document === "undefined" || dismissed) return

	const splash = document.getElementById(BOOT_SPLASH_ID)
	if (!splash) {
		dismissed = true
		return
	}

	dismissed = true
	splash.classList.add(BOOT_SPLASH_DONE_CLASS)
	splash.setAttribute("aria-hidden", "true")
	splash.setAttribute("aria-busy", "false")

	window.setTimeout(() => {
		if (!splash.isConnected) return
		splash.remove()
	}, BOOT_SPLASH_FADE_MS)
}

export { dismissBootSplash }
