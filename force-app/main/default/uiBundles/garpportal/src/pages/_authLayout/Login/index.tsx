import { createFileRoute } from "@tanstack/react-router";

import { LoginForm } from "@/components/organisms/login-form";

export const Route = createFileRoute("/_authLayout/Login/")({
	component: Login,
});

const FOOTER_LINKS = [
	{ label: "Bylaws", href: "https://www.garp.org/bylaws" },
	{ label: "Code of Conduct", href: "https://www.garp.org/code-of-conduct" },
	{ label: "Privacy Notice", href: "https://www.garp.org/privacy-notice" },
	{ label: "Terms of Use", href: "https://www.garp.org/terms-of-use" },
];

function Login() {
	return (
		<div className="flex min-h-screen flex-col items-center justify-center gap-8 bg-[url('https://www.garp.org/hubfs/GARP%20Design/membership/image/bckgd-dark-gradient-1.png')] bg-cover bg-fixed bg-no-repeat px-4 py-12">
			<img
				src="https://www.garp.org/hubfs/Website/Logos/GARP%20Corporate%20Logo%20-%20Full%20Knockout.png"
				alt="GARP - Global Association of Risk Professionals"
				className="h-auto w-full max-w-sm"
			/>
			<LoginForm />
			<footer className="flex flex-col items-center gap-3 text-sm text-corporate-navy-foreground">
				<ul className="flex flex-wrap justify-center gap-4">
					{FOOTER_LINKS.map((link) => (
						<li key={link.label}>
							<a href={link.href} target="_blank" rel="noreferrer" className="hover:underline">
								{link.label}
							</a>
						</li>
					))}
				</ul>
				<p>&copy; {new Date().getFullYear()} Global Association of Risk Professionals</p>
			</footer>
		</div>
	);
}
