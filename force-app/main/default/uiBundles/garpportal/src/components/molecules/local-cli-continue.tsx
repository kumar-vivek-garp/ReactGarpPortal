import { useState } from "react"
import { useNavigate } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import { authQueryKeys } from "@/api/auth/query-options"
import { DEFAULT_POST_LOGIN_PATH } from "@/auth/constants"
import {
	checkLocalSfHealth,
	fetchCurrentUserViaLocalCli,
} from "@/auth/local-cli-auth"
import { clearLocalLogoutFlag } from "@/auth/local-session"
import { queryClient } from "@/api/client"

/**
 * Localhost only (lazy-loaded from LoginForm on Vite `dev` / `preview`).
 * Uses the local CLI gateway instead of Experience Site.login.
 */
function LocalCliContinue() {
	const navigate = useNavigate()
	const [pending, setPending] = useState(false)
	const [errors, setErrors] = useState<string[]>([])

	async function onContinue() {
		setPending(true)
		setErrors([])
		try {
			const health = await checkLocalSfHealth()
			if (!health.ok) {
				setErrors(
					[
						health.error ?? "Local Salesforce gateway is not ready.",
						health.hint ?? "From the repo root run: npm run local-sf",
					].filter(Boolean),
				)
				return
			}

			clearLocalLogoutFlag()
			const user = await fetchCurrentUserViaLocalCli()
			if (!user) {
				setErrors([
					"CLI session is up, but identity checks failed.",
					`Gateway user: ${health.username ?? "unknown"}`,
					"Try: sf org login web --alias devjuly25a",
				])
				return
			}

			queryClient.setQueryData(authQueryKeys.currentUser, user)
			await navigate({ to: DEFAULT_POST_LOGIN_PATH })
		} catch (error) {
			setErrors([
				error instanceof Error ? error.message : "Local CLI continue failed.",
			])
		} finally {
			setPending(false)
		}
	}

	return (
		<div className="flex flex-col gap-3 border-t border-border pt-4">
			<p className="text-center text-sm text-muted-foreground">
				Local development: use your Salesforce CLI session (no Experience login).
			</p>
			{errors.length > 0 ? (
				<ul className="list-disc space-y-1 pl-5 text-body text-destructive" role="alert">
					{errors.map((message) => (
						<li key={message}>{message}</li>
					))}
				</ul>
			) : null}
			<Button
				type="button"
				variant="outline"
				className="h-[60px]"
				disabled={pending}
				onClick={() => void onContinue()}
			>
				{pending ? "Connecting…" : "Continue with Salesforce CLI"}
			</Button>
		</div>
	)
}

export { LocalCliContinue }
