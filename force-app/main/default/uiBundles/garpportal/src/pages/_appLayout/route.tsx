import { createFileRoute, Outlet } from "@tanstack/react-router"

import { PageContainer } from "@/components/molecules/page-container"
import { AppSidebar } from "@/components/organisms/app-sidebar"
import { Footer } from "@/components/organisms/footer"
import { Navbar } from "@/components/organisms/navbar"

export const Route = createFileRoute("/_appLayout")({
	component: AppLayout,
})

function AppLayout() {
	return (
		<div className="flex min-h-screen flex-col">
			<Navbar />
			{/* Footer in the main column + sticky sidebar: same look, sidebar stays while footer scrolls. */}
			<div className="flex flex-1">
				<AppSidebar />
				<div className="flex min-w-0 flex-1 flex-col">
					{/* Fill viewport below the toolbar so short pages don’t show the tall footer in the first screen. */}
					<main className="min-h-[calc(100vh-4rem)] min-w-0 flex-1 app:min-h-[calc(100vh-5rem)]">
						<PageContainer className="py-6">
							<Outlet />
						</PageContainer>
					</main>
					<Footer />
				</div>
			</div>
		</div>
	)
}
