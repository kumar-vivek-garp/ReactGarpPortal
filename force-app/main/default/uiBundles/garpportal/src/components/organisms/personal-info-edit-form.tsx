import { useId, useRef, useState, type ReactNode } from "react"
import { Controller, useForm, useWatch, type SubmitHandler } from "react-hook-form"
import { CircleUser } from "lucide-react"

import type { AddressFormFields, PersonalInfoEditData } from "@/api/personal-info"
import { copyAddress, phoneCodeOptions } from "@/api/personal-info"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Button } from "@/components/atoms/button"
import { Checkbox } from "@/components/atoms/checkbox"
import { DialogFooter } from "@/components/atoms/dialog"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { Skeleton } from "@/components/atoms/skeleton"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { useCountryOptions } from "@/hooks/use-country-options"
import { usePersonalInfoEditData } from "@/hooks/use-personal-info-edit-data"
import { useProfilePhoto } from "@/hooks/use-profile-photo"
import { useUpdatePersonalInfo } from "@/hooks/use-update-personal-info"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const MAX_PHOTO_BYTES = 2 * 1024 * 1024
const ALLOWED_PHOTO_TYPES = new Set(["image/jpeg", "image/png"])

type PersonalInfoFormValues = {
	firstName: string
	lastName: string
	email: string
	mobilePhoneCode: string
	mobilePhone: string
	billing: AddressFormFields
	mailing: AddressFormFields
	sameAsBilling: boolean
}

const EMPTY_FORM_VALUES: PersonalInfoFormValues = {
	firstName: "",
	lastName: "",
	email: "",
	mobilePhoneCode: "",
	mobilePhone: "",
	billing: {
		company: "",
		address1: "",
		address2: "",
		address3: "",
		country: "",
		city: "",
		state: "",
		postalCode: "",
		phone: "",
	},
	mailing: {
		company: "",
		address1: "",
		address2: "",
		address3: "",
		country: "",
		city: "",
		state: "",
		postalCode: "",
		phone: "",
	},
	sameAsBilling: false,
}

type PersonalInfoEditFormProps = {
	contactId: string
	/** Close the parent dialog after a successful save. */
	onSaved?: () => void
}

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-xs text-destructive" role="alert">
			{message}
		</p>
	)
}

function FormField({
	label,
	htmlFor,
	error,
	children,
	className,
}: {
	label: string
	htmlFor: string
	error?: string
	children: ReactNode
	className?: string
}) {
	return (
		<div className={cn("flex flex-col gap-1.5", className)}>
			<Label htmlFor={htmlFor}>{label}</Label>
			{children}
			<FieldError message={error} />
		</div>
	)
}

function SkeletonField({ className }: { className?: string }) {
	return (
		<div className={cn("flex flex-col gap-1.5", className)}>
			<Skeleton className="h-3.5 w-20" />
			<Skeleton className="h-9 w-full rounded-md" />
		</div>
	)
}

function AddressSkeleton({ titleWidth = "w-28" }: { titleWidth?: string }) {
	return (
		<section className="flex flex-col gap-3">
			<Skeleton className={cn("h-4", titleWidth)} />
			<div className="grid gap-3 sm:grid-cols-2">
				<SkeletonField className="sm:col-span-2" />
				<SkeletonField className="sm:col-span-2" />
				<SkeletonField className="sm:col-span-2" />
				<SkeletonField />
				<SkeletonField />
				<SkeletonField />
				<SkeletonField />
				<SkeletonField className="sm:col-span-2" />
			</div>
		</section>
	)
}

