import { lazy, Suspense } from "react"
import { createFileRoute } from "@tanstack/react-router"
import { z } from "zod"

import { LoginForm } from "@/components/organisms/login-form"
import { isLocalCliAuthEnabled } from "@/auth/local-cli-auth"
import { AUTH_REDIRECT_PARAM } from "@/auth/constants"
import { GARP_AUTH_BG, GARP_LOGO_FULL } from "@/config/navigation/garp-logos"
import { pageTitle } from "@/lib/document-title"

const loginSearchSchema = z.object({
	[AUTH_REDIRECT_PARAM]: z.string().optional().catch(undefined),
})

const AuthLocalTools = lazy(() =>
	import("@/components/molecules/auth-local-tools").then((m) => ({
		default: m.AuthLocalTools,
	})),
)

export const Route = createFileRoute("/_authLayout/Login/")({
	validateSearch: loginSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Login") }],
	}),
	component: Login,
})

const FOOTER_LINKS = [
	{ label: "Bylaws", href: "https://www.garp.org/bylaws" },
	{ label: "Code of Conduct", href: "https://www.garp.org/code-of-conduct" },
	{ label: "Privacy Notice", href: "https://www.garp.org/privacy-notice" },
	{ label: "Terms of Use", href: "https://www.garp.org/terms-of-use" },
]

function Login() {
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
			<img
				src={GARP_LOGO_FULL}
				alt="GARP - Global Association of Risk Professionals"
				className="h-auto w-full max-w-sm"
			/>
			<LoginForm />
			<footer className="flex flex-col items-center gap-3 text-caption text-corporate-navy-foreground">
				<ul className="flex flex-wrap justify-center gap-4">
					{FOOTER_LINKS.map((link) => (
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
