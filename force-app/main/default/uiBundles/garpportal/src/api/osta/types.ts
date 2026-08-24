import type { MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring `GARP_Portal_OstaService` — the government-ID details a
 * candidate sitting at an OSTA (On-Site Test Administration) centre in China
 * must supply before they can be scheduled.
 *
 * Unrelated to the OSTA *address* on the CV, which travels with `cvAddress`
 * and posts the certificate. Same acronym, different feature.
 */
export type OstaIdInfo = {
	idType: string | null
	idLocation: string | null
	/**
	 * On READ this is the **last five characters only** — the org keeps the
	 * whole number in `OSTA_Full_ID__c` for the test centre and only the tail
	 * in `ID_Number__c`, and the read returns the tail. The full number never
	 * leaves the org through this API.
	 *
	 * On WRITE it must be the **whole** number: Apex stores what it is sent as
	 * the full ID and derives the tail with `.right(5)`. Echoing the masked
	 * value back would overwrite a real ID with five characters.
	 */
	idNumber: string | null
	/** `MM/dd/yyyy` — not ISO. Apex parses it with `Date.parse`. */
	idExpireDate: string | null
	/**
	 * Always `false` on read, even for a member who has already consented —
	 * `OSTA_Consent__c` holds a timestamp but the read hard-codes false. The
	 * box therefore starts empty every visit, which is defensible for a
	 * consent tick and is what the legacy does.
	 */
	ostaConsent: boolean
}

/** `GET osta`. */
export type OstaView = {
	statusMessage: string | null
	statusCode: number
	ostaIdInfo: OstaIdInfo | null
}

/** `POST osta`. All five are required — Apex refuses with 501 otherwise. */
export type OstaIdInput = {
	idType: string
	idLocation: string
	/** The whole number, never the masked tail. */
	idNumber: string
	/** `MM/dd/yyyy`. */
	idExpireDate: string
	/** Must be `true`; Apex tests `!= true` and refuses. */
	ostaConsent: boolean
}

export type OstaResult = {
	statusMessage: string | null
	statusCode: number
}

export type { MemberPortalEnvelope }
