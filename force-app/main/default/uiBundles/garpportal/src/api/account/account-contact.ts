import { createDataSDK, gql } from "@salesforce/platform-sdk"

import type { AccountContact } from "@/api/account/account-contact-types"
import { AppError } from "@/api/client"

type StringField = { value?: string | null } | null | undefined
type BooleanField = { value?: boolean | null } | null | undefined
type DateField = { value?: string | null } | null | undefined

type AccountContactNode = {
	Id?: string
	FirstName?: StringField
	LastName?: StringField
	Name?: StringField
	Email?: StringField
	Phone?: StringField
	Photo_URL__c?: StringField
	GARP_Member_ID__c?: StringField
	GARP_ID__c?: StringField
	Membership_Type__c?: StringField
	MPS_Membership_Status__c?: StringField
	KPI_Membership_Expiration_Date__c?: DateField
	Membership_Caluclated_Expiration_Date__c?: DateField
	MPS_Membership_Expire_Date__c?: DateField
	KPI_Membership_Since__c?: DateField
	MPS_Membership_Autorenew_On__c?: BooleanField
	Company__c?: StringField
	Corporate_Title__c?: StringField
	Job_Function__c?: StringField
	Company_City__c?: StringField
	Company_Country__c?: StringField
	Industry_Working_Year__c?: StringField
	Highest_Degree__c?: StringField
	School_Name__c?: StringField
	Degree_Program_Name__c?: StringField
	Currently_in_School__c?: BooleanField
	Risk_Specialty__c?: StringField
	Topics_or_Expertise__c?: StringField
	GARP_Directory_Opt_In__c?: BooleanField
	GARP_Directory_Connect_Feature__c?: BooleanField
	GARP_Dir_Privacy_Job_Information__c?: BooleanField
	GARP_Dir_Privacy_Prof_Background__c?: BooleanField
	GARP_Dir_Privacy_Additional_Detail__c?: BooleanField
	KPI_Primary_Chapter_Name__c?: StringField
	KPI_Secondary_Chapter_Name__c?: StringField
	MailingStreet?: StringField
	MailingCity?: StringField
	MailingState?: StringField
	MailingPostalCode?: StringField
	MailingCountry?: StringField
	OtherStreet?: StringField
	OtherCity?: StringField
	OtherState?: StringField
	OtherPostalCode?: StringField
	OtherCountry?: StringField
	Account?: {
		Id?: string
		BillingStreet?: StringField
		BillingCity?: StringField
		BillingState?: StringField
		BillingPostalCode?: StringField
		BillingCountry?: StringField
	} | null
}

type AccountContactQueryResult = {
	uiapi?: {
		query?: {
			Contact?: {
				edges?: Array<{ node?: AccountContactNode | null } | null> | null
			} | null
		} | null
	} | null
}

const ACCOUNT_CONTACT_QUERY = gql`
	query AccountContact($contactId: ID!, $first: Int!) {
		uiapi {
			query {
				Contact(where: { Id: { eq: $contactId } }, first: $first) {
					edges {
						node {
							Id
							FirstName @optional {
								value
							}
							LastName @optional {
								value
							}
							Name @optional {
								value
							}
							Email @optional {
								value
							}
							Phone @optional {
								value
							}
							Photo_URL__c @optional {
								value
							}
							GARP_Member_ID__c @optional {
								value
							}
							GARP_ID__c @optional {
								value
							}
							Membership_Type__c @optional {
								value
							}
							MPS_Membership_Status__c @optional {
								value
							}
							KPI_Membership_Expiration_Date__c @optional {
								value
							}
							Membership_Caluclated_Expiration_Date__c @optional {
								value
							}
							MPS_Membership_Expire_Date__c @optional {
								value
							}
							KPI_Membership_Since__c @optional {
								value
							}
							MPS_Membership_Autorenew_On__c @optional {
								value
							}
							Company__c @optional {
								value
							}
							Corporate_Title__c @optional {
								value
							}
							Job_Function__c @optional {
								value
							}
							Company_City__c @optional {
								value
							}
							Company_Country__c @optional {
								value
							}
							Industry_Working_Year__c @optional {
								value
							}
							Highest_Degree__c @optional {
								value
							}
							School_Name__c @optional {
								value
							}
							Degree_Program_Name__c @optional {
								value
							}
							Currently_in_School__c @optional {
								value
							}
							Risk_Specialty__c @optional {
								value
							}
							Topics_or_Expertise__c @optional {
								value
							}
							GARP_Directory_Opt_In__c @optional {
								value
							}
							GARP_Directory_Connect_Feature__c @optional {
								value
							}
							GARP_Dir_Privacy_Job_Information__c @optional {
								value
							}
							GARP_Dir_Privacy_Prof_Background__c @optional {
								value
							}
							GARP_Dir_Privacy_Additional_Detail__c @optional {
								value
							}
							KPI_Primary_Chapter_Name__c @optional {
								value
							}
							KPI_Secondary_Chapter_Name__c @optional {
								value
							}
							MailingStreet @optional {
								value
							}
							MailingCity @optional {
								value
							}
							MailingState @optional {
								value
							}
							MailingPostalCode @optional {
								value
							}
							MailingCountry @optional {
								value
							}
							OtherStreet @optional {
								value
							}
							OtherCity @optional {
								value
							}
							OtherState @optional {
								value
							}
							OtherPostalCode @optional {
								value
							}
							OtherCountry @optional {
								value
							}
							Account @optional {
								Id
								BillingStreet @optional {
									value
								}
								BillingCity @optional {
									value
								}
								BillingState @optional {
									value
								}
								BillingPostalCode @optional {
									value
								}
								BillingCountry @optional {
									value
								}
							}
						}
					}
					pageInfo {
						hasNextPage
						endCursor
					}
				}
			}
		}
	}
`

function trimOrNull(value: string | null | undefined): string | null {
	const trimmed = value?.trim()
	return trimmed ? trimmed : null
}

function firstDate(
	...values: Array<string | null | undefined>
): string | null {
	for (const value of values) {
		const trimmed = trimOrNull(value)
		if (trimmed) return trimmed
	}
	return null
}

/**
 * Loads Contact account-information fields via GraphQL.
 * Completeness stays on REST `GET /memberportal/account`.
 */
export async function fetchAccountContact(
	contactId: string,
): Promise<AccountContact> {
	const trimmedId = contactId.trim()
	if (!trimmedId) {
		throw new AppError({ messages: ["Contact Id is required."] })
	}

	const sdk = await createDataSDK()
	// React Query owns freshness; SDK OneStore defaults to a 300s TTL which
	// would otherwise serve stale Contact data after personal-info mutations.
	const result = await sdk.graphql?.query<
		AccountContactQueryResult,
		{ contactId: string; first: number }
	>({
		query: ACCOUNT_CONTACT_QUERY,
		variables: { contactId: trimmedId, first: 1 },
		cacheControl: "no-cache",
	})

	if (result?.errors?.length) {
		throw new AppError({
			messages: result.errors.map((error) => error.message),
		})
	}

	const node = result?.data?.uiapi?.query?.Contact?.edges?.[0]?.node
	if (!node?.Id) {
		throw new AppError({ messages: ["Unable to load account contact."] })
	}

	const garpMemberId = trimOrNull(node.GARP_Member_ID__c?.value)
	const garpLegacyId = trimOrNull(node.GARP_ID__c?.value)

	return {
		contactId: node.Id,
		firstName: trimOrNull(node.FirstName?.value),
		lastName: trimOrNull(node.LastName?.value),
		fullName: trimOrNull(node.Name?.value),
		email: trimOrNull(node.Email?.value),
		garpId: garpMemberId ?? garpLegacyId,
		photoUrl: trimOrNull(node.Photo_URL__c?.value),
		phone: trimOrNull(node.Phone?.value),
		membershipType: trimOrNull(node.Membership_Type__c?.value),
		membershipStatus: trimOrNull(node.MPS_Membership_Status__c?.value),
		membershipExpiration: firstDate(
			node.KPI_Membership_Expiration_Date__c?.value,
			node.Membership_Caluclated_Expiration_Date__c?.value,
			node.MPS_Membership_Expire_Date__c?.value,
		),
		memberSince: trimOrNull(node.KPI_Membership_Since__c?.value),
		autoRenew: node.MPS_Membership_Autorenew_On__c?.value === true,
		career: {
			currentlyWorkingStatus: null,
			company: trimOrNull(node.Company__c?.value),
			corporateTitle: trimOrNull(node.Corporate_Title__c?.value),
			jobFunction: trimOrNull(node.Job_Function__c?.value),
			areaOfConcentration: null,
			companyCity: trimOrNull(node.Company_City__c?.value),
			companyCountry: trimOrNull(node.Company_Country__c?.value),
			industryWorkingYear: trimOrNull(node.Industry_Working_Year__c?.value),
			riskManagementWorkingYear: null,
		},
		academic: {
			highestDegree: trimOrNull(node.Highest_Degree__c?.value),
			schoolName: trimOrNull(node.School_Name__c?.value),
			degreeProgramName: trimOrNull(node.Degree_Program_Name__c?.value),
			currentlyInSchool:
				typeof node.Currently_in_School__c?.value === "boolean"
					? node.Currently_in_School__c.value
					: null,
			expectedGraduationDate: null,
			expectedGraduationMonth: null,
		},
		expertise: {
			riskSpecialty: trimOrNull(node.Risk_Specialty__c?.value),
			topicsOrExpertise: trimOrNull(node.Topics_or_Expertise__c?.value),
		},
		directory: {
			optedIn:
				typeof node.GARP_Directory_Opt_In__c?.value === "boolean"
					? node.GARP_Directory_Opt_In__c.value
					: null,
			connectFeature:
				typeof node.GARP_Directory_Connect_Feature__c?.value === "boolean"
					? node.GARP_Directory_Connect_Feature__c.value
					: null,
			showJobInformation:
				typeof node.GARP_Dir_Privacy_Job_Information__c?.value === "boolean"
					? node.GARP_Dir_Privacy_Job_Information__c.value
					: null,
			showProfessionalBackground:
				typeof node.GARP_Dir_Privacy_Prof_Background__c?.value === "boolean"
					? node.GARP_Dir_Privacy_Prof_Background__c.value
					: null,
			showAdditionalDetail:
				typeof node.GARP_Dir_Privacy_Additional_Detail__c?.value === "boolean"
					? node.GARP_Dir_Privacy_Additional_Detail__c.value
					: null,
		},
		chapters: {
			primary: trimOrNull(node.KPI_Primary_Chapter_Name__c?.value),
			secondary: trimOrNull(node.KPI_Secondary_Chapter_Name__c?.value),
		},
		mailing: {
			street: trimOrNull(node.MailingStreet?.value),
			city: trimOrNull(node.MailingCity?.value),
			state: trimOrNull(node.MailingState?.value),
			postalCode: trimOrNull(node.MailingPostalCode?.value),
			country: trimOrNull(node.MailingCountry?.value),
		},
		billing: {
			street: trimOrNull(node.Account?.BillingStreet?.value),
			city: trimOrNull(node.Account?.BillingCity?.value),
			state: trimOrNull(node.Account?.BillingState?.value),
			postalCode: trimOrNull(node.Account?.BillingPostalCode?.value),
			country: trimOrNull(node.Account?.BillingCountry?.value),
		},
		other: {
			street: trimOrNull(node.OtherStreet?.value),
			city: trimOrNull(node.OtherCity?.value),
			state: trimOrNull(node.OtherState?.value),
			postalCode: trimOrNull(node.OtherPostalCode?.value),
			country: trimOrNull(node.OtherCountry?.value),
		},
	}
}
