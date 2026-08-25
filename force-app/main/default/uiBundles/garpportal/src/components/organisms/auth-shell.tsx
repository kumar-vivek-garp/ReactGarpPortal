import { lazy, Suspense, type ReactNode } from "react"

import { GarpLogoFull } from "@/components/atoms/garp-logo-full"
import { GARP_AUTH_BG } from "@/config/navigation/garp-logos"
import { AUTH_FOOTER_LINKS } from "@/config/navigation/auth-footer-links"
import { isLocalCliAuthEnabled } from "@/auth/local-cli-auth"

/**
 * Theme toggle + local Contact picker, fixed top-left. Localhost only —
 * `isLocalCliAuthEnabled()` is false on the deployed Experience site, so this
 * never ships to members. Lazy so the dialog and its deps stay out of the
 * bundle everyone else downloads.
 */
const AuthLocalTools = lazy(() =>
	import("@/components/molecules/auth-local-tools").then((m) => ({
		default: m.AuthLocalTools,
	})),
)

/**
 * Shared chrome for the unauthenticated pages: GARP backdrop, logo, the legal
 * strip, and the localhost dev tools. Anything added here reaches every auth
 * page — which is the point; the dev tools used to be rendered by the login
 * page itself, which is why they were missing from anything else.
 *
 * Login is currently its only occupant. Affiliate registration sat here too
 * until it moved to `/registration/affiliate` under `_publicFormLayout` — this
 * shell is a vertically-centred splash for one narrow card, which is right for
 * a sign-in box and wrong for a form with eight fields and three attestations.
 * A registration form belongs with the other registration forms.
 *
 * The shell does not scroll a tall child for it — a form that outgrows the
 * viewport must cap its own height and scroll internally, so the logo and
 * footer stay put.
 *
 * Inline `style` for the backdrop rather than a Tailwind class because the
 * asset URL resolves at runtime from the org's static resources.
 */
function AuthShell({ children }: { children: ReactNode }) {
	const showLocalTools = isLocalCliAuthEnabled()

	return (
		<div
			className="flex min-h-screen flex-col items-center justify-center gap-8 bg-cover bg-fixed bg-no-repeat px-4 py-12"
			style={{ backgroundImage: `url('${GARP_AUTH_BG}')` }}
		>
			{showLocalTools ? (
				<Suspense fallback={null}>
					<AuthLocalTools />
				</Suspense>
			) : null}
			{/* Pinned to knockout: the backdrop image is dark in either theme. */}
			<GarpLogoFull className="h-auto w-full max-w-sm text-toolbar-foreground" />
			{children}
			<footer className="flex flex-col items-center gap-3 text-caption text-corporate-navy-foreground">
				<ul className="flex flex-wrap justify-center gap-4">
					{AUTH_FOOTER_LINKS.map((link) => (
						<li key={link.label}>
							<a
								href={link.href}
								target="_blank"
								rel="noreferrer"
								className="hover:underline"
							>
								{link.label}
							</a>
						</li>
					))}
				</ul>
				<p>
					&copy; {new Date().getFullYear()} Global Association of Risk
					Professionals
				</p>
			</footer>
		</div>
	)
}

export { AuthShell }
