import { useState } from "react"
import { useForm, type SubmitHandler } from "react-hook-form"
import {
	BookOpen,
	CircleHelp,
	Mail,
	type LucideIcon,
} from "lucide-react"

import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { Textarea } from "@/components/atoms/textarea"
import { CardCta } from "@/components/molecules/card-cta"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import {
	CONTACT_US_URL,
	HELP_RESOURCE_LINKS,
	MEMBER_SERVICES_MAILTO,
} from "@/config/help-center"
import { useSubmitCase } from "@/hooks/use-submit-case"
import { cn } from "@/lib/utils"

const SUBJECT_MAX = 255
const DESCRIPTION_MAX = 3200

type SupportCaseFormValues = {
	subject: string
	description: string
}

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

function ResourceLink({
	href,
	icon: Icon,
	children,
}: {
	href: string
	icon: LucideIcon
	children: string
}) {
	return (
		<div className="flex items-center gap-2">
			<Icon className="size-4 shrink-0 text-primary" aria-hidden />
			<CardCta label={children} url={href} isExternal newWindow />
		</div>
	)
}

function HelpCenterPanel({ className }: { className?: string }) {
	const submitCase = useSubmitCase()
	const [sent, setSent] = useState(false)

	const {
		register,
		handleSubmit,
		reset,
		formState: { errors, isSubmitting },
	} = useForm<SupportCaseFormValues>({
		defaultValues: { subject: "", description: "" },
		mode: "onSubmit",
	})

	const isBusy = isSubmitting || submitCase.isPending

	const onSubmit: SubmitHandler<SupportCaseFormValues> = async (values) => {
		try {
			await submitCase.mutateAsync({
				subject: values.subject,
				description: values.description,
			})
			reset({ subject: "", description: "" })
			setSent(true)
		} catch {
			// Toast via MutationCache.
		}
	}

	return (
		<StaggerReveal className={cn("space-y-8", className)}>
			<div>
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Help Center
				</h1>
				<p className="mt-1 text-sm text-muted-foreground">
					Open a support case with Member Services, or use the links for FAQs
					and other contact options.
				</p>
			</div>

			<div className="grid items-start gap-10 lg:grid-cols-[minmax(0,1fr)_18rem] lg:gap-16">
				<section className="min-w-0 space-y-5">
					<div>
						<h2 className="font-heading text-lg font-semibold tracking-wide text-foreground">
							Open Support Case
						</h2>
						<p className="mt-1 text-sm text-muted-foreground">
							Tell us what you need help with. A representative from Member
							Services will follow up.
						</p>
					</div>

					{sent ? (
						<div className="space-y-4">
							<p className="text-sm text-foreground">
								Thank you for your submission.
							</p>
							<p className="text-sm text-muted-foreground">
								A representative from Member Services will be in touch with you
								shortly.
							</p>
							<Button
								type="button"
								variant="outline"
								onClick={() => setSent(false)}
							>
								Open another case
							</Button>
						</div>
					) : (
						<form
							className="space-y-5"
							onSubmit={(event) => {
								void handleSubmit(onSubmit)(event)
							}}
							noValidate
						>
							<div className="flex flex-col gap-1.5">
								<Label htmlFor="help-center-subject">Subject</Label>
								<Input
									id="help-center-subject"
									maxLength={SUBJECT_MAX}
									aria-invalid={Boolean(errors.subject)}
									disabled={isBusy}
									{...register("subject", {
										required: "Subject is required",
										maxLength: {
											value: SUBJECT_MAX,
											message: `Subject must be ${SUBJECT_MAX} characters or fewer`,
										},
									})}
								/>
								<FieldError message={errors.subject?.message} />
							</div>

							<div className="flex flex-col gap-1.5">
								<Label htmlFor="help-center-description">Description</Label>
								<Textarea
									id="help-center-description"
									rows={10}
									maxLength={DESCRIPTION_MAX}
									aria-invalid={Boolean(errors.description)}
									disabled={isBusy}
									className="min-h-48"
									{...register("description", {
										required: "Description is required",
										maxLength: {
											value: DESCRIPTION_MAX,
											message: `Description must be ${DESCRIPTION_MAX} characters or fewer`,
										},
									})}
								/>
								<FieldError message={errors.description?.message} />
							</div>

							<div className="flex justify-end">
								<Button type="submit" disabled={isBusy}>
									{isBusy ? "Submitting…" : "Submit"}
								</Button>
							</div>
						</form>
					)}
				</section>

				<aside className="space-y-4 lg:border-l lg:border-border/60 lg:pl-10">
					<div>
						<h2 className="font-heading text-lg font-semibold tracking-wide text-foreground">
							Other ways to get help
						</h2>
						<p className="mt-1 text-sm text-muted-foreground">
							Email Member Services or browse public FAQs.
						</p>
					</div>
					<div className="flex flex-col gap-3">
						<ResourceLink href={MEMBER_SERVICES_MAILTO} icon={Mail}>
							Email Member Services
						</ResourceLink>
						<ResourceLink href={CONTACT_US_URL} icon={CircleHelp}>
							Contact Us
						</ResourceLink>
						{HELP_RESOURCE_LINKS.map((link) => (
							<ResourceLink key={link.url} href={link.url} icon={BookOpen}>
								{link.title}
							</ResourceLink>
						))}
					</div>
				</aside>
			</div>
		</StaggerReveal>
	)
}

export { HelpCenterPanel }
