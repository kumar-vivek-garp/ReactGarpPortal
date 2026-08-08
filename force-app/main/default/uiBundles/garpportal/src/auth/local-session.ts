/**
 * Local Vite uses the Salesforce CLI/org proxy for GraphQL, so `/secur/logout.jsp`
 * on localhost cannot clear that session. This flag lets Sign Out behave correctly
 * in local preview until a real Experience-hosted session is used.
 */
const LOCAL_LOGOUT_FLAG = "garpportal:local-logged-out"

export function isLocallyLoggedOut(): boolean {
	try {
		return sessionStorage.getItem(LOCAL_LOGOUT_FLAG) === "1"
	} catch {
		return false
	}
}

export function markLocallyLoggedOut(): void {
	try {
		sessionStorage.setItem(LOCAL_LOGOUT_FLAG, "1")
	} catch {
		/* ignore quota / private mode */
	}
}

export function clearLocalLogoutFlag(): void {
	try {
		sessionStorage.removeItem(LOCAL_LOGOUT_FLAG)
	} catch {
		/* ignore */
	}
}
