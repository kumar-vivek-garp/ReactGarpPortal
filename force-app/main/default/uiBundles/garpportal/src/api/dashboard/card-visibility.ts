import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	assertMemberPortalEnvelopeOk,
	normalizeHttpResponse,
	unwrapApiResult,
} from "@/api/client"
import type {
	CardVisibilityResult,
	MemberPortalEnvelope,
} from "@/api/dashboard/types"

/**
 * Hiding and un-hiding a dashboard card.
 *
 * Both actions are the same Apex method with a flag
 * (`GARP_Portal_DismissCardService.setMuted`), so they are one function here
 * too. Dismissing is a **60-day snooze**, not a delete — the card returns on
 * day 61 — which is why the restore half has to exist at all: without it a
 * member who hit the × by accident waits two months.
 *
 * Apex refuses any key outside `GARP_Portal_Core.DISMISSIBLE_CARDS` rather than
 * silently accepting it, so a card never shows as hidden when the next load
 * would bring it straight back.
 */
const CARD_ACTION = {
	dismiss: {
		path: "/services/apexrest/memberportal/dismissCard",
		verb: "dismiss",
	},
	restore: {
		path: "/services/apexrest/memberportal/restoreCard",
		verb: "restore",
	},
} as const

type CardAction = keyof typeof CARD_ACTION

async function setCardVisibility(
	action: CardAction,
	key: string,
): Promise<CardVisibilityResult> {
	const { path, verb } = CARD_ACTION[action]
	const trimmed = key.trim()
	if (!trimmed) {
		throw new AppError({ messages: ["A card key is required."] })
	}

	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			Accept: "application/json",
		},
		body: JSON.stringify({ key: trimmed }),
	})

	const result = await normalizeHttpResponse<
		MemberPortalEnvelope<CardVisibilityResult>
	>(response, {
		unreachableMessage: "Unable to reach the dashboard service.",
		fallbackErrorMessage: `Unable to ${verb} this card. Please try again.`,
	})

	const envelope = unwrapApiResult(result)

	assertMemberPortalEnvelopeOk(envelope, {
		fallbackErrorMessage: `Unable to ${verb} this card.`,
		status: result.status,
	})

	return envelope.data ?? { [verb === "dismiss" ? "dismissed" : "restored"]: trimmed }
}

/** Snoozes a dismissible dashboard card for 60 days. */
export function dismissCard(key: string): Promise<CardVisibilityResult> {
	return setCardVisibility("dismiss", key)
}

/** Clears the snooze, bringing the card back on the next dashboard fetch. */
export function restoreCard(key: string): Promise<CardVisibilityResult> {
	return setCardVisibility("restore", key)
}
