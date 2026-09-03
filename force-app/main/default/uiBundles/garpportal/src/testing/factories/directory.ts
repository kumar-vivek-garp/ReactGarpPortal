import type {
	DirectoryMember,
	DirectorySearchResults,
	DirectoryView,
} from "@/api/directory"

/** A member in good standing with full directory + advanced-search access. */
export function directoryView(
	overrides: Partial<DirectoryView> = {},
): DirectoryView {
	return {
		statusMessage: null,
		statusCode: 200,
		settings: null,
		preview: null,
		hasDirectoryAccess: true,
		hasDirectoryCPDAccess: false,
		hasDirectoryConnectAccess: true,
		hasDirectoryAdvancedSearchAccess: true,
		hasDirectoryNonCertifiedAccess: false,
		hasDirectorySettingsAccess: true,
		upsellMembershipType: null,
		pendingMembershipOrderId: null,
		...overrides,
	}
}

/** One directory row, already redacted — nullable fields default to null. */
export function directoryMember(
	overrides: Partial<DirectoryMember> = {},
): DirectoryMember {
	return {
		id: "003-1",
		garpId: "G-1",
		name: "Ada Lovelace",
		firstName: "Ada",
		lastName: "Lovelace",
		mailingCity: "London",
		mailingCountry: "United Kingdom",
		photoUrl: null,
		membershipType: "Individual",
		membershipSince: "2019-01-01",
		isFRMCertified: true,
		frmCertifiedDate: null,
		isERPCertified: false,
		erpCertifiedDate: null,
		isSCRHolder: false,
		scrCompletionDate: null,
		isRAIHolder: false,
		raiCompletionDate: null,
		cpeRequirementStatus: null,
		cpeCurrentCycle: null,
		cpeLastCompletedCycle: null,
		jobFunction: null,
		riskSpecialty: null,
		areaOfConcentration: null,
		corporateTitle: "Head of Risk",
		company: "Analytical Engines",
		designations: null,
		otherQualifications: null,
		canSendMessage: true,
		canInvite: false,
		...overrides,
	}
}

/** One result page; `total` follows the member count unless overridden. */
export function directorySearchResults(
	overrides: Partial<DirectorySearchResults> = {},
): DirectorySearchResults {
	const members = overrides.members ?? [directoryMember()]
	return {
		statusMessage: null,
		statusCode: 200,
		pages: 1,
		total: members.length,
		pageCurrent: 1,
		pageSize: 10,
		...overrides,
		members,
	}
}
