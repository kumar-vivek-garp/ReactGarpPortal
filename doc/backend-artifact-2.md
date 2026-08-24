
GarpAppv1 · 60 Apex classes · 55 routes · updated 22 Aug 2026

GarpAppv1 Apex Map
Every route the bundle answers, the class hierarchy behind each one, and the request chain from a cold URL through to the moment payment takes over. All of it is live in devjuly25a.

The dependency answer
Measured, not asserted: comments stripped from all 60 classes, then matched against GARP_BC_*, GARP_MS_*, GARP_EventReg_*, GARP_EventRegFast_*, garpAppRemoter, sfdcAppRemoter and the Stripe controllers. Prose like “a port of GARP_BC_Foo” does not count as a dependency.

No GARP_BC_* anywhere
Zero executable references across all 60 classes. The exam-setup wizard was the last holdout and was cut over on 22 Aug. The name survives only in provenance comments.

No LWC or Aura at all
No lwc/ directory, no aura/ directory, and not one @AuraEnabled method. Everything is reached over REST from React.

Two calls out, by design
Both are org infrastructure, not portal logic: one applies an approved exam modification, one pushes a registration to the exam provider. Re-implementing either would fork behaviour that staff tooling and triggers share.

Classes with REAL legacy references:

  (none)

Remaining calls into shared org infrastructure:

  GARP_Portal_ExamSetupService -> ExamManagementController.processExamRegMods
  GARP_Portal_ExamSetupService -> ExamRegistrationsStatusCls.updateRegistration
Why those two stay
ExamManagementController.processExamRegMods is what actually moves a candidate between sittings. It is also called from OpportunityHandler’s Opportunity trigger and from the Member Services tool, so a second copy would race the first on the same records.

ExamRegistrationsStatusCls.updateRegistration is the outbound integration to Pearson / PSI / ATA. Same standing as the Stripe webhook: shared plumbing the bundle calls rather than owns.

Routes and redirects
React Router v6, browser history, served from the site’s /GarpAppv1 base. Route ranking is global across the flattened tree, so a static segment always beats a dynamic one no matter where it sits.

Public registration
Path	Page	Serves
/registration/:programType	ExamRegistration	frm, scr, riskai (alias rai), raij, frr, frr25, ffr, mem, affiliate
/registration/:programType/:regCode	ExamRegistration	Same, with a B2B deal code or EPP affiliate code in the path
/registration/micro/:courseCode/:regCode	ExamRegistration	Micro courses â€” B2B only, so the code is not optional
/registration/event/:eventId	EventRegistration	The legacy shape, served directly
/registration/event/:eventId/:regCode	EventRegistration	Legacy accepted a team code here; nothing reads it yet
/registration/chaptermeeting/:eventId	EventRegistration	Variant fixed by the route â€” Chapter_Meeting__c
/registration/webcast/:eventId	EventRegistration	Variant fixed by the route â€” Webcast__c
/registration/event	EventRegistration	No id â€” the “choose an event” picker
Legacy URL compatibility
Both legacy generations put the record in the path and serve the form from there, so the path is canonical here too. These four render directly — no redirect, no address-bar rewrite in front of links that are already in invitations and marketing emails.

Older path	Behaviour
/event/registration/:eventId	Renders — the older sfdcApp router's shape
/event/registration/:eventId/public	Renders. The /public segment only chose a ui-router state; both states rendered the same component
/chaptermeeting/registration/:eventId	Renders, variant chaptermeeting
/webcast/registration/:eventId	Renders, variant webcast
Three genuine redirects remain, and they exist because the target moved rather than because the URL shape changed:

