import {
	BookUser,
	Briefcase,
	Lightbulb,
	MapPin,
	ShieldCheck,
	UserRound,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"

/**
 * One record per Account Information card — the my-account analogue of
 * `PROGRAM_BUCKET_META`. Card headers, DOM anchors and the completeness
 * jump-to all read from here so they cannot drift apart.
 */
export const ACCOUNT_SECTIONS = [
	"personal",
	"career",
	"membership",
	"chapters",
	"directory",
	"expertise",
] as const

export type AccountSection = (typeof ACCOUNT_SECTIONS)[number]

type AccountSectionMeta = {
	/** Scroll-jump anchor. */
	domId: string
	label: string
	icon: LucideIcon
	/** Long intro copy, lifted out of the card components. */
	blurb?: string
}

export const CHAPTERS_BLURB =
	"Stay on the cutting edge of risk management and make new connections by participating in your local chapter. As a member of the GARP community, you may attend our chapter meetings anywhere in the world and will always be welcome."

export const DIRECTORY_BLURB =
	"These settings allow you to adjust what is shown in your entry in the GARP Directory. The minimum amount of information required to be listed in the directory is contained in the Basic Information section below. Other categories allow you to share more information about your professional accomplishments and specialties. The Professional Background and Job Information categories will only be visible to fellow members."

export const EXPERTISE_BLURB =
	"Please complete the form below if you have experience as a Subject Matter Expert in one or more areas of financial risk management and would like to collaborate with GARP on delivering risk intelligence."

export const ACCOUNT_SECTION_META: Record<AccountSection, AccountSectionMeta> = {
	personal: {
		domId: "account-section-personal",
		label: "Personal Information",
		icon: UserRound,
	},
	career: {
		domId: "account-section-career",
		label: "Career Information",
		icon: Briefcase,
	},
	membership: {
		domId: "account-section-membership",
		label: "Membership",
		icon: ShieldCheck,
	},
	chapters: {
		domId: "account-section-chapters",
		label: "Preferred Chapters",
		icon: MapPin,
		blurb: CHAPTERS_BLURB,
	},
	directory: {
		domId: "account-section-directory",
		label: "Directory Settings",
		icon: BookUser,
		blurb: DIRECTORY_BLURB,
	},
	expertise: {
		domId: "account-section-expertise",
		label: "Expertise",
		icon: Lightbulb,
		blurb: EXPERTISE_BLURB,
	},
}

/**
 * Bento order. Also the single-column stack order below `xl`, so the most
 * important cards (identity, standing) come first on a phone and the
 * settings cards last.
 */
export const ACCOUNT_CARD_ORDER: readonly AccountSection[] = [
	"personal",
	"membership",
	"career",
	"chapters",
	"expertise",
	"directory",
]

/**
 * Column spans at `xl`. Auto-placement then yields three clean rows:
 * [personal personal][membership] / [career career][chapters] /
 * [expertise expertise][directory].
 *
 * Written out in full — Tailwind's scanner cannot see composed class names.
 */
export const ACCOUNT_CARD_SPAN: Record<AccountSection, string> = {
	personal: "xl:col-span-2",
	membership: "",
	career: "xl:col-span-2",
	chapters: "",
	expertise: "xl:col-span-2",
	directory: "",
}

/** Grid geometry — shared verbatim with the pending shell so they cannot drift. */
export const ACCOUNT_CARD_GRID = "grid items-start gap-6 xl:grid-cols-3"
