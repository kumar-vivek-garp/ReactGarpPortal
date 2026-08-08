/** Auth route and Salesforce session endpoints (no custom session cookies). */
export const LOGIN_PATH = "/Login" as const

export const DEFAULT_POST_LOGIN_PATH = "/dashboard" as const

/** Query param for return URL after login (must be a relative path). */
export const AUTH_REDIRECT_PARAM = "startUrl" as const

/** Salesforce Experience Cloud logout — clears the platform session cookie. */
export const LOGOUT_URL = "/secur/logout.jsp" as const

export const AUTH_API = {
	LOGIN: "/services/apexrest/auth/login",
} as const
