import type { AccountView, PortalAddress } from "@/api/account/types"
import { splitStreet, str } from "@/api/personal-info/address-utils"
import type {
	AddressFormFields,
	PersonalInfoEditData,
} from "@/api/personal-info/types"

/**
 * Address lines for the form. Apex already splits the street into three
 * lines; the fallback covers a payload that carries only the joined value.
 */
function toAddressFields(
	address: PortalAddress,
	company: string | null | undefined,
	phone: string | null | undefined,
): AddressFormFields {
	const [line1, line2, line3] =
		address.street1 == null && address.street2 == null && address.street3 == null
			? splitStreet(address.street)
			: [str(address.street1), str(address.street2), str(address.street3)]
	return {
		company: str(company),
		address1: line1,
		address2: line2,
		address3: line3,
		country: str(address.country),
		city: str(address.city),
		state: str(address.state),
		postalCode: str(address.postalCode),
		phone: str(phone),
	}
}

/**
 * Shapes the composed account view into what the Personal Information dialog
 * edits. Pure and total: it runs as a React Query `select`, so it must never
 * throw. `billingCompany` comes from its own read because the account
 * payload does not carry it (and the address save writes it back verbatim).
 */
export function toPersonalInfoEditData(
	view: AccountView,
	billingCompany: string | null,
): PersonalInfoEditData {
	const { personal } = view
	return {
		contactId: view.identity.contactId,
		photoUrl: personal.photoUrl?.trim() || null,
		firstName: str(personal.firstName),
		lastName: str(personal.lastName),
		email: str(personal.email),
		mobilePhoneCode: str(personal.mobilePhoneCode),
		mobilePhone: str(personal.mobilePhone),
		// Contact.Phone is the billing phone; HomePhone the mailing one — the
		// same pairing the address save writes.
		billing: toAddressFields(view.billingAddress, billingCompany, personal.phone),
		mailing: toAddressFields(
			view.mailingAddress,
			personal.mailingCompany,
			personal.homePhone,
		),
		sameAsBilling: view.isBillingAndMailingAddressSame === true,
	}
}
