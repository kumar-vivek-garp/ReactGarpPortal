import { GARP_LOGO_FULL, GARP_LOGO_KNOCKOUT } from "@/config/navigation/garp-logos"
import { LOGIN_PATH } from "@/auth/constants"

const AUTH_BG =
	"https://www.garp.org/hubfs/GARP%20Design/membership/image/bckgd-dark-gradient-1.png"

function isAuthPath(pathname: string): boolean {
	return (
		pathname === LOGIN_PATH ||
		pathname.endsWith(LOGIN_PATH) ||
		pathname.includes(`${LOGIN_PATH}?`)
	)
}

/** Lightweight login-chrome placeholder (no lazy route chunk required). */
function AuthRoutePending() {
	return (
		<div
			className="flex min-h-screen flex-col items-center justify-center gap-8 bg-cover bg-fixed bg-no-repeat px-4 py-12"
			style={{ backgroundImage: `url('${AUTH_BG}')` }}
			role="status"
			aria-busy="true"
			aria-label="Loading sign in"
		>
			<img
				src={GARP_LOGO_FULL}
				alt="GARP - Global Association of Risk Professionals"
				className="h-auto w-full max-w-sm"
			/>
			<div className="w-full max-w-auth space-y-4 rounded-xl bg-secondary p-6 shadow-sm">
				<div className="mx-auto h-7 w-24 animate-pulse rounded-md bg-border/80" />
				<div className="h-10 w-full animate-pulse rounded-xl bg-border/60" />
				<div className="h-10 w-full animate-pulse rounded-xl bg-border/60" />
				<div className="h-[60px] w-full animate-pulse rounded-md bg-border/70" />
			</div>
		</div>
	)
}

/**
 * Lightweight app-chrome placeholder — CSS-only, no Navbar/Sidebar imports,
 * so it can live in the eager bundle while real layout chunks download.
 * Mirrors real toolbar: solid black `bg-toolbar`, knockout logo.
 */
function AppRoutePending() {
	return (
		<div className="flex min-h-screen flex-col" role="status" aria-busy="true" aria-label="Loading">
			{/* Match live Navbar: fixed 80px black toolbar (desktop). */}
			<header className="box-border flex h-16 max-w-[100vw] items-center bg-toolbar text-toolbar-foreground app:h-20">
				<div className="mr-[25px] ml-4 shrink-0 app:ml-[38px]">
					<img
						src={GARP_LOGO_KNOCKOUT}
						alt="GARP logo"
						width={125}
						height={36}
						decoding="async"
						fetchPriority="high"
						className="w-[100px] app:w-[125px]"
					/>
				</div>
				<div className="ml-auto flex shrink-0 items-center gap-3 pr-4">
					<div className="hidden h-8 w-20 animate-pulse rounded-md bg-white/15 app:block" />
					<div className="h-8 w-24 animate-pulse rounded-md bg-white/15" />
				</div>
			</header>
			<div className="flex flex-1">
				<aside className="hidden w-[294px] shrink-0 bg-linear-to-b from-surface-gradient-start to-surface-gradient-end p-4 app:block">
					<div className="mb-4 flex items-center gap-3">
						<div className="size-11 animate-pulse rounded-full bg-border/80" />
						<div className="flex-1 space-y-2">
							<div className="h-4 w-36 animate-pulse rounded bg-border/80" />
							<div className="h-3 w-24 animate-pulse rounded bg-border/60" />
						</div>
					</div>
					<div className="space-y-0 divide-y divide-background border-t border-background">
						{Array.from({ length: 6 }, (_, i) => (
							<div key={i} className="h-12 animate-pulse bg-border/40" />
						))}
					</div>
				</aside>
				<main className="min-w-0 flex-1 p-6">
					<div className="space-y-3">
						<div className="h-8 w-48 animate-pulse rounded-md bg-border/80" />
						<div className="h-4 w-full max-w-xl animate-pulse rounded-md bg-border/60" />
						<div className="h-4 w-full max-w-lg animate-pulse rounded-md bg-border/60" />
					</div>
				</main>
			</div>
		</div>
	)
}

/**
 * Router-level default pending UI. Lives in the entry bundle so it can paint
 * while lazy route `component` chunks are still downloading.
 */
function RoutePendingFallback() {
	const pathname =
		typeof window !== "undefined" ? window.location.pathname : ""
	if (isAuthPath(pathname)) {
		return <AuthRoutePending />
	}
	return <AppRoutePending />
}

export { AppRoutePending, AuthRoutePending, RoutePendingFallback }
