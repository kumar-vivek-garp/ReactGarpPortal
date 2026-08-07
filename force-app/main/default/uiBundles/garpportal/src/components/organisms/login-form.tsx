import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"

function LoginForm() {
	return (
		<Card className="w-full max-w-[420px] bg-secondary">
			<CardHeader>
				<CardTitle className="text-center text-3xl font-medium">Sign In</CardTitle>
			</CardHeader>
			<CardContent>
				<form className="flex flex-col gap-4">
					<div className="flex flex-col gap-2">
						<Label htmlFor="email" className="font-bold">Email Address</Label>
						<Input
							id="email"
							name="email"
							type="email"
							autoComplete="email"
							required
							className="h-10 rounded-xl bg-background"
						/>
					</div>
					<div className="flex flex-col gap-2">
						<Label htmlFor="password" className="font-bold">Password</Label>
						<Input
							id="password"
							name="password"
							type="password"
							autoComplete="current-password"
							required
							className="h-10 rounded-xl bg-background"
						/>
					</div>
					<Button type="submit" className="mt-2 h-[60px]">
						Sign In
					</Button>
					<div className="flex items-center justify-center gap-2 text-sm">
						<a href="/registration" className="font-semibold text-primary hover:underline">
							Create Account
						</a>
						<span className="text-muted-foreground">|</span>
						<a href="/forgot-password" className="font-semibold text-primary hover:underline">
							Reset Password
						</a>
					</div>
				</form>
			</CardContent>
		</Card>
	)
}

export { LoginForm }
