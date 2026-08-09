import type { Identity, MemberPortalEnvelope } from "@/api/account/types"

/**
 * Types mirroring GARP_MemberPortal_Service MembershipView DTOs.
 */

export type PortalCard = {
	key: string
	page: string
	provider: string | null
	rank: number
	title: string | null
	body: string | null
	ctaLabel: string | null
	ctaUrl: string | null
	ctaIsExternal: boolean
	imageUrl: string | null
	eyebrow: string | null
	badge: string | null
	locked: boolean
	dismissible: boolean
	bullets: string[] | null
	meta: Record<string, unknown>
}

export type Benefit = {
	id: string
	title: string | null
	section: string | null
	sortOrder: number
	paragraphs: string[]
	bullets: string[]
	imageUrl: string | null
	ctaLabel: string | null
	ctaUrl: string | null
	ctaIsExternal: boolean
	opensInNewWindow: boolean
	promoCode: string | null
	locked: boolean
	membershipRequired: boolean
}

export type BenefitSection = {
	name: string
	benefits: Benefit[]
}

export type MembershipView = {
	identity: Identity
	hero: PortalCard | null
	sections: BenefitSection[]
	lockedCount: number
}

export type { MemberPortalEnvelope }
