import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_authLayout/Login/")({
	component: Login,
});

function Login() {
	return <div>Login</div>;
}