/** Form-shaped placeholder while edit data + countries hydrate. */
function PersonalInfoEditFormSkeleton() {
	return (
		<div
			className="flex flex-col gap-6"
			aria-busy
			aria-label="Loading personal information"
		>
			<section className="flex flex-col gap-3 sm:flex-row sm:items-center">
				<Skeleton className="size-20 shrink-0 rounded-full" />
				<div className="flex flex-wrap gap-2">
					<Skeleton className="h-9 w-28 rounded-full" />
					<Skeleton className="h-9 w-20 rounded-full" />
				</div>
			</section>

			<div className="grid gap-3 sm:grid-cols-2">
				<SkeletonField />
				<SkeletonField />
				<SkeletonField className="sm:col-span-2" />
				<div className="grid grid-cols-[7rem_1fr] gap-2 sm:col-span-2">
					<SkeletonField />
					<SkeletonField />
				</div>
			</div>

			<AddressSkeleton titleWidth="w-32" />

			<div className="flex items-center gap-2">
				<Skeleton className="size-4 rounded-sm" />
				<Skeleton className="h-3.5 w-48" />
			</div>

			<AddressSkeleton titleWidth="w-36" />
		</div>
	)
}

function toFormValues(data: PersonalInfoEditData): PersonalInfoFormValues {
	return {
		firstName: data.firstName,
		lastName: data.lastName,
		email: data.email,
		mobilePhoneCode: data.mobilePhoneCode,
		mobilePhone: data.mobilePhone,
		billing: { ...data.billing },
		mailing: { ...data.mailing },
		sameAsBilling: data.sameAsBilling,
	}
}

