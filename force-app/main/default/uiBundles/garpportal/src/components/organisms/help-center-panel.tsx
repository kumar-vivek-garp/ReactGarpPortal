import { useState } from "react"
import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"
import { useForm, type SubmitHandler } from "react-hook-form"

import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { Textarea } from "@/components/atoms/textarea"
import { HelpCenterRequests } from "@/components/molecules/help-center-requests"
import { HelpCenterResources } from "@/components/molecules/help-center-resources"
import { HelpCenterRequestsSkeleton } from "@/components/molecules/page-pending"
import {
	HELP_CENTER_BUCKET_META,
	HELP_CENTER_TAB_ITEMS,
	type HelpCenterTab,
} from "@/config/help-center"
import { useCases } from "@/hooks/use-cases"
import { useSubmitCase } from "@/hooks/use-submit-case"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

const SUBJECT_MAX = 255
const DESCRIPTION_MAX = 3200

type SupportCaseFormValues = {
	subject: string
	description: string
}

type HelpCenterPanelProps = {
	tab: HelpCenterTab
	className?: string
}

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

function SupportCaseForm({ onSubmitted }: { onSubmitted: () => void }) {
	const submitCase = useSubmitCase()
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
			onSubmitted()
		} catch {
			// Toast via MutationCache.
		}
	}

	return (
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
	)
}

function GetHelpTabBody({ onSubmitted }: { onSubmitted: () => void }) {
	const { icon: Icon, heading } = HELP_CENTER_BUCKET_META["get-help"]

	return (
		<div className="grid items-start gap-8 lg:grid-cols-[minmax(0,7fr)_minmax(0,3fr)] lg:gap-10">
			<section className="min-w-0 space-y-5">
				<div>
					<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
						<Icon className="size-5 shrink-0 text-primary" aria-hidden />
						{heading}
					</h2>
					<p className="mt-1 text-sm text-muted-foreground">
						Tell us what you need help with. A representative from Member
						Services will follow up.
					</p>
				</div>

				<SupportCaseForm onSubmitted={onSubmitted} />
			</section>

			<HelpCenterResources className="lg:h-full" />
		</div>
	)
}

function RequestsTabBody() {
	const { data, isPending, isError } = useCases()

	if (isPending) return <HelpCenterRequestsSkeleton />

	if (isError) {
		return (
			<p className="text-sm text-muted-foreground">
				We couldn&apos;t load your requests. Please try again later.
			</p>
		)
	}

	// The pill already names this section, so the heading would just repeat it.
	return <HelpCenterRequests cases={data ?? []} showHeading={false} />
}

function HelpCenterPanel({ tab, className }: HelpCenterPanelProps) {
	const navigate = useNavigate({ from: "/help-center/" })
	const { data } = useCases()
	const [justSubmitted, setJustSubmitted] = useState(false)

	const selectTab = (next: HelpCenterTab) => {
		void navigate({ search: { tab: next }, replace: true })
	}

	/**
	 * Land on the requests list after submitting: the new case appearing with a
	 * status is stronger confirmation than a thank-you message, and it is where
	 * the member will look to track it.
	 */
	const handleSubmitted = () => {
		setJustSubmitted(true)
		selectTab("requests")
	}

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => selectTab(value as HelpCenterTab)}
			className={cn("gap-0", className)}
		>
			<header className="space-y-4">
				<div>
					<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
						Help Center
					</h1>
					<p className="mt-1 max-w-2xl text-sm text-muted-foreground">
						Open a support case with Member Services, track requests you have
						already raised, or use the links for FAQs and other contact options.
					</p>
				</div>

				<PillTabs
					items={HELP_CENTER_TAB_ITEMS.map((item) =>
						item.value === "requests"
							? { ...item, count: data?.length ?? 0 }
							: item,
					)}
					value={tab}
				/>
			</header>

			<div className="mt-6">
				{justSubmitted && tab === "requests" ? (
					<p className="mb-4 rounded-xl border border-border bg-muted/40 px-4 py-3 text-sm text-foreground">
						Thanks — your case has been submitted. Member Services will follow
						up, and you can track it below.
					</p>
				) : null}

				{tabTransitions((style, currentTab) => (
					<animated.div key={currentTab} role="tabpanel" style={style}>
						{currentTab === "get-help" ? (
							<GetHelpTabBody onSubmitted={handleSubmitted} />
						) : (
							<RequestsTabBody />
						)}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export { HelpCenterPanel }
