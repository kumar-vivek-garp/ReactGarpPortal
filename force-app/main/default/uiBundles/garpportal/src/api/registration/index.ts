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
	fetchExamDemographics,
	fetchExamPaymentStatus,
	fetchExamRegistration,
	fetchExamResume,
	fetchRegistrationOptions,
	payExamOrder,
	registerExam,
	rollbackExamRegistration,
	saveExamDemographics,
	startExamCheckout,
	verifyExamAddress,
	verifyExamCustomer,
} from "@/api/registration/exam-registration"
export {
	examDemographicsQueryOptions,
	examFeesQueryOptions,
	examRegistrationQueryOptions,
	examResumeQueryOptions,
} from "@/api/registration/query-options"
export type {
	AddressCheckResult,
	AddressInput,
	CheckoutResult,
	ConsentInput,
	CustomerInput,
	DemographicsOptions,
	DemographicsSaveRequest,
	DemographicsSaveResult,
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
	ResumeResult,
	SelectionInput,
	StagedRegistrationStatus,
	StudyMaterialView,
} from "@/api/registration/exam-types"