Path	Redirects to	Why
/event-registration?eventId=â€¦	/registration/event/:eventId	This page briefly took the query form. Kept so anything that captured it still resolves; &eventType= maps to the chaptermeeting or webcast segment
/order-details/:orderNumber	/purchase-history/:orderNumber	The legacy's own emails and “View Order” buttons point here
/member-resources	/membership	Merged into the membership page
Member portal — behind PortalAuthLayout → PrivateRoute → PortalShell
Path	Page	GET action → service
/dashboard	PortalDashboard	dashboard, ad, alertBar → DashboardService, AdService, AlertBarService
/my-account	PortalMyAccount	account, options, expertise → AccountService, OptionsService, ExpertiseService
/membership	PortalMembership	membership → MembershipService
/programs	PortalPrograms	programs → ProgramsService
/programs/:programType	PortalProgramDetail	programDetail → ProgramDetailService
/programs/exam-setup/:programType	PortalExamSetup	examSetup → ExamSetupService (static segment wins over :programType)
/courses/:courseType	PortalCourseDetail	courseDetail → CourseDetailService
/exam-results	PortalExamResults	examResults → ExamResultsService
/study-materials	PortalStudyMaterials	studyMaterials, myEBooks → StudyMaterialsService
/study-materials-type/:program	PortalStudyMaterials	same, filtered
/study-materials-archive	PortalStudyMaterialsArchive	same
/cpd	PortalCpd	cpd, cpdProgram → CpdService, CpdProgramService
/cpd-activities	PortalCpdActivities	cpdActivities, cpdActivityTypes → CpdActivityService
/cpd-activities-detail/:activityId	PortalCpdActivities	same, pre-selected
/member-directory	PortalMemberDirectory	directory → DirectoryService
/member-directory-search/:searchtext	PortalMemberDirectory	directorySearch (POST)
/events	PortalEvents	events → EventsService
/purchase-history	PortalPurchaseHistory	orders → OrdersService
/purchase-history/:orderNumber	PortalOrderDetail	orderDetail → OrdersService
/work-experience	PortalWorkExperience	cv, cvExperience, cvAttachments → CvService
/work-experience/manage/:programType	PortalWorkExperience	same, step = list
/work-experience/manage/addresses/:programType	PortalWorkExperience	same, step = addresses
/work-experience/manage/addresses/review/:programType	PortalWorkExperience	same, step = review
/errata/:programType	PortalErrata	errataForm → ErrataService
/identity	PortalOsta	osta → OstaService
/content	PortalGatedContent	gate only â€” no service call
/help-center	PortalHelpCenter	cases → CasesService
/registration/survey	PortalRegistrationSurvey	outside PortalShell â€” no chrome
/registration/information	PortalRegistrationSurvey	same
Authentication
Path	Page	Apex
/login	Login	UIBundleLogin
/register	Register	UIBundleRegistration
/forgot-password	ForgotPassword	UIBundleForgotPassword
/reset-password	ResetPassword	UIBundleForgotPassword
/change-password	ChangePassword	UIBundleChangePassword
/profile	Profile	guarded by PrivateRoute
Class hierarchy, from the API route down
Every class the bundle owns, arranged by what reaches it. Generated by stripping comments from all 59 classes and matching cross-references, so this is the real call graph, not a diagram of the intended one. Two REST resources and one set of auth endpoints are the only ways in.

router the @RestResource
service owns one action
selector all the SOQL
config metadata-driven registry
dto typed contract
shared reached by nearly everything
Calling these by hand: mind the base path
The Apex path is /services/apexrest/<resource>/<action>, but hitting <site>/GarpAppv1/services/apexrest/â€¦ does not reach it — the bundle's SPA catch-all answers first and returns the HTML shell with HTTP 200, which looks like a working endpoint returning nonsense.

Requests go through the bundle's API proxy, published to the page as SFDC_ENV.apiPath:

https://<site>/GarpAppv1/sf/api/services/apexrest/examreg/event/info?eventId=â€¦&eventType=event
                     â””â”€â”€ SFDC_ENV.apiPath â”€â”€â”˜
