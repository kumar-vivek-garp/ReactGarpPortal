import { addYears, startOfMonth } from "date-fns"
import { BookUser, Car, IdCard } from "lucide-react"
import { Controller, type Control, type FieldErrors } from "react-hook-form"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import { DatePicker } from "@/components/molecules/date-picker"
import { FieldError, FormField } from "@/components/molecules/form-field"
import { TileRadioGroup, type TileRadioOption } from "@/components/molecules/tile-radio-group"
import { OptionSelect } from "@/components/forms/exam-setup/sections/option-select"
import {
	EXAM_SETUP_ID_TYPES,
	EXAM_SETUP_MOBILE_HINT,
	EXAM_SETUP_SECTIONS,
} from "@/config/exam-setup"
import type { ExamSetupIdFormValues } from "@/lib/exam-setup-presentation"

/** The two documents, each with the thing it is. */
const ID_TYPE_ICONS: Record<string, TileRadioOption["icon"]> = {
	passport: BookUser,
	"driver license": Car,
}

const ID_TYPE_OPTIONS: TileRadioOption[] = EXAM_SETUP_ID_TYPES.map((option) => ({
	value: option.value,
	label: option.label,
	icon: ID_TYPE_ICONS[option.value] ?? IdCard,
}))

/** An ID is good for a decade or so; twenty years of dropdown covers every issuer. */
const EXPIRY_YEARS_AHEAD = 20

type IdentitySectionProps = {
	control: Control<ExamSetupIdFormValues>
	errors: FieldErrors<ExamSetupIdFormValues>
	/** True for FRM, the only programme whose sites demand a government ID. */
	isFrm: boolean
	/** Apex `isOSTA` — switches the number field's placeholder to the full number. */
	isOSTA: boolean
	/** Picklist values of `Contact.Mobile_Phone_Code__c`. */
	mobilePhoneLocations: string[]
}

/**
 * "Confirm your ID" — the details the test centre checks on exam day.
 *
 * FRM sites demand a government ID, so the type, number, confirmation and
 * expiry appear and are mandatory there. Every other programme gives only a
 * name and a contact number.
 */
function IdentitySection({
	control,
	errors,
	isFrm,
	isOSTA,
	mobilePhoneLocations,
}: IdentitySectionProps) {
	const thisMonth = startOfMonth(new Date())

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-lg">
					<IdCard className="size-5 text-muted-foreground" aria-hidden />
					{EXAM_SETUP_SECTIONS.identity.title}
				</CardTitle>
				<p className="text-body text-muted-foreground">
					{EXAM_SETUP_SECTIONS.identity.description}
				</p>
			</CardHeader>
			<CardContent className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				{isFrm ? (
					<>
						<Controller
							control={control}
							name="idType"
							render={({ field }) => (
								<TileRadioGroup
									id="exam-setup-id-type"
									legend="ID type"
									required
									value={field.value}
									options={ID_TYPE_OPTIONS}
									onChange={field.onChange}
									error={errors.idType?.message}
									className="sm:col-span-2"
								/>
							)}
						/>

						<Controller
							control={control}
							name="idNumber"
							render={({ field }) => (
								<FormField
									id="exam-setup-id-number"
									label="ID number"
									required
									error={errors.idNumber?.message}
								>
									<Input
										id="exam-setup-id-number"
										placeholder={isOSTA ? "Enter ID Number" : "Last 5 digits of your ID"}
										aria-invalid={errors.idNumber ? true : undefined}
										{...field}
									/>
								</FormField>
							)}
						/>

						<Controller
							control={control}
							name="idNumberConfirm"
							render={({ field }) => (
								<FormField
									id="exam-setup-id-number-confirm"
									label="Confirm ID number"
									required
									error={errors.idNumberConfirm?.message}
								>
									<Input
										id="exam-setup-id-number-confirm"
										placeholder={isOSTA ? "Confirm ID Number" : "Last 5 digits of your ID"}
										aria-invalid={errors.idNumberConfirm ? true : undefined}
										{...field}
									/>
								</FormField>
							)}
						/>

						<Controller
							control={control}
							name="idExpireDate"
							render={({ field }) => (
								<FormField
									id="exam-setup-id-expiry"
									label="ID expiration date"
									required
									error={errors.idExpireDate?.message}
								>
									{/* ISO in and out — what Apex returns and what `toIdInput` converts. */}
									<DatePicker
										id="exam-setup-id-expiry"
										value={field.value}
										onChange={field.onChange}
										placeholder="Select the expiry date"
										startMonth={thisMonth}
										endMonth={addYears(thisMonth, EXPIRY_YEARS_AHEAD)}
										aria-invalid={Boolean(errors.idExpireDate)}
									/>
								</FormField>
							)}
						/>
					</>
				) : null}

				<Controller
					control={control}
					name="idName"
					render={({ field }) => (
						<FormField
							id="exam-setup-id-name"
							label="Name as it appears on your ID"
							required
							error={errors.idName?.message}
							className={isFrm ? undefined : "sm:col-span-2"}
						>
							<Input
								id="exam-setup-id-name"
								autoComplete="name"
								aria-invalid={errors.idName ? true : undefined}
								{...field}
							/>
						</FormField>
					)}
				/>

				{/* One label over two controls and one message: the code and the
				    number are useless apart, so a message under each would say
				    the same thing twice. */}
				<div className="flex flex-col gap-2 sm:col-span-2">
					<Label htmlFor="exam-setup-phone-number" className="font-bold">
						Mobile number
						<span className="text-destructive" aria-hidden>
							{" "}
							*
						</span>
					</Label>
					<div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
						<Controller
							control={control}
							name="mobilePhoneLocation"
							render={({ field }) => (
								<OptionSelect
									id="exam-setup-phone-location"
									value={field.value}
									options={mobilePhoneLocations}
									placeholder="Country code"
									onChange={field.onChange}
									aria-label="Mobile number country code"
									aria-invalid={Boolean(errors.mobilePhoneLocation)}
								/>
							)}
						/>
						<Controller
							control={control}
							name="mobilePhoneNumber"
							render={({ field }) => (
								<div className="sm:col-span-2">
									<Input
										id="exam-setup-phone-number"
										type="tel"
										inputMode="numeric"
										autoComplete="tel"
										aria-invalid={errors.mobilePhoneLocation ? true : undefined}
										{...field}
									/>
								</div>
							)}
						/>
					</div>
					<FieldError message={errors.mobilePhoneLocation?.message} />
					<p className="text-caption text-muted-foreground">{EXAM_SETUP_MOBILE_HINT}</p>
				</div>
			</CardContent>
		</Card>
	)
}

export { IdentitySection }
