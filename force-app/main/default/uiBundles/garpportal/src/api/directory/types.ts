/** One row of the Member Directory, read from Contact over GraphQL. */
export type DirectoryMember = {
	id: string
	name: string | null
	company: string | null
	country: string | null
	corporateTitle: string | null
	jobFunction: string | null
}