Registration — /services/apexrest/examreg/*
GARP_ExamReg_API router — routes the action, wraps the envelope
GETinfo →GARP_ExamReg_LoadService
GARP_ExamReg_TeamReg resolves the URL code: affiliate, then B2B seat
GARP_ExamReg_Config config
GARP_ExamReg_Selector selector
GARP_ExamReg_Stripe reads the useStripe flag only
GARP_ExamReg_Dto dto
GEToptions →GARP_ExamReg_Selector company / school typeaheads
GETwhoami →no service — a query-less guest check
POSTfees →GARP_ExamReg_PricingService
GARP_ExamReg_TeamReg B2B seat pricing and affiliate credits
GARP_ExamReg_LoadService programme + retake resolution
GARP_ExamReg_Selector
GARP_ExamReg_Config
POSTverifyCustomer · verifyAddress · register · payOrder · paymentStatus · rollback →GARP_ExamReg_RegService
GARP_ExamReg_PricingService re-prices before every write
GARP_ExamReg_LoadService eligibility recheck
GARP_ExamReg_Selector
GARP_ExamReg_Config
POSTcheckout →GARP_ExamReg_Stripe hosted Stripe Checkout Session
GARP_ExamReg_Selector
GETevent/info · event/options →GARP_ExamReg_EventLoad
GARP_ExamReg_EventSelector selector — the only place the three object families' fields live
GARP_ExamReg_EventDto dto
GARP_ExamReg_Selector shared countries and picklists
GARP_ExamReg_Config
GARP_ExamReg_Stripe
POSTevent/register · event/rsvpDecline →GARP_ExamReg_EventReg
GARP_ExamReg_EventLoad re-checks eligibility
GARP_ExamReg_EventSelector
GARP_ExamReg_EventDto
GARP_ExamReg_Config
GARP_ExamReg_Config and GARP_ExamReg_Selector reference each other — the config reads its programme records through the selector, and the selector asks the config which product codes to fetch. Everything else flows one way.

Member portal — /services/apexrest/memberportal/*
41 classes, one service per action. Five of them are reached by almost every service, so they are listed once at the bottom rather than repeated 30 times; the tree shows only the edges where one feature service calls another.

GARP_Portal_API router — 40 GET/POST actions, plus a batch that folds several GETs into one round trip
Identity and account
me → GARP_Portal_MeService
account → GARP_Portal_AccountService
GARP_Portal_MembershipService
addresses → GARP_Portal_AddressService
profile → GARP_Portal_ProfileService
options → GARP_Portal_OptionsService
expertise → GARP_Portal_ExpertiseService
osta → GARP_Portal_OstaService
memberPhoto · memberPhotoRemove → GARP_Portal_PhotoService
emailPreferenceUpdate → GARP_Portal_EmailPrefService
Dashboard and notices
dashboard → GARP_Portal_DashboardService
GARP_Portal_NotificationsService
GARP_Portal_ProgramsService
ad → GARP_Portal_AdService
GARP_Portal_ExamWindowService
GARP_Portal_ProgramDetailService
alertBar → GARP_Portal_AlertBarService
GARP_Portal_ExamResultsService
GARP_Portal_ExamWindowService
examNotifications · newNotification → GARP_Portal_NotificationsService
GARP_Portal_ProgramsService
dismissCard · restoreCard → GARP_Portal_DismissCardService
Programs and exams
programs → GARP_Portal_ProgramsService
programDetail → GARP_Portal_ProgramDetailService
GARP_Portal_ProgramsService
GARP_Portal_NotificationsService
courseDetail → GARP_Portal_CourseDetailService
GARP_Portal_ProgramDetailService
GARP_Portal_ProgramsService
GARP_Portal_StudyMaterialsService
examWindow → GARP_Portal_ExamWindowService
examResults · examResultViewed → GARP_Portal_ExamResultsService
examSetup · examSetupId · examSetupFees · examSetupAuthorize → GARP_Portal_ExamSetupService
GARP_Portal_ExamSetupFees selection resolution, validation, deferral fees
ExamManagementController outside the bundle — applies the modification
ExamRegistrationsStatusCls outside the bundle — provider push
eppOptIn → GARP_Portal_EppOptInService
GARP_Portal_ProgramDetailService
Study, CV and errata
studyMaterials · myEBooks · eBookAccess · eBookAccessLinks → GARP_Portal_StudyMaterialsService
GARP_Portal_ProgramDetailService
GARP_Portal_ProgramsService
cv · cvExperience · cvAttachment… · cvAddress · cvSubmit → GARP_Portal_CvService
errataForm · submitErrata · attachErrataFile → GARP_Portal_ErrataService
Membership, CPD, directory
membership · membershipAutoRenewOn · membershipAutoRenewOff → GARP_Portal_MembershipService
GARP_ExamReg_Selector the one cross-module edge in the bundle
cpd → GARP_Portal_CpdService
GARP_Portal_ProgramsService
cpdProgram → GARP_Portal_CpdProgramService
cpdActivities · cpdActivityTypes → GARP_Portal_CpdActivityService
cpdClaim · cpdClaimDelete · cpdAttest → GARP_Portal_CpdClaimService
directory · directorySearch · directoryMessage → GARP_Portal_DirectoryService
GARP_Portal_MembershipService
Orders, events, support
orders · orderDetail · payOrder · cancelOrder → GARP_Portal_OrdersService
events → GARP_Portal_EventsService
cases → GARP_Portal_CasesService
submitCase → GARP_Portal_SubmitCaseService
GARP_Portal_CasesService
Shared foundation — reached by nearly every service above
GARP_Portal_Core contact, identity, contracts, completeness, card engine
GARP_Portal_Access the membership gate and the contract map
GARP_Portal_ProgramCatalog config — every programme, from custom metadata
GARP_Portal_Util access checks, error translation, formatting
GARP_Portal_Diagnostics why a response came back thin
Authentication — the site's own endpoints
UIBundleLogin   UIBundleRegistration   UIBundleForgotPassword   UIBundleChangePassword
UIBundleAuthUtils shared — the only thing all four have in common
Two things the graph shows that the tables do not
The modules touch in exactly one place. GARP_Portal_MembershipService reaches into GARP_ExamReg_Selector for pricebook access when staging a recurring membership order. Nothing else crosses. If the registration module is ever extracted, that is the single seam to cut.

Four portal services are load-bearing for others. ProgramsService is called by six, ProgramDetailService by four, NotificationsService and ExamWindowService by two each. A change to any of them is not local — the dashboard, the alert bar, study materials and course detail all read through them.

Registration, cold URL to payment
One @RestResource at /services/apexrest/examreg/*, one envelope ({status, statusCode, errorMessage, data}). The client echoes back IDs and choices only; every amount is re-derived server-side, and register re-runs the whole pricing calculation, so tampering with the cart changes nothing.

The URL resolves

/registration/rai/139A5WOWZ → ExamRegistration. programConfig.ts maps the slug (rai→riskai) and the third segment is carried as regCode.

Load the form — GET examreg/info?type=&regCode=&courseCode=

GARP_ExamReg_LoadService returns eligibility, exam parts and administrations, sites, study materials, countries and the membership upsell. If a regCode is present it is resolved first by GARP_ExamReg_TeamReg â€” affiliate code, then B2B deal seat. A code that resolves to neither fails the load rather than being ignored.

Lazy lists — GET examreg/options

Company and school typeaheads from GARP_ExamReg_Selector. Kept out of the info payload so the page paints first.

Price the cart — POST examreg/fees

GARP_ExamReg_PricingService. Main product, FRM enrolment, China OSTA fees, complimentary membership, the paid membership upsell, study materials, shipping, processing fee and wire/ACH tax. A B2B seat swaps the main product for the exam rate’s Team_Product__c and sets hasBilling = false â€” the employer is invoiced, not the candidate.

Identify the customer — POST examreg/verifyCustomer

GARP_ExamReg_RegService. Returns whether the contact exists, whether the programme forces a sign-in, and a Form_Data__c session id that the register call quotes back.

Check the address — POST examreg/verifyAddress

Billing and shipping validated against Country_Code__c â€” which payment methods the country allows, whether a province or postal code is required.

Write the order — POST examreg/register

GARP_ExamReg_RegService re-prices, then writes the Opportunity, its line items, contracts, exam attempts and contact profile. A B2B seat stamps B2B_Deal_Item__c and EPP_Deal__c on the order; an affiliate code stamps Affiliate_Program_Code__c and its credits. Returns orderId, orderNumber, total, hasBilling.

Payment boundary
From here the bundle stops holding the transaction. Which of three exits it takes is decided by hasBilling and the chosen payment type:

Card → POST examreg/checkout. GARP_ExamReg_Stripe opens a hosted Stripe Checkout Session and the browser leaves for Stripe with a ?stripe_return=1&oid= success URL. Payment and tax are Stripe’s; the org’s existing webhook finalises the order and bumps Seats_Used__c on any B2B deal item.
Wire / ACH, or a zero-total order → POST examreg/payOrder, completed server-side, then POST examreg/paymentStatus polled three times.
Abandoned or failed → POST examreg/rollback cancels the order and its attempts.
payOrder takes no money. It readies the order and reports whether a checkout should follow.

Events, and the payment handshake
Webcasts are free by construction — no rate object, no Opportunity on Webcast_Registration__c. Events and chapter meetings can be either, and the fork is decided server-side from the resolved rate, never from what the client believes.

Load — GET examreg/event/info?eventId=&eventType=

GARP_ExamReg_EventLoad over GARP_ExamReg_EventSelector. Resolves the rate window for this caller â€” member, non-member or alumni â€” and returns amountDue with it.

Register — POST examreg/event/register?eventType=

GARP_ExamReg_EventReg re-loads server-side and re-reads the price. Free: the registration row is written outright, Status Registered, done. Paid: an Account + Contact via GARP_ExamReg_Customer, an Opportunity carrying one line for the rate's product, and a registration row pointing at it.

Checkout — POST examreg/checkout

GARP_ExamReg_Stripe, the same hosted session the exam form uses. The browser leaves for Stripe.

Why a paid registration is written with a null status
It is not an oversight, it is the handshake with the org's Stripe webhook. On payment, GARP_BC_Registration.payOrderSuccessComplete finds registrations by Opportunity__c and promotes the null-status ones to Registered (GARP_BC_Registration.cls:2591-2606).

Writing Registered at order time would mark somebody as attending who has not paid, and the webhook would skip the row because it only touches null ones. The pending state is what makes an abandoned checkout harmless.

The block was in two places, not one
Refusing paid registrations was implemented twice: an Apex exception in GARP_ExamReg_EventReg and an early return in the React RegistrationForm that swapped the whole form for a notice whenever amountDue > 0. Building the server path and testing it over REST proved the order and the Stripe session worked while the page still showed the old notice, because the form never rendered.

Worth remembering when the next capability lands: a server-side gate and a client-side gate for the same rule will not be found by the same search, and an API test cannot see the second one.

Two vocabularies for the same idea
Event__c.Delivery_Method__c is [Online Only | In-Person Only | Hybrid]. Attendance on both registration objects is a restricted [In-Person | Virtual]. Passing one into the other fails the insert with INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST on every non-hybrid record — which is what it did until a real submit was attempted, silently breaking free event registration as well as paid. Both vocabularies are now normalised before the write.

Exam setup, three steps to payment
Reached from Schedule Exam at /programs/exam-setup/:programType. The wizard shows three steps â€” Exam Details, ID Information, Setup Completed â€” but the third is not one screen: the server returns a nextScreen and the page renders whichever ending applies.

Load — GET memberportal/examSetup?programType=

GARP_Portal_ExamSetupService returns the current sittings, the administrations and sites that can be moved to, and the ID form with its country and month options.

Save and decide — POST memberportal/examSetupId

Writes the candidate’s ID and OSTA details to the Contact, then GARP_Portal_ExamSetupFees resolves both ends of the move, applies the validation rules, and prices it. If anything changed, an Exam_Registration_Modification__c is raised. Returns nextScreen: Pay Fees, Check Authorization or Setup Complete.

Show the bill — POST memberportal/examSetupFees

Only on the Pay Fees branch. Re-prices from what the modification recorded, so the checkout page cannot be handed a different cart than the one agreed on screen. The modification must resolve through the signed-in member’s own registrations â€” the legacy fetched it by bare id, which let any member price anyone else’s deferral.

Authorise — POST memberportal/examSetupAuthorize

Only on the Check Authorization branch. Pushes each part to its provider and, once both come back Processed, hands out the Pearson / PSI / ATA scheduling links. isRetry exists because the page polls.

Payment boundary
A change with fees is left Pending. The member is sent to /Login?start=myprograms/setup/feescheckout/{modificationId} â€” the legacy checkout â€” and this page never takes a card. When that order closes, OpportunityHandler’s trigger applies the modification.

A change with nothing to pay is applied immediately, in-request, via ExamManagementController.processExamRegMods.

What the fees actually are
These were once left delegated on the belief that the legacy held a second pricing engine. It does not: there is no pricebook here, only four literal amounts and a lot of branching about which apply.

Line	When	Amount
Administration change â€” FRM	Either part moves sitting	250
Administration change â€” SCR / RAIJ / RAI	The sitting moves	150
OSTA location fee CHLF	Per part newly sitting in mainland China	40
OSTA data fee CHNDF	Once, when the account has no OSTA program yet	10
Refunds	Moving out of China reverses both, if the data was never uploaded	negative
Registration — GARP_ExamReg_*
One REST resource, one envelope. Serves exams, courses, membership, affiliate, events, chapter meetings and webcasts.

Core — exams, courses, membership, affiliate
Class	Job	Lines
GARP_ExamReg_API	The @RestResource at /examreg/* â€” router plus the standard envelope. The only entry point.	219
GARP_ExamReg_Config	Per-program registry read from GARP_ExamReg_Program__mdt; adding a program is a metadata change, not a deploy	225
GARP_ExamReg_Selector	All SOQL for the exam/course/membership side	743
GARP_ExamReg_Dto	Typed request/response contract	343
GARP_ExamReg_LoadService	Screen payload â€” eligibility, exam options, study materials	796
GARP_ExamReg_TeamReg	Resolves the code in the URL â€” EPP affiliate link or B2B deal seat â€” and its referral credits	313
GARP_ExamReg_PricingService	Fees â€” main product, enrolment, OSTA, membership, materials, shipping, tax, B2B seats	893
GARP_ExamReg_Customer	Find-or-create the Account + Contact an order is written against. Shared by the exam and paid-event paths so the two cannot drift	68
GARP_ExamReg_RegService	Verify, register, pay, status, rollback; writes Opportunity, contracts, attempts	961
GARP_ExamReg_Stripe	Hosted Stripe Checkout, module-owned. Serves both exam and event orders	178
Event family — events, chapter meetings, webcasts
Class	Job	Lines
GARP_ExamReg_EventSelector	All SOQL for the three object families â€” the only place their field names live	197
GARP_ExamReg_EventDto	Typed contract, replacing the legacy nested blob	150
GARP_ExamReg_EventLoad	Load, eligibility and the dropdown options	419
GARP_ExamReg_EventReg	Registration writes and RSVP decline, free and paid. A paid one stages an Opportunity and leaves the registration pending for the webhook	422
Three families, not one object with a type flag: Event__c / Event_Rate__c / Event_Registration__c, Chapter_Meeting__c / Chapter_Meeting_Rate__c / Chapter_Meeting_Registration__c, and Webcast__c / Webcast_Registration__c with no rate object because webcasts are free.

Portal — GARP_Portal_*
One @RestResource at /memberportal/*, one service class per action, over a shared core. A batch action folds several GETs into one round trip; anything taking parameters stays a single GET.

Shared plumbing
Class	Job	Lines
GARP_Portal_API	REST surface, routed to one service per action	853
GARP_Portal_Core	Shared core â€” identity, contact, contracts, profile completeness	895
GARP_Portal_Access	The membership gate, plus the contract map every service reads	150
GARP_Portal_ProgramCatalog	Every program, read from GARP_Portal_Program__mdt	590
GARP_Portal_Util	Access checks, error translation, text formatting	130
GARP_Portal_Diagnostics	Why a response came back thinner than it should have	48
Member identity and account
Class	Job	Lines
GARP_Portal_MeService	Identity and membership summary	184
GARP_Portal_AccountService	My Account sections and addresses	196
GARP_Portal_ProfileService	Applies a fieldâ†’value map to the member's Contact	157
GARP_Portal_AddressService	Mailing and billing addresses	137
GARP_Portal_PhotoService	Profile photo upload, set, remove	196
GARP_Portal_OptionsService	Picklist and chapter options for the edit forms	161
GARP_Portal_ExpertiseService	Subject-matter expertise	145
GARP_Portal_OstaService	OSTA identity details	141
GARP_Portal_EmailPrefService	Email subscription preferences	65
GARP_Portal_EppOptInService	Exam-prep-provider outreach consent	83
Programs, exams and study
Class	Job	Lines
GARP_Portal_ProgramsService	The programs listing	867
GARP_Portal_ProgramDetailService	One program's detail page	861
GARP_Portal_CourseDetailService	Course detail	321
GARP_Portal_StudyMaterialsService	Study materials, eBooks, eBook access URLs	1457
GARP_Portal_ExamResultsService	Registrations and released results	423
GARP_Portal_ExamWindowService	Which registration window to advertise	160
GARP_Portal_ExamSetupService	Exam-setup wizard â€” reads plus the three write steps ported	1044
GARP_Portal_ExamSetupFees	Selection resolution, deferral rules and the fee maths behind it	803
GARP_Portal_CvService	FRM/ERP certification CV and work experience	1294
GARP_Portal_ErrataService	Errata form, submission and attachments	338
Membership, CPD, directory, orders
Class	Job	Lines
GARP_Portal_MembershipService	Standing, benefit catalogue, auto-renew	799
GARP_Portal_CpdService	The dashboard CPD summary	153
GARP_Portal_CpdProgramService	The CPD page per program	447
GARP_Portal_CpdActivityService	Browse Credit Opportunities	236
GARP_Portal_CpdClaimService	CPD claim, delete and attestation	283
GARP_Portal_DirectoryService	Member Directory settings, search and messaging	672
GARP_Portal_OrdersService	Purchase history, unpaid and paid	528
GARP_Portal_EventsService	The member's events listing	449
Dashboard furniture and support
Class	Job	Lines
GARP_Portal_DashboardService	The dashboard payload	232
GARP_Portal_AlertBarService	The banner across every portal page	399
GARP_Portal_AdService	The dashboard exam advertisement	124
GARP_Portal_NotificationsService	Exam notifications	228
GARP_Portal_DismissCardService	Hides or restores a dismissible card	42
GARP_Portal_CasesService	Support cases raised by the member	47
GARP_Portal_SubmitCaseService	Raises a support case	229
Authentication — UIBundle*
The site's own login plumbing. No legacy references.

Class	Job	Lines
UIBundleLogin	Sign in	94
UIBundleRegistration	Self-registration	145
UIBundleForgotPassword	Password reset request and reset	62
UIBundleChangePassword	Password change	68
UIBundleAuthUtils	Shared auth helpers	63
Verified by running it
Deployed to devjuly25a across several waves â€” 301/301 components on the main deploy (0AfgP0000069YBvSAM), then 58–60 component Apex deploys for the B2B, affiliate and exam-setup work. GARP_EventReg_REST was removed by destructive deploy and is gone.

Check	Result
All 10 registration program types resolve	mem → kind=membership, affiliate → isAffiliate=true, addOns=(AFREE)
Real Event__c / Chapter_Meeting__c / Webcast__c loads	Eligible, correctly refused (closed), and eligible on-demand respectively
B2B seat re-prices the exam	RAI RAINMS 750 → RAITNME 650, hasBilling=false; FRM FRM1S 800 → FRM1TE 600
Expired and unknown codes	Refused, not silently ignored â€” previously both quoted full price
Affiliate codes, all 8 in the org	Credits computed; an out-of-window deal correctly refused
Exam-setup port vs legacy, live members	6/6 identical on status, changes, scheduling and total
Exam-setup fee engine vs legacy	8/9 identical; the ninth is a legacy null fee name for Risk AI
Affiliate registration, submitted for real	Order W3869837 â€” total 0, hasBilling=false, contract created, exactly one AFREE line
Event API called anonymously, no session	GET â€¦/sf/api/services/apexrest/examreg/event/info â†’ HTTP 200, full payload, isAuthenticated:false â€” guest access and GARP_ExamReg_API grant both confirmed working
Legacy event paths in the deployed bundle	All seven present, served hash matches the build
Paid event registration, guest, end to end	Order W3869839 â€” Opportunity 1045.00 / New Lead / Automated, one EVENTNMS line, contact role, registration linked with null status, and a live checkout.stripe.com session returned
The webhook would promote it	Its own query (Opportunity__c + null status) returns the row â†’ true
Caveats worth carrying
Sandbox data blocks two proofs. No currently-open exam rate has Team_Product__c populated, so a live B2B registration hits “Team registration products not configured” â€” legacy would too. And only one administration is open per exam type, so a real deferral cannot be constructed; the exam-setup live diff covers no-op selections only.
Paid events now complete; paid chapter meetings are untested. The paid path is one code path for both, but only an event has been run through it end to end. A chapter meeting writes to a different object with its own restricted picklists, which is exactly where the event path broke first — try one before trusting it.
Affiliate registration has now been submitted once; paid membership has not. Running /registration/affiliate end to end is what surfaced a duplicate AFREE line on every affiliate order — the guard that stops the free-membership fallback firing twice listed the four paid and complimentary codes but not AFREE itself, so the cart’s own line did not count. Fixed and re-verified. Nothing has been ordered through /registration/mem, which does take money.
Three B2B deal fields are not applied, left alone rather than guessed at: OSTA_Fee_Paid_by_Institution__c, GST_Fee_Paid_by_Institution__c and Free_Membership__c. The legacy handles each outside its fee routine.
No page has been opened in a browser at any point. Everything above is deploy results, org describes and anonymous Apex. Rendering is unverified.
Guest Apex Class Access is still manual. The guest profile needs GARP_ExamReg_API; the grant for the deleted GARP_EventReg_REST can be removed.
Compiled 22 August 2026 from the GarpAppv1 source tree; dependency figures produced by stripping comments from all 60 classes before matching, so documentation prose is not counted as a dependency. Line counts are measured, not estimated.