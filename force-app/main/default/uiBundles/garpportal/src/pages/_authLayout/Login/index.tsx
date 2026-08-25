import { createFileRoute } from "@tanstack/react-router"
import { z } from "zod"

import { LoginForm } from "@/components/organisms/login-form"
import { AuthShell } from "@/components/organisms/auth-shell"
import { AUTH_REDIRECT_PARAM } from "@/auth/constants"
import { pageTitle } from "@/lib/document-title"

const loginSearchSchema = z.object({
	[AUTH_REDIRECT_PARAM]: z.string().optional().catch(undefined),
})

export const Route = createFileRoute("/_authLayout/Login/")({
	validateSearch: loginSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle("Login") }],
	}),
	component: Login,
})

function Login() {
	return (
		<AuthShell>
			<LoginForm />
		</AuthShell>
	)
}
