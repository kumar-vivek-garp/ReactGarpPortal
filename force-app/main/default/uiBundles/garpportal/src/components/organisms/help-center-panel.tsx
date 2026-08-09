import { useForm, type SubmitHandler } from "react-hook-form"

import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { Textarea } from "@/components/atoms/textarea"
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

function HelpCenterPanel({ className }: { className?: string }) {
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
		} catch {
			// Toast via MutationCache.
		}
	}

	return (
		<div className={cn("space-y-6", className)}>
			<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
				Help Center
			</h1>

			<section className="max-w-2xl space-y-4">
				<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
					Open Support Case
				</h2>

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
							rows={8}
							maxLength={DESCRIPTION_MAX}
							aria-invalid={Boolean(errors.description)}
							disabled={isBusy}
							className="min-h-40"
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
			</section>
		</div>
	)
}

export { HelpCenterPanel }
