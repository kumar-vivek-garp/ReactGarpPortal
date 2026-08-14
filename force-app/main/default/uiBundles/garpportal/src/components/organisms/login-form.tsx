import { lazy, Suspense } from "react"
import { useForm, type SubmitHandler } from "react-hook-form"
import { useSearch } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { useLogin } from "@/hooks/use-login"
import { AUTH_REDIRECT_PARAM } from "@/auth/constants"
import { isLocalCliAuthEnabled } from "@/auth/local-cli-auth"
import { getSafeStartUrl } from "@/auth/start-url"

type LoginFormValues = {
	email: string
	password: string
}

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

const LocalCliContinue = lazy(() =>
	import("@/components/molecules/local-cli-continue").then((m) => ({
		default: m.LocalCliContinue,
	})),
)

function LoginForm() {
	const search = useSearch({ from: "/_authLayout/Login/" })
	const startUrl = getSafeStartUrl(
		typeof search[AUTH_REDIRECT_PARAM] === "string" ? search[AUTH_REDIRECT_PARAM] : undefined,
	)
	const loginMutation = useLogin()
	const showLocalCli = isLocalCliAuthEnabled()

	const {
		register,
		handleSubmit,
		formState: { errors, isSubmitting },
	} = useForm<LoginFormValues>({
		defaultValues: {
			email: "",
			password: "",
		},
		mode: "onSubmit",
	})

	const onSubmit: SubmitHandler<LoginFormValues> = async (values) => {
		try {
			const result = await loginMutation.mutateAsync({
				email: values.email.trim(),
				password: values.password,
				startUrl,
			})
			window.location.replace(result.redirectUrl)
		} catch {
			// API failures toast via QueryClient MutationCache (useLogin meta).
		}
	}

	const isPending = loginMutation.isPending || isSubmitting

	return (
		<Card className="w-full max-w-auth bg-secondary">
			<CardHeader>
				<CardTitle className="font-sans text-center text-title font-medium">Sign In</CardTitle>
			</CardHeader>
			<CardContent>
				<form
					className="flex flex-col gap-4"
					onSubmit={(event) => {
						void handleSubmit(onSubmit)(event)
					}}
					noValidate
				>
					<div className="flex flex-col gap-2">
						<Label htmlFor="email" className="font-bold">
							Email Address
						</Label>
						<Input
							id="email"
							type="email"
							autoComplete="email"
							disabled={isPending}
							aria-invalid={errors.email ? true : undefined}
							className="h-10 rounded-xl bg-background"
							{...register("email", {
								required: "Email Address is required",
								pattern: {
									value: EMAIL_PATTERN,
									message: "Please enter a valid email address",
								},
							})}
						/>
						{errors.email ? (
							<p className="text-caption text-destructive" role="alert">
								{errors.email.message}
							</p>
						) : null}
					</div>

					<div className="flex flex-col gap-2">
						<Label htmlFor="password" className="font-bold">
							Password
						</Label>
						<Input
							id="password"
							type="password"
							autoComplete="current-password"
							disabled={isPending}
							aria-invalid={errors.password ? true : undefined}
							className="h-10 rounded-xl bg-background"
							{...register("password", {
								required: "Password is required",
							})}
						/>
						{errors.password ? (
							<p className="text-caption text-destructive" role="alert">
								{errors.password.message}
							</p>
						) : null}
					</div>

					<Button type="submit" className="mt-2 h-[60px]" disabled={isPending}>
						{isPending ? "Signing in…" : "Sign In"}
					</Button>

					<div className="flex items-center justify-center gap-2 text-body">
						<a href="/registration" className="font-semibold text-primary hover:underline">
							Create Account
						</a>
						<span className="text-muted-foreground">|</span>
						<a href="/forgot-password" className="font-semibold text-primary hover:underline">
							Reset Password
						</a>
					</div>
				</form>

				{showLocalCli ? (
					<Suspense fallback={null}>
						<LocalCliContinue />
					</Suspense>
				) : null}
			</CardContent>
		</Card>
	)
}

export { LoginForm }
