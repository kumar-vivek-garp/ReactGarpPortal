import { createDataSDK, gql } from "@salesforce/platform-sdk"

import { AppError } from "@/api/client"
import { copyAddress, joinStreet } from "@/api/personal-info/address-utils"
import type { PersonalInfoSaveInput } from "@/api/personal-info/types"

type SavePersonalInfoResult = {
	uiapi?: {
		AccountUpdate?: { success?: boolean | null } | null
		ContactUpdate?: { success?: boolean | null } | null
	} | null
}

const SAVE_PERSONAL_INFO_MUTATION = gql`
	mutation SavePersonalInfo(
		$accountId: IdOrRef!
		$contactId: IdOrRef!
		$billingCompany: String
		$billingStreet: TextArea
		$billingCity: String
		$billingState: String
		$billingPostalCode: String
		$billingCountry: String
		$billingPhone: PhoneNumber
		$firstName: String
		$lastName: String
		$email: Email
		$mobilePhoneCode: String
		$mobilePhone: PhoneNumber
		$mailingCompany: String
		$mailingStreet: TextArea
		$mailingCity: String
		$mailingState: String
		$mailingPostalCode: String
		$mailingCountry: String
		$homePhone: PhoneNumber
	) {
		uiapi(input: { allOrNone: true }) {
			AccountUpdate(
				input: {
					Id: $accountId
					Account: {
						Billing_Address_Company__c: $billingCompany
						BillingStreet: $billingStreet
						BillingCity: $billingCity
						BillingState: $billingState
						BillingPostalCode: $billingPostalCode
						BillingCountry: $billingCountry
						Phone: $billingPhone
					}
				}
			) {
				success
			}
			ContactUpdate(
				input: {
					Id: $contactId
					Contact: {
						FirstName: $firstName
						LastName: $lastName
						Email: $email
						Mobile_Phone_Code__c: $mobilePhoneCode
						MobilePhone: $mobilePhone
						Mailing_Address_Company__c: $mailingCompany
						MailingStreet: $mailingStreet
						MailingCity: $mailingCity
						MailingState: $mailingState
						MailingPostalCode: $mailingPostalCode
						MailingCountry: $mailingCountry
						HomePhone: $homePhone
					}
				}
			) {
				success
			}
		}
	}
`

/**
 * Saves personal + billing + mailing fields via GraphQL AccountUpdate + ContactUpdate.
 */
export async function savePersonalInfo(input: PersonalInfoSaveInput): Promise<void> {
	if (!input.contactId.trim()) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}
	if (!input.accountId.trim()) {
		throw new AppError({
			messages: ["Account Id is required to update billing address."],
		})
	}

	const mailing = input.sameAsBilling
		? copyAddress(input.billing)
		: input.mailing

	const sdk = await createDataSDK()
	const result = await sdk.graphql?.mutate<
		SavePersonalInfoResult,
		Record<string, string | null>
	>({
		mutation: SAVE_PERSONAL_INFO_MUTATION,
		variables: {
			accountId: input.accountId,
			contactId: input.contactId,
			billingCompany: input.billing.company.trim() || null,
			billingStreet:
				joinStreet(
					input.billing.address1,
					input.billing.address2,
					input.billing.address3,
				) || null,
			billingCity: input.billing.city.trim() || null,
			billingState: input.billing.state.trim() || null,
			billingPostalCode: input.billing.postalCode.trim() || null,
			billingCountry: input.billing.country.trim() || null,
			billingPhone: input.billing.phone.trim() || null,
			firstName: input.firstName.trim() || null,
			lastName: input.lastName.trim() || null,
			email: input.email.trim() || null,
			mobilePhoneCode: input.mobilePhoneCode.trim() || null,
			mobilePhone: input.mobilePhone.trim() || null,
			mailingCompany: mailing.company.trim() || null,
			mailingStreet:
				joinStreet(mailing.address1, mailing.address2, mailing.address3) || null,
			mailingCity: mailing.city.trim() || null,
			mailingState: mailing.state.trim() || null,
			mailingPostalCode: mailing.postalCode.trim() || null,
			mailingCountry: mailing.country.trim() || null,
			homePhone: mailing.phone.trim() || null,
		},
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}
}
