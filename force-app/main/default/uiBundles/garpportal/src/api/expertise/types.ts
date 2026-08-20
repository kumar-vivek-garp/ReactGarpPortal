import type { PicklistOption } from "@/api/account/types"

export const EXPERTISE_FIELDS = [
	"Self_Identification_Topic_Tags__c",
	"Publishing_Experience__c",
	"Teaching_Experience__c",
	"Expert_Participation__c",
] as const

export type ExpertiseField = (typeof EXPERTISE_FIELDS)[number]

/** `GET /memberportal/expertise` (`GARP_Portal_ExpertiseService.ExpertiseView`). */
export type ExpertiseView = {
	statusMessage: string | null
	statusCode: number
	values: Record<string, string | null>
	options: Record<string, PicklistOption[]>
	labels: Record<string, string>
}

export type ExpertiseResult = {
	statusMessage: string | null
	statusCode: number
}

export type ExpertiseValues = Record<string, string | null>
