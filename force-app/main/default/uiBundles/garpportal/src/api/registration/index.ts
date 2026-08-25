export {
	AFFILIATE_PROGRAM_TYPE,
	completeAffiliateOrder,
	fetchAffiliateRegistration,
	registerAffiliate,
	verifyAffiliateCustomer,
} from "@/api/registration/affiliate"
export {
	affiliateRegistrationQueryOptions,
	registrationQueryKeys,
} from "@/api/registration/query-options"
export type {
	AffiliateProgramView,
	AffiliateRegisterRequest,
	AffiliateRegistrationLoad,
	RegisterResult,
	RegistrationContact,
	RegistrationCountry,
	VerifyCustomerRequest,
	VerifyCustomerResult,
} from "@/api/registration/types"

/* ===================== exam registration ===================== */

export {
	EXAMREG_BASE,
	EXAMREG_UNREACHABLE,
	examregFetch,
} from "@/api/registration/examreg-fetch"
export {
	calculateFees,
	fetchExamPaymentStatus,
	fetchExamRegistration,
	fetchRegistrationOptions,
	payExamOrder,
	registerExam,
	rollbackExamRegistration,
	startExamCheckout,
	verifyExamAddress,
	verifyExamCustomer,
} from "@/api/registration/exam-registration"
export {
	examFeesQueryOptions,
	examRegistrationQueryOptions,
} from "@/api/registration/query-options"
export type {
	AddressCheckResult,
	AddressInput,
	CheckoutResult,
	ConsentInput,
	CustomerInput,
	ExamAdminView,
	ExamPartView,
	ExamProgramView,
	ExamRegisterRequest,
	ExamRegisterResult,
	ExamRegistrationLoad,
	ExamSelectionView,
	ExamSiteView,
	ExamVerifyCustomerRequest,
	FeeLine,
	FeesRequest,
	FeesResult,
	PartChoice,
	PaymentStatusResult,
	PersonalInput,
	ProgramKind,
	RegistrationOptions,
	RegistrationTracking,
	SelectionInput,
	StudyMaterialView,
} from "@/api/registration/exam-types"