function AddressSection({
	prefix,
	title,
	disabled,
	control,
	register,
	errors,
	countryOptions,
	ids,
}: {
	prefix: "billing" | "mailing"
	title: string
	disabled?: boolean
	control: ReturnType<typeof useForm<PersonalInfoFormValues>>["control"]
	register: ReturnType<typeof useForm<PersonalInfoFormValues>>["register"]
	errors: ReturnType<typeof useForm<PersonalInfoFormValues>>["formState"]["errors"]
	countryOptions: Array<{ label: string; value: string }>
	ids: Record<string, string>
}) {
	const sectionErrors = errors[prefix]

	return (
		<section className="flex flex-col gap-3">
			<h3 className="font-heading text-sm font-semibold text-foreground">{title}</h3>
			<FormField
				label="Company"
				htmlFor={ids.company}
				error={sectionErrors?.company?.message}
			>
				<Input
					id={ids.company}
					disabled={disabled}
					aria-invalid={Boolean(sectionErrors?.company)}
					{...register(`${prefix}.company`)}
				/>
			</FormField>
			<FormField
				label="Address line 1"
				htmlFor={ids.address1}
				error={sectionErrors?.address1?.message}
			>
				<Input
					id={ids.address1}
					disabled={disabled}
					aria-invalid={Boolean(sectionErrors?.address1)}
					{...register(`${prefix}.address1`, {
						required: disabled ? false : "Address is required",
					})}
				/>
			</FormField>
			<div className="grid gap-3 sm:grid-cols-2">
				<FormField label="Address line 2" htmlFor={ids.address2}>
					<Input id={ids.address2} disabled={disabled} {...register(`${prefix}.address2`)} />
				</FormField>
				<FormField label="Address line 3" htmlFor={ids.address3}>
					<Input id={ids.address3} disabled={disabled} {...register(`${prefix}.address3`)} />
				</FormField>
			</div>
			<div className="grid gap-3 sm:grid-cols-2">
				<FormField
					label="Country"
					htmlFor={ids.country}
					error={sectionErrors?.country?.message}
				>
					<Controller
						name={`${prefix}.country`}
						control={control}
						rules={{ required: disabled ? false : "Country is required" }}
						render={({ field }) => (
							<Select
								// Remount once options load so a pre-set value (e.g. Aruba)
								// is applied after Radix has matching SelectItems.
								key={`${prefix}-country-${countryOptions.length}-${field.value || "empty"}`}
								value={field.value || undefined}
								onValueChange={field.onChange}
								disabled={disabled || countryOptions.length === 0}
							>
								<SelectTrigger
									id={ids.country}
									className="w-full"
									aria-invalid={Boolean(sectionErrors?.country)}
								>
									<SelectValue placeholder="Select country" />
								</SelectTrigger>
								<SelectContent>
									{countryOptions.map((option) => (
										<SelectItem key={option.value} value={option.value}>
											{option.label}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
						)}
					/>
				</FormField>
				<FormField
					label="City"
					htmlFor={ids.city}
					error={sectionErrors?.city?.message}
				>
					<Input
						id={ids.city}
						disabled={disabled}
						aria-invalid={Boolean(sectionErrors?.city)}
						{...register(`${prefix}.city`, {
							required: disabled ? false : "City is required",
						})}
					/>
				</FormField>
			</div>
			<div className="grid gap-3 sm:grid-cols-2">
				<FormField label="State / Province" htmlFor={ids.state}>
					<Input id={ids.state} disabled={disabled} {...register(`${prefix}.state`)} />
				</FormField>
				<FormField
					label="Postal code"
					htmlFor={ids.postal}
					error={sectionErrors?.postalCode?.message}
				>
					<Input
						id={ids.postal}
						disabled={disabled}
						aria-invalid={Boolean(sectionErrors?.postalCode)}
						{...register(`${prefix}.postalCode`, {
							required: disabled ? false : "Postal code is required",
						})}
					/>
				</FormField>
			</div>
			<FormField label="Phone" htmlFor={ids.phone}>
				<Input id={ids.phone} disabled={disabled} {...register(`${prefix}.phone`)} />
			</FormField>
		</section>
	)
}

function PersonalInfoEditForm({ contactId, onSaved }: PersonalInfoEditFormProps) {
	const formId = useId()
	const fileInputRef = useRef<HTMLInputElement>(null)
	const [photoError, setPhotoError] = useState<string | null>(null)
	/** `undefined` = use server photo; otherwise local override after upload/remove. */
	const [localPhotoUrl, setLocalPhotoUrl] = useState<string | null | undefined>(undefined)

	const editQuery = usePersonalInfoEditData(contactId, Boolean(contactId))
	const countriesQuery = useCountryOptions(Boolean(contactId))
	const updateMutation = useUpdatePersonalInfo()
	const { upload: uploadPhoto, remove: removePhoto } = useProfilePhoto()

	const {
		register,
		control,
		handleSubmit,
		setValue,
		getValues,
		formState: { errors, isSubmitting },
	} = useForm<PersonalInfoFormValues>({
		defaultValues: EMPTY_FORM_VALUES,
		values: editQuery.data ? toFormValues(editQuery.data) : EMPTY_FORM_VALUES,
		mode: "onSubmit",
	})

	const sameAsBilling = useWatch({ control, name: "sameAsBilling" })
	const rawPreviewUrl =
		localPhotoUrl === undefined ? (editQuery.data?.photoUrl ?? null) : localPhotoUrl
	const previewUrl =
		rawPreviewUrl === null
			? null
			: (resolvePortalAssetUrl(rawPreviewUrl) ?? rawPreviewUrl)

	const countries = countriesQuery.data ?? []
	const phoneCodes = phoneCodeOptions(countries)
	const isBusy =
		isSubmitting ||
		updateMutation.isPending ||
		uploadPhoto.isPending ||
		removePhoto.isPending

	const onSubmit: SubmitHandler<PersonalInfoFormValues> = async (values) => {
		const accountId = editQuery.data?.accountId
		if (!accountId) {
			return
		}

		try {
			await updateMutation.mutateAsync({
				contactId,
				accountId,
				firstName: values.firstName,
				lastName: values.lastName,
				email: values.email,
				mobilePhoneCode: values.mobilePhoneCode,
				mobilePhone: values.mobilePhone,
				billing: values.billing,
				mailing: values.sameAsBilling
					? copyAddress(values.billing)
					: values.mailing,
				sameAsBilling: values.sameAsBilling,
			})
			onSaved?.()
		} catch {
			// Toast via MutationCache.
		}
	}

	const handlePhotoSelected = (fileList: FileList | null) => {
		setPhotoError(null)
		const file = fileList?.[0]
		if (!file) return

		if (file.size > MAX_PHOTO_BYTES) {
			setPhotoError("File size should not exceed 2 MB.")
			return
		}
		if (!ALLOWED_PHOTO_TYPES.has(file.type)) {
			setPhotoError("Only JPEG and PNG files are allowed.")
			return
		}

		const reader = new FileReader()
		reader.onload = () => {
			const result = typeof reader.result === "string" ? reader.result : ""
			const base64 = result.includes(",") ? result.split(",")[1] : result
			if (!base64 || !result) {
				setPhotoError("Unable to read the selected file.")
				return
			}
			// Show the selected file immediately; swap to the server URL after upload.
			setLocalPhotoUrl(result)
			void uploadPhoto
				.mutateAsync({
					contactId,
					base64Body: base64,
					fileName: file.name,
				})
				.then((url) => {
					setLocalPhotoUrl(url)
				})
				.catch(() => {
					setLocalPhotoUrl(undefined)
					// Toast via MutationCache.
				})
		}
		reader.onerror = () => {
			setPhotoError("Unable to read the selected file.")
		}
		reader.readAsDataURL(file)
	}

	const handleRemovePhoto = () => {
		setPhotoError(null)
		void removePhoto
			.mutateAsync(contactId)
			.then(() => {
				setLocalPhotoUrl(null)
			})
			.catch(() => {
				// Toast via MutationCache.
			})
	}

	const isLoading = editQuery.isLoading || countriesQuery.isLoading
	const loadFailed = editQuery.isError || !editQuery.data
	const missingAccount = Boolean(editQuery.data && !editQuery.data.accountId)
	const canSubmit = !isLoading && !loadFailed && !missingAccount && !isBusy

	return (
		<form
			className="flex min-h-0 flex-1 flex-col"
			onSubmit={(event) => {
				void handleSubmit(onSubmit)(event)
			}}
			noValidate
		>
			<div className="min-h-0 flex-1 overflow-y-auto px-6 py-4">
				{isLoading ? (
					<PersonalInfoEditFormSkeleton />
				) : loadFailed ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your personal information for editing. Please try
						again later.
					</p>
				) : missingAccount ? (
					<p className="text-sm text-muted-foreground">
						Billing account is unavailable for this profile, so personal information
						cannot be edited right now.
					</p>
				) : (
					<div className="flex flex-col gap-6">
						<section className="flex flex-col gap-3 sm:flex-row sm:items-center">
							<Avatar className="size-20 shrink-0" key={previewUrl ?? "empty"}>
								<AvatarImage
									src={previewUrl ?? undefined}
									alt=""
									className="object-cover"
								/>
								<AvatarFallback className="bg-transparent p-0 text-muted-foreground">
									<CircleUser
										className="size-20"
										strokeWidth={1.25}
										absoluteStrokeWidth
										aria-hidden
									/>
								</AvatarFallback>
							</Avatar>
							<div className="flex flex-wrap gap-2">
								<input
									ref={fileInputRef}
									type="file"
									accept="image/jpeg,image/png"
									className="sr-only"
									onChange={(event) => {
										handlePhotoSelected(event.target.files)
										event.target.value = ""
									}}
								/>
								<Button
									type="button"
									variant="outline"
									size="sm"
									disabled={isBusy}
									onClick={() => fileInputRef.current?.click()}
								>
									{uploadPhoto.isPending ? "Uploading…" : "Upload photo"}
								</Button>
								<Button
									type="button"
									variant="ghost"
									size="sm"
									disabled={isBusy || !previewUrl}
									onClick={handleRemovePhoto}
								>
									{removePhoto.isPending ? "Removing…" : "Remove"}
								</Button>
							</div>
							{photoError ? (
								<p className="w-full text-xs text-destructive" role="alert">
									{photoError}
								</p>
							) : null}
						</section>

						<section className="grid gap-3 sm:grid-cols-2">
							<FormField
								label="First name"
								htmlFor={`${formId}-firstName`}
								error={errors.firstName?.message}
							>
								<Input
									id={`${formId}-firstName`}
									aria-invalid={Boolean(errors.firstName)}
									{...register("firstName", {
										required: "First name is required",
									})}
								/>
							</FormField>
							<FormField
								label="Last name"
								htmlFor={`${formId}-lastName`}
								error={errors.lastName?.message}
							>
								<Input
									id={`${formId}-lastName`}
									aria-invalid={Boolean(errors.lastName)}
									{...register("lastName", {
										required: "Last name is required",
									})}
								/>
							</FormField>
							<FormField
								label="Email"
								htmlFor={`${formId}-email`}
								error={errors.email?.message}
								className="sm:col-span-2"
							>
								<Input
									id={`${formId}-email`}
									type="email"
									autoComplete="email"
									aria-invalid={Boolean(errors.email)}
									{...register("email", {
										required: "Email is required",
										pattern: {
											value: EMAIL_PATTERN,
											message: "Enter a valid email address",
										},
									})}
								/>
							</FormField>
							<FormField
								label="Mobile country code"
								htmlFor={`${formId}-mobileCode`}
								error={errors.mobilePhoneCode?.message}
							>
								<Controller
									name="mobilePhoneCode"
									control={control}
									render={({ field }) => (
										<Select
											value={field.value || undefined}
											onValueChange={field.onChange}
										>
											<SelectTrigger
												id={`${formId}-mobileCode`}
												className="w-full"
												aria-invalid={Boolean(errors.mobilePhoneCode)}
											>
												<SelectValue placeholder="Select country code" />
											</SelectTrigger>
											<SelectContent>
												{phoneCodes.map((option) => (
													<SelectItem key={option.value} value={option.value}>
														{option.label}
													</SelectItem>
												))}
											</SelectContent>
										</Select>
									)}
								/>
							</FormField>
							<FormField
								label="Mobile number"
								htmlFor={`${formId}-mobilePhone`}
								error={errors.mobilePhone?.message}
							>
								<Input
									id={`${formId}-mobilePhone`}
									type="tel"
									aria-invalid={Boolean(errors.mobilePhone)}
									{...register("mobilePhone")}
								/>
							</FormField>
						</section>

						<AddressSection
							prefix="billing"
							title="Billing address"
							control={control}
							register={register}
							errors={errors}
							countryOptions={countries}
							ids={{
								company: `${formId}-billing-company`,
								address1: `${formId}-billing-address1`,
								address2: `${formId}-billing-address2`,
								address3: `${formId}-billing-address3`,
								country: `${formId}-billing-country`,
								city: `${formId}-billing-city`,
								state: `${formId}-billing-state`,
								postal: `${formId}-billing-postal`,
								phone: `${formId}-billing-phone`,
							}}
						/>

						<div className="flex items-center gap-2">
							<Controller
								name="sameAsBilling"
								control={control}
								render={({ field }) => (
									<Checkbox
										id={`${formId}-sameAsBilling`}
										checked={field.value}
										onCheckedChange={(checked) => {
											const next = checked === true
											field.onChange(next)
											if (next) {
												setValue("mailing", copyAddress(getValues("billing")), {
													shouldDirty: true,
												})
											}
										}}
									/>
								)}
							/>
							<Label htmlFor={`${formId}-sameAsBilling`} className="font-normal">
								Mailing address is the same as billing address
							</Label>
						</div>

						<AddressSection
							prefix="mailing"
							title="Mailing address"
							disabled={sameAsBilling}
							control={control}
							register={register}
							errors={errors}
							countryOptions={countries}
							ids={{
								company: `${formId}-mailing-company`,
								address1: `${formId}-mailing-address1`,
								address2: `${formId}-mailing-address2`,
								address3: `${formId}-mailing-address3`,
								country: `${formId}-mailing-country`,
								city: `${formId}-mailing-city`,
								state: `${formId}-mailing-state`,
								postal: `${formId}-mailing-postal`,
								phone: `${formId}-mailing-phone`,
							}}
						/>
					</div>
				)}
			</div>

			<DialogFooter className="shrink-0 border-t border-border px-6 py-4 sm:justify-end">
				<Button type="submit" disabled={!canSubmit}>
					{updateMutation.isPending ? "Saving…" : "Save"}
				</Button>
			</DialogFooter>
		</form>
	)
}

export { PersonalInfoEditForm }
