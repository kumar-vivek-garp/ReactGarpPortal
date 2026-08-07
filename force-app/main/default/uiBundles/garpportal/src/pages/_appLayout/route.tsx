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
			<div className="flex flex-1">
				<AppSidebar />
				<main className="min-w-0 flex-1">
					<PageContainer className="py-6">
						<Outlet />
					</PageContainer>
				</main>
			</div>
			<Footer />
		</div>
	)
}
