export { DashboardPending } from "./dashboard-pending"
export {
	StudyMaterialsContentSkeleton,
	StudyMaterialsPending,
	StudyMaterialsPendingShell,
} from "./study-materials-pending"
export {
	ProgramsContentSkeleton,
	ProgramsPending,
	ProgramsPendingShell,
} from "./programs-pending"
export {
	EventsContentSkeleton,
	EventsPending,
	EventsPendingShell,
} from "./events-pending"
export {
	MembershipBenefitsSkeleton,
	MembershipDirectorySkeleton,
	MembershipPending,
	MembershipPendingShell,
} from "./membership-pending"
export { MyAccountPending } from "./my-account-pending"
export { OrderHistorySkeleton } from "./order-history-skeleton"
export {
	OrderDetailPending,
	OrderDetailSkeleton,
} from "./order-detail-pending"
export {
	ProgramDetailPending,
	ProgramDetailSkeleton,
} from "./program-detail-pending"
export {
	ExamResultsPending,
	ExamResultsPendingSkeleton,
} from "./exam-results-pending"
export {
	CpdActivitiesContentSkeleton,
	CpdActivitiesPending,
	CpdActivitiesPendingShell,
} from "./cpd-activities-pending"
export {
	CpdContentSkeleton,
	CpdPending,
	CpdPendingShell,
} from "./cpd-pending"
export {
	WorkExperienceContentSkeleton,
	WorkExperiencePending,
	WorkExperiencePendingShell,
} from "./work-experience-pending"
export {
	HelpCenterPending,
	HelpCenterPendingShell,
} from "./help-center-pending"
export {
	ExamSetupContentSkeleton,
	ExamSetupPending,
	ExamSetupPendingShell,
} from "./exam-setup-pending"

/**
 * Delay before swapping to the page skeleton on in-app nav.
 * Keep above typical warm chunk+cache resolve so cached visits don’t flash shimmer;
 * still covers slow 3G chunk waits.
 */
export const PAGE_PENDING_MS = 250

/** Don’t force the skeleton to linger once the real page is ready. */
export const PAGE_PENDING_MIN_MS = 0
