import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { invalidateAccountCaches } from "@/api/account/invalidate-caches"
import { accountOptionsQueryOptions, accountQueryOptions } from "@/api/account/query-options"
import { saveAccountProfile, type AccountProfileValues } from "@/api/account/save-profile"
import type { AccountView, PicklistOption } from "@/api/account/types"
import { saveExamDemographics } from "@/api/registration/exam-registration"
import {
	examDemographicsQueryOptions,
	registrationOptionsQueryOptions,
} from "@/api/registration/query-options"

/**
 * Which backend the survey may talk to — decided by the CLIENT session, the
 * same way the rest of the registration panel decides where its links may
 * point. A guest must not touch the member portal's endpoints at all: the
 * guest profile has no access, and the failed calls read as a broken page.
 */
export type SurveyMode = "member" | "guest"

/** The options both modes are folded into, so the form has one shape. */
export type SurveyOptions = {
	picklists: Record<string, PicklistOption[]>
	workingYears: string[]
	graduationYears: string[]
	organizations: string[]
	schools: string[]
}

type SurveySource = {
	options: SurveyOptions | null
	/** The member's record, to seed from. Null for a guest. */
	account: AccountView | null
	isPending: boolean
	/** Nothing to write to: the reads failed, or a guest arrived with no key. */
	isUnavailable: boolean
}

/**
 * The survey's reads.
 *
 * Member: options and the current record from the member portal. Guest with a
 * key: the registration module's own picklists plus its company/school lists.
 * Guest without a key: nothing — there is no record to attach answers to.
 */
export function useRegistrationSurveySource(
	mode: SurveyMode,
	surveyKey: string | null,
): SurveySource {
	const isMember = mode === "member"
	const guestWithKey = !isMember && Boolean(surveyKey)

	const account = useQuery({ ...accountQueryOptions, enabled: isMember })
	const memberOptions = useQuery(accountOptionsQueryOptions(isMember))
	const demographics = useQuery({
		...examDemographicsQueryOptions,
		enabled: guestWithKey,
	})
	const lists = useQuery({
		...registrationOptionsQueryOptions,
		enabled: guestWithKey,
	})

	if (isMember) {
		if (account.isError || memberOptions.isError) {
			return { options: null, account: null, isPending: false, isUnavailable: true }
		}
		if (account.isPending || memberOptions.isPending) {
			return { options: null, account: null, isPending: true, isUnavailable: false }
		}
		return {
			options: {
				picklists: memberOptions.data.picklists ?? {},
				workingYears: memberOptions.data.workingYears ?? [],
				graduationYears: memberOptions.data.graduationYears ?? [],
				organizations: memberOptions.data.organizations ?? [],
				schools: memberOptions.data.schools ?? [],
			},
			account: account.data,
			isPending: false,
			isUnavailable: false,
		}
	}

	if (!guestWithKey) {
		return { options: null, account: null, isPending: false, isUnavailable: true }
	}
	if (demographics.isError) {
		return { options: null, account: null, isPending: false, isUnavailable: true }
	}
	// The company/school lists are hints only — their failure leaves the
	// inputs plain, exactly as the OSTA card does, rather than killing the form.
	if (demographics.isPending || lists.isPending) {
		return { options: null, account: null, isPending: true, isUnavailable: false }
	}
	return {
		options: {
			// Defensive against a thin payload: an empty list is a plain input,
			// never a crash on the confirmation screen.
			picklists: demographics.data.picklists ?? {},
			workingYears: demographics.data.workingYears ?? [],
			graduationYears: demographics.data.graduationYears ?? [],
			organizations: lists.data?.companies ?? [],
			schools: lists.data?.schools ?? [],
		},
		account: null,
		isPending: false,
		isUnavailable: false,
	}
}

/**
 * The survey's save. Silent: the form shows a failure inline and stays, so
 * the candidate can try again or skip — the standard mutation toast would
 * say the same thing twice.
 *
 * Member → the member-portal profile, then the account caches are refreshed
 * so My Account shows the answers. Guest → `POST examreg/demographics` with
 * the registration's own id as the key; the server resolves the contact from
 * that record, never from the browser.
 */
export function useRegistrationSurveySave(
	mode: SurveyMode,
	surveyKey: string | null,
) {
	const queryClient = useQueryClient()
	return useMutation<void, unknown, AccountProfileValues>({
		mutationFn: async (values) => {
			if (mode === "member") {
				await saveAccountProfile(values)
				await invalidateAccountCaches(queryClient)
				return
			}
			if (!surveyKey) throw new Error("No registration to attach the survey to.")
			await saveExamDemographics({ key: surveyKey, values })
		},
		meta: { silent: true },
	})
}
