import { useId, useRef, useState } from "react"
import { Controller, useForm, useWatch } from "react-hook-form"
import { Paperclip, X } from "lucide-react"

import type { ErrataFormView } from "@/api/errata"
import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { Textarea } from "@/components/atoms/textarea"
import {
	ERRATA_MAX_UPLOAD_LABEL,
	ERRATA_UPLOAD_ACCEPT,
} from "@/config/errata"
import { useSubmitErrata, type ErrataSubmitOutcome } from "@/hooks/use-errata"
import {
	EMPTY_ERRATA_FORM,
	errataBookOptions,
	errataMaterialOptions,
	errataPageLabel,
	toErrataSubmission,
	validateErrataUpload,
	type ErrataFormValues,
} from "@/lib/errata-presentation"

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

function Field({
	id,
	label,
	required,
	error,
	hint,
	children,
}: {
	id: string
	label: string
	required?: boolean
	error?: string
	hint?: string
	children: React.ReactNode
}) {
	return (
		<div className="space-y-1.5">
			<Label htmlFor={id} className="text-sm">
				{label}
				{required ? (
					<span className="text-destructive" aria-hidden>
						{" "}
						*
					</span>
				) : null}
			</Label>
			{children}
			{hint && !error ? (
				<p className="text-xs text-muted-foreground">{hint}</p>
			) : null}
			<FieldError message={error} />
		</div>
	)
}

type ErrataFormProps = {
	programType: string
	view: ErrataFormView
	onSubmitted: (outcome: ErrataSubmitOutcome) => void
}

/**
 * The report form.
 *
 * Every field is validated here, because Apex answers a single 501 "Required
 * information missing" for any of the five it needs — a message that cannot
 * tell the member which one is blank.
 *
 * The body is built by `toErrataSubmission`, which pins the `studyMaterial` /
 * `book` inversion. Do not assemble it inline.
 */
function ErrataForm({ programType, view, onSubmitted }: ErrataFormProps) {
	const formId = useId()
	const fileRef = useRef<HTMLInputElement>(null)
	const [file, setFile] = useState<File | null>(null)
	const [fileError, setFileError] = useState<string | null>(null)
	const mutation = useSubmitErrata()

	const {
		control,
		register,
		handleSubmit,
		setValue,
		formState: { errors, isSubmitting },
	} = useForm<ErrataFormValues>({
		defaultValues: EMPTY_ERRATA_FORM,
		mode: "onSubmit",
	})

	const studyMaterial = useWatch({ control, name: "studyMaterial" }) ?? ""
	const materials = errataMaterialOptions(view)
	const books = errataBookOptions(view, studyMaterial)
	const isBusy = isSubmitting || mutation.isPending

	const pickFile = (chosen: File | undefined) => {
		setFileError(null)
		if (!chosen) return
		const problem = validateErrataUpload(chosen)
		if (problem) {
			setFileError(problem)
			if (fileRef.current) fileRef.current.value = ""
			return
		}
		setFile(chosen)
	}

	const onSubmit = async (values: ErrataFormValues) => {
		try {
			const outcome = await mutation.mutateAsync({
				submission: toErrataSubmission(programType, values),
				file,
			})
			onSubmitted(outcome)
		} catch {
			// Toast comes from the shared MutationCache. The legacy set a failure
			// message it never rendered and left Submit stuck on "Submitting…".
		}
	}

	return (
		<form
			onSubmit={(event) => void handleSubmit(onSubmit)(event)}
			className="space-y-4"
		>
			<Controller
				control={control}
				name="studyMaterial"
				rules={{ required: "Please select a study material." }}
				render={({ field }) => (
					<Field
						id={`${formId}-material`}
						label="What study material does the error pertain to?"
						required
						error={errors.studyMaterial?.message}
					>
						<Select
							value={field.value || undefined}
							onValueChange={(next) => {
								field.onChange(next)
								/*
								 * Always clear the book. Both halves are free-form strings
								 * by the time Apex sees them, so a value left over from the
								 * previous material would be accepted and the report filed
								 * against a section that material does not contain.
								 */
								setValue("book", "")
							}}
						>
							<SelectTrigger id={`${formId}-material`} className="w-full">
								<SelectValue placeholder="Select…" />
							</SelectTrigger>
							<SelectContent>
								{materials.map((material) => (
									<SelectItem key={material} value={material}>
										{material}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					</Field>
				)}
			/>

			<Controller
				control={control}
				name="book"
				rules={{ required: "Please select a book." }}
				render={({ field }) => (
					<Field
						id={`${formId}-book`}
						label="What book does the error pertain to?"
						required
						error={errors.book?.message}
						hint={
							studyMaterial ? undefined : "Choose a study material first."
						}
					>
						<Select
							key={`book-${studyMaterial}`}
							value={field.value || undefined}
							onValueChange={field.onChange}
							disabled={books.length === 0}
						>
							<SelectTrigger id={`${formId}-book`} className="w-full">
								<SelectValue placeholder="Select…" />
							</SelectTrigger>
							<SelectContent>
								{books.map((book) => (
									<SelectItem key={book} value={book}>
										{book}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					</Field>
				)}
			/>

			<Field
				id={`${formId}-page`}
				label={errataPageLabel(studyMaterial)}
				required
				error={errors.pageNumber?.message}
			>
				<Input
					id={`${formId}-page`}
					{...register("pageNumber", {
						required: "Please say where the error appears.",
					})}
				/>
			</Field>

			<Field
				id={`${formId}-description`}
				label="Describe the problem"
				required
				error={errors.errorDescription?.message}
				hint="The section title or number, and as much context as you can give."
			>
				<Textarea
					id={`${formId}-description`}
					rows={5}
					{...register("errorDescription", {
						required: "Please describe the problem.",
					})}
				/>
			</Field>

			<Field
				id={`${formId}-correction`}
				label="What do you think the correction should be?"
				hint="Optional, but it speeds up review."
			>
				<Textarea
					id={`${formId}-correction`}
					rows={3}
					{...register("correction")}
				/>
			</Field>

			<div className="space-y-2">
				<Label className="text-sm">Supporting file</Label>
				<input
					ref={fileRef}
					type="file"
					accept={ERRATA_UPLOAD_ACCEPT}
					className="sr-only"
					onChange={(event) => pickFile(event.target.files?.[0])}
				/>
				{file ? (
					<div className="flex items-center gap-2 rounded-lg border border-border px-3 py-2">
						<Paperclip
							className="size-4 shrink-0 text-muted-foreground"
							aria-hidden
						/>
						<span className="min-w-0 flex-1 truncate text-sm text-foreground">
							{file.name}
						</span>
						<Button
							type="button"
							variant="ghost"
							size="icon-sm"
							aria-label={`Remove ${file.name}`}
							onClick={() => {
								setFile(null)
								if (fileRef.current) fileRef.current.value = ""
							}}
						>
							<X className="size-4" />
						</Button>
					</div>
				) : (
					<div className="flex flex-wrap items-center gap-3">
						<Button
							type="button"
							variant="outline"
							size="sm"
							onClick={() => fileRef.current?.click()}
						>
							<Paperclip className="size-4" aria-hidden />
							Add a file
						</Button>
						<span className="text-xs text-muted-foreground">
							Optional · up to {ERRATA_MAX_UPLOAD_LABEL}
						</span>
					</div>
				)}
				<FieldError message={fileError ?? undefined} />
			</div>

			<Button type="submit" disabled={isBusy}>
				{isBusy ? "Submitting…" : "Submit report"}
			</Button>
		</form>
	)
}

export { ErrataForm }
