import { useId, useRef, useState } from "react"
import { FileText, Loader2, Paperclip, Trash2, Upload } from "lucide-react"

import type { CvAttachmentInfo } from "@/api/work-experience"
import { Button } from "@/components/atoms/button"
import { Skeleton } from "@/components/atoms/skeleton"
import {
	CV_MAX_UPLOAD_LABEL,
	CV_UPLOAD_ACCEPT,
} from "@/config/work-experience"
import {
	useCvAttachments,
	useDeleteCvAttachment,
	useUploadCvAttachment,
} from "@/hooks/use-cv"
import { readFileAsBase64 } from "@/lib/read-file-base64"
import { cn } from "@/lib/utils"
import {
	formatFileSize,
	validateCvUpload,
} from "@/lib/work-experience-presentation"

type CvAttachmentManagerProps = {
	/** Null until the experience has been saved — files need a parent record. */
	experienceId: string | null
	/** Apex's own list of what this role needs, when it asks for anything. */
	requiredDocuments?: string[] | null
	documentMessage?: string | null
	required?: boolean
	className?: string
}

/**
 * Supporting documents for one experience.
 *
 * An unsaved experience has nothing to attach to — Apex needs a parent record
 * id — so the picker is replaced by a line saying to save first rather than
 * being offered and then failing with "Work Experience not found".
 *
 * Every rejection reason is shown next to the picker: the file that was too
 * large, the type that is not accepted, and the server's own sentence when an
 * upload fails. The legacy showed none of them.
 */
function CvAttachmentManager({
	experienceId,
	requiredDocuments,
	documentMessage,
	required,
	className,
}: CvAttachmentManagerProps) {
	const inputId = useId()
	const inputRef = useRef<HTMLInputElement>(null)
	const [localError, setLocalError] = useState<string | null>(null)
	const [pendingName, setPendingName] = useState<string | null>(null)

	const key = experienceId?.trim() ?? ""
	const attachments = useCvAttachments(key, Boolean(key))
	const upload = useUploadCvAttachment()
	const remove = useDeleteCvAttachment()

	const files: CvAttachmentInfo[] = attachments.data?.attachments ?? []
	const isBusy = upload.isPending || remove.isPending

	const onPick = async (file: File | undefined) => {
		if (!file || !key) return
		setLocalError(null)

		const problem = validateCvUpload(file)
		if (problem) {
			setLocalError(problem)
			return
		}

		setPendingName(file.name)
		try {
			const fileText = await readFileAsBase64(file)
			await upload.mutateAsync({
				experienceId: key,
				fileName: file.name,
				fileText,
			})
		} catch {
			// Read failures surface here; server failures toast from the
			// MutationCache carrying Apex's own `data.message`.
			setLocalError((current) => current ?? "This file could not be read.")
		} finally {
			setPendingName(null)
			// Lets the member re-pick the same file after fixing the problem.
			if (inputRef.current) inputRef.current.value = ""
		}
	}

	return (
		<div className={cn("space-y-3", className)}>
			<div className="flex items-center gap-2">
				<Paperclip className="size-4 text-muted-foreground" aria-hidden />
				<p className="font-heading text-sm font-semibold tracking-wide text-foreground">
					Supporting documents
				</p>
			</div>

			{documentMessage ? (
				<p
					className={cn(
						"text-sm",
						required ? "text-foreground" : "text-muted-foreground",
					)}
				>
					{documentMessage}
				</p>
			) : null}

			{/* Can be null while `required` is true — never mapped unguarded. */}
			{requiredDocuments && requiredDocuments.length > 0 ? (
				<ul className="list-disc space-y-1 pl-5 text-sm text-muted-foreground">
					{requiredDocuments.map((document) => (
						<li key={document}>{document}</li>
					))}
				</ul>
			) : null}

			{!key ? (
				<p className="rounded-lg border border-dashed border-border bg-muted/20 px-4 py-3 text-sm text-muted-foreground">
					Save this experience first, then add any documents it needs.
				</p>
			) : (
				<>
					{attachments.isLoading ? (
						<div className="space-y-2" aria-busy>
							<Skeleton className="h-9 w-full rounded-lg" />
						</div>
					) : null}

					{!attachments.isLoading && files.length > 0 ? (
						<ul className="divide-y divide-border/80 rounded-lg border border-border">
							{files.map((file, index) => {
								const size = formatFileSize(file.size)
								return (
									<li
										key={file.id ?? `attachment-${index}`}
										className="flex items-center gap-3 px-3 py-2"
									>
										<FileText
											className="size-4 shrink-0 text-muted-foreground"
											aria-hidden
										/>
										<span className="min-w-0 flex-1 truncate text-sm text-foreground">
											{file.name ?? "Untitled file"}
										</span>
										{size ? (
											<span className="shrink-0 text-xs text-muted-foreground tabular-nums">
												{size}
											</span>
										) : null}
										{file.id ? (
											<Button
												type="button"
												variant="ghost"
												size="icon-sm"
												aria-label={`Remove ${file.name ?? "this file"}`}
												className="shrink-0 text-muted-foreground hover:text-destructive"
												disabled={isBusy}
												onClick={() => void remove.mutateAsync(file.id ?? "")}
											>
												<Trash2 className="size-4" />
											</Button>
										) : null}
									</li>
								)
							})}
						</ul>
					) : null}

					<div className="flex flex-wrap items-center gap-3">
						<input
							ref={inputRef}
							id={inputId}
							type="file"
							accept={CV_UPLOAD_ACCEPT}
							className="sr-only"
							onChange={(event) => void onPick(event.target.files?.[0])}
						/>
						<Button
							type="button"
							variant="outline"
							size="sm"
							disabled={isBusy}
							onClick={() => inputRef.current?.click()}
						>
							{upload.isPending ? (
								<Loader2 className="size-4 animate-spin" aria-hidden />
							) : (
								<Upload className="size-4" aria-hidden />
							)}
							{upload.isPending ? "Uploading…" : "Add a file"}
						</Button>
						<span className="text-xs text-muted-foreground">
							Up to {CV_MAX_UPLOAD_LABEL}
						</span>
					</div>

					{pendingName ? (
						<p className="text-xs text-muted-foreground">
							Uploading {pendingName}…
						</p>
					) : null}

					{localError ? (
						<p className="text-xs text-destructive" role="alert">
							{localError}
						</p>
					) : null}
				</>
			)}
		</div>
	)
}

export { CvAttachmentManager }
