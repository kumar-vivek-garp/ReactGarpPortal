Legacy garpapp · Angular · hash router
garpapp Route Atlas
Every route in the legacy member portal, and every button, link and action on it — transcribed from the Angular sources recovered out of garpApp2/main.js.map. Labels are quoted verbatim, including the legacy's own typos. The status chip on each route records where the React port stands today.

Ported and deployed
Ported with known gaps
Not ported
Status reflects a read of the React source against each legacy page, not a click-through of the running app. All 25 legacy portal routes now resolve in React; the chips below describe feature parity within them, and the ranked gap list follows the index.

All routes at a glance
Legacy path	Component	React path	Status
/dashboard	DashboardComponent	/dashboard	Gaps
/my-account	MyAccountComponent	/my-account	Ported
/programs	ProgramsComponent	/programs	Gaps
/programs/:program	ExamDetailsComponent	/programs/:programType	Ported
/programs/exam-setup/:program	ExamSetupComponent	/programs/exam-setup/:programType	Ported
/exam-results	ExamResultsListingComponent	/exam-results	Gaps
/work-experience	WorkExperienceComponent	/work-experience	Ported
/work-experience/manage/:programType	ManageWorkExperienceComponent	/work-experience/manage/:programType	Ported
/work-experience/manage/addresses/:programType	SubmitAddressesComponent	/work-experience/manage/addresses/:programType	Ported
/work-experience/manage/addresses/review/:programType	ReviewWorkExperienceComponent	/work-experience/manage/addresses/review/:programType	Ported
/study-materials	StudyMaterialsListComponent	/study-materials	Gaps
/study-materials-type/:program	StudyMaterialsListComponent	/study-materials-type/:program	Ported
/study-materials-archive	StudyMaterialsArchiveComponent	/study-materials-archive	Ported
/cpd	CpdComponent	/cpd	Gaps
/cpd-activities	CpdActivitiesComponent	/cpd-activities	Ported
/cpd-activities-detail/:activityId	CpdActivitiesComponent	/cpd-activities-detail/:activityId	Ported
/membership	MembershipComponent	/membership	Gaps
/member-resources	MembershipComponent	/member-resources —  /membership	Ported
/member-directory	MemberDirectoryComponent	/member-directory	Gaps
/member-directory-search/:searchtext	MemberDirectoryComponent	/member-directory-search/:searchtext	Ported
/events	MyEventsComponent	/events	Gaps
/help-center	HelpCenterComponent	/help-center	Ported
/purchase-history	PurchaseHistoryComponent	/purchase-history	Ported
/order-details/:orderNumber	OrderDetailsComponent	/purchase-history/:orderNumber	Gaps
/errata/:programType	ErrataComponent	/errata/:programType	Ported
/registration/{frm|scr|rai|ffr|frr|frr25|membership}	RegistrationFormComponent	/registration/:programType	Gaps
/registration/micro/:courseCode	MicroFormComponent	/registration/:programType	Gaps
/registration/survey · /registration/information	SurveyFormComponent	/registration/survey · /registration/information	Ported
/registration/completed	CompletedFormComponent	in-page, not a route	Gaps
(no route — cookie-driven)	GatedContentComponent	/content	Ported
Two apps, not one. The legacy portal is garpapp. Registration, checkout and order payment live in a different older app, sfdcApp, and garpapp reaches them by full page navigation — /sfdcApp#!/registration/{type} and /Login?start=checkout/{productCode}/. Those hand-offs are marked external throughout and are the boundary of what the React port owns.

What's missing — ranked
Every legacy route has a React counterpart, so the route map is complete. This is the feature-parity audit that followed: what reading the React source against the legacy turned up, and what has since been built. Everything marked Fixed is deployed to devjuly25a and typechecks — none of it has been driven in a browser.

Gap	Where	What it costs
Fixed Exam Setup is step 1 only	PortalExamSetup.tsx	A member cannot schedule or defer an exam. Steps 2 and 3 don't exist, there is no fees table, and Next Step at step 1 is hard-disabled. saveExamSetupId, fetchExamSetupFees and authorizeExamSetup all exist in the API client with zero call sites.
Fixed Study-materials Purchase link is hardcoded	PortalStudyMaterials.tsx:200	Points at garp.org instead of /Login?start=checkout/{productCode}/. Nothing can be bought. productCode is loaded and unused.
Fixed No Download Order on order detail	PortalOrderDetail.tsx	The legacy's own copy tells unpaid members to download the order for payment instructions. Without it, a wire or ACH payer has no way to get those instructions.
Fixed Member Directory has no details dialog	DirectorySearch.tsx:302-334	Rows aren't clickable. Send Message and Invite to Connect are unreachable — sendDirectoryMessage is never imported. Ten fetched fields (job function, risk specialty, designations, CPD cycles…) are never shown.
Fixed Membership page is missing its actions	PortalMembership.tsx	No Manage My Membership, Renew Now, Become a Member, or View Order. The state-specific copy and the benefit dialog are absent; the five per-tile CTAs collapse to one server label.
Fixed Manage Attendance never rendered	PortalEvents.tsx	canManageAttendance is in the type and the fixtures but has no UI. Chapter directors cannot take attendance.
Fixed EPP portal link points to the wrong URL	DashboardCards.tsx:433-441	/eppApp where the legacy uses /garpEPPPortal. GBI is /gbiApp vs /gbiapp — check whether the host is case-sensitive.
Partly Exam Results quartiles are flat bars	PortalExamResults.tsx:31-63	No bell curve, no Show/Hide accordion, and no Understanding / Percentile readout — those two aren't on the wire at all. Contact link is a mailto: where the legacy routes to /help-center, and it's missing on Fail.
Fixed Dashboard Undo missing	PortalDashboard.tsx	Dismissing the profile card is irreversible in the UI. restoreCard exists and is never imported. Notification See All goes to /programs rather than opening the dialog.
Fixed CPD Download Handbook disabled	PortalCpd.tsx:355	Hard-disabled with “The handbook isn't available yet”. The Apex never returns cpdHandbookURL — this needs a server change, not just a UI one.
No breadcrumbs anywhere	PortalPage.tsx	The legacy breadcrumbs on exam results, the archive and CPD have no equivalent. A breadcrumb component exists in the design system but no portal page imports it.
Fixed Gated content not ported	/content	The membership paywall. A member following a gated link from garp.org had nowhere to land, so the upgrade path off that link did not exist. Built as a real route rather than the legacy's shell hijack, which makes the state unlinkable. Needed a new isMemberInGoodStanding on the identity payload — the membership type is the wrong gate, and a lapsed Individual still reads "Individual".
Fixed Demographics survey not ported	/registration/survey	The React registration flow went straight from the form to its confirmation, so nobody was ever asked — which is why members reach My Account with an empty Career Information card. Optional, seeded from what they already have, and it only writes on Submit.
Exam-setup live fee preview has no endpoint	Apex	The legacy re-prices on every dropdown change via getExamSetupExamSelectionInfo. There is no Apex equivalent — fees can only be fetched after the change is saved, so the member commits before seeing the cost.
The API layer is ahead of the UI. Six client functions have no call site at all — saveExamSetupId, fetchExamSetupFees, authorizeExamSetup, restoreCard, sendDirectoryMessage, fetchAd — and two Apex actions (examWindow, eBookAccessLinks) are never called either. Several gaps above are UI-only work on plumbing that already exists and is deployed.

Global chrome
Left rail
app-side-nav-bar
Ported
Six items and a profile block. The React rail matches it exactly — same items, same order, same labels.

Label	Legacy icon	Goes to
{first name} {last name} (GARP ID {id})	account_circle	/my-account
Dashboard	home_outline	/dashboard
Programs	auto_stories_outline	/programs
Study Materials	psychology_outline	/study-materials
Membership Benefits	group	/membership
Events	calendar_month_outline	/events
Help Center	help_outline	/help-center
My Account and Exam Results are deliberately not rail items — My Account hangs off the profile block at the top, and Exam Results is reached from Programs and the dashboard card.

Top bar
app-desktop-nav-bar
Ported
The GARP logo, six marketing mega-menus, and sign-out. Every menu link leaves the portal for garp.org.

Menu	Columns
FRM	FRM Certification · FRM Resources
SCR	SCR Certificate · SCR Resources
Risk & AI	RAI Certificate · RAI Resources
Membership	Membership · Professional Development
Insights & Events	Risk Insights · Content Type · Events
About Us	About Us · Industry Engagement
These URLs do not follow a pattern — don't generate them. FRM uses /frm/program-exams while SCR and RAI use /program-exam (singular). FAQs live at /frequently-asked-questions, not /faq. GARP Risk Institute points at /sustainability-climate-risk. The nav table also ships one dead link — #placeholder-garp-for-students.

Footer
app-footer
Ported
Nine link columns, a logo and social block, then a bar of five notices. The columns are not the same lists as the mega-menus even where the headings match — the footer has Membership Overview and Career Center where the menu has Overview and Risk Career Center, and adds Resources, Events and Additional Education columns the menu has no equivalent of.

Columns	Footer bar
Financial Risk Manager (FRM) · Sustainability and Climate Risk (SCR) · Risk & AI (RAI) · Membership · Resources · Events · Additional Education · About Us · Industry Engagement	Important Notices · Bylaws · Code of Conduct · Privacy Notice · Terms of Use · © Global Association of Risk Professionals
Home & account
/dashboard
Dashboard · DashboardComponent
Gaps
The landing route — '' and the ** catch-all both redirect here. There is no page heading. Cards come from a server-supplied ordered manifest, not from markup: the client holds no card list at all, and a name the dispatch table doesn't know renders nothing.

Card / section	Shows when
Complete Your Profile (4 heading variants)	manifest contains Member Profile
Enrolled Programs	manifest contains Enrolled Programs — first 2 only
Advertisement	manifest contains Advertisement — which programme depends on adType
Member Directory	manifest contains Member Directory
{cycle} CPD Credits	manifest contains CPD
My Events	manifest contains Events — first 2 only
New Notifications	manifest contains Exam Notifications
Access GBI	manifest contains GBI Portal
Access EPP	manifest contains EPP Portal
BenchPrep Access	manifest contains BenchPrep Viewer
Label	Shown when	Goes to
✕ dismiss	Member Profile card header	muteProfileComponent(true) — hides it for 6 months
Undo	after dismissing	muteProfileComponent(false)
Update My Profile	profile card, career data loaded	the Edit Profile dialog
Register Now	Advertisement card, registration open	/Login?start=registration/{frm|scr|rai}
a programme name	Enrolled Programs rows	/programs/{programType}
See All	Enrolled Programs footer	/programs
—x— / Enter	Member Directory card search box	/member-directory-search/{term}
View Directory	Member Directory footer	/member-directory
Manage Credits	CPD card footer	/cpd
an event name	My Events rows	garp.org/events/{slug}
See All	My Events footer	/events
See All	New Notifications footer	the notifications dialog
Access Now	GBI card	/gbiapp
Access Now	EPP card	/garpEPPPortal
a BenchPrep link	BenchPrep card rows	that link's URL
Dialog	Opened by	Its buttons
Notifications	See All on the notifications card	close only
Edit Information (sic — double space)	Update My Profile	Cancel · Save Changes
Port gap. The dashboard opens the shared profile dialog without a name, so its title renders as Edit  Information with the word missing. The Mute Profile Reminders For 1 Year link inside it also has href="" and is dead. Every card's data is memoised for the session, so nothing refetches on return.

/my-account
My Account · MyAccountComponent
Ported
Header with two pills and an email-preferences link, then six cards. Three of them save inline with no dialog and no Save button.

Card / section	Shows when
Personal Information	always
Career Information	always — includes the professional designations
Membership	always
Preferred Chapters	always — two dropdowns, save on change
Directory Settings	always — four checkboxes, save on change
Expertise	always — four multi-selects, save on close
Label	Shown when	Goes to
Account Settings / Order History	tab pills	/my-account · /purchase-history
Manage My Email Subscription Preferences	header, right	stamps Last_Email_Pref_Update_Date__c; org automation sends the mail
Edit (Personal Information)	card footer	dialog — photo, name, email, mobile, billing + mailing address
Upload / Remove (photo)	inside the edit dialog	immediate — 2 MB cap, JPEG and PNG only
Edit (Career Information)	card footer	dialog — job info, designations, academic
Upgrade	Membership card, Affiliate only	external · sfdcApp
Renew Now	Individual, auto-renew off, no pending order	external · sfdcApp
Disable Auto Renew	Individual, auto-renew on	membershipAutoRenewOff
Turn On Auto-Renew	Individual, auto-renew off, not lapsed	membershipAutoRenewOn — needPaymentInfo means checkout still required
View Order	a pending membership order exists	/order-details/{id}
View Upcoming Meetings	Preferred Chapters footer	/events
Programs & exams
/programs
My Programs · ProgramsComponent
Gaps
Three sections, each hidden when empty. On mobile they become a single-open accordion.

Card / section	Shows when
In Progress	enrolledPrograms.length > 0
Completed	completedPrograms.length > 0
Explore Other Programs	otherPrograms.length > 0
CPD card (rail)	hasCPDProgram
Exam Results card (rail)	hasExamResults
Label	Shown when	Goes to
View Details	In Progress and Completed cards only	/programs/{programType}
Register Now	Explore card, registration open	external · sfdcApp — riskai becomes rai; micro courses use micro/{code}
Learn More	Explore card	garp.org/{programType}
See All	Exam Results rail card	/exam-results
Port gap. The Explore Other Programs cards never link to /programs/:program — an un-enrolled member can only reach that page by typing the URL, where it renders an empty section with no message.

/programs/:program
{formal program name} · ExamDetailsComponent
Ported
The largest page in the portal. :program selects both the data source and the render branch: frm, scr, riskai and erp take the exam-attempt branch; frr, frr25, ffr and any other slug fall through to the course-detail branch.

Card / section	Shows when
New Notification	examNotifications.length
Work Experience (CV card)	programState === 'CVSubmission'
Manage Your Exam	a deferral is open, Part II can be added, or an ADA form exists
{TYPE} Exam Part I	result not stale, and programType !== 'ERP'
{TYPE} Exam Part II	Part II has an attempt, and not SCR / RiskAI
ID INFORMATION	a sitting can still be changed, or is booked and awaiting
OSTA INFORMATION	as above, FRM only, and isOSTACandidate
{TITLE} Program (expired)	programState === 'EnrollmentExpired'
Congratulations! (completed)	programState === 'Completed'
Share Your Progress (rail)	a part has a released result of Pass
Important Deadlines (rail)	deadlines exist and a part is SchedulingOpen
Exam Resources (rail)	examResources is present
Exam Results (rail)	a part has results, or the program is complete
Label	Shown when	Goes to
View Order	Part card, Unpaid	/order-details/{unpaidOrderId}
Edit —S}	deferral open and no unpaid change	/programs/exam-setup/{programType}
Exam Setup	scheduling open and already scheduled	/programs/exam-setup/{programType}
Schedule Exam	scheduling open, not yet scheduled	same
Take Exam	showTakeExam	the provider's URL, new tab
Register Again	never scheduled, window closed, registration open	external · sfdcApp
View Results Details	results available	/exam-results
Register for Part I / Part II	results available and registration open	external · sfdcApp
Defer Exam	Manage Your Exam, deferral open, nothing unpaid	/programs/exam-setup/{programType}
Add FRM Part II	registration open and Part II can be added	external · sfdcApp — hard-codes frm
ADA Application	an ADA form URL exists	the form, new tab
View Pending Order	an unpaid exam change exists	/order-details/{id}
Submit / Resubmit Work Experience	CV card, Initial or Failed Review	/work-experience/manage/{programType}
Read more..	notification card	the notifications dialog
Show	ID card, FRM, an ID number exists	reveals the masked number in place
Member Services	ID card footer	mailto:memberservices@garp.com
Edit OSTA Information —S}	OSTA card footer	/programs/exam-setup/{programType}
Share on LinkedIn	completed card and badge card	the LinkedIn dialog
Download Certificate	SCR and RiskAI only	the certificate URL
Request Copy of Certificate	FRM and ERP only	/Login?start=myprograms/certcheckout/{type}
GARP Learning Platform	an e-learning URL exists	the platform, new tab
{program} eBooks	eBook items exist and provider is not Pearson	the eBooks dialog
Study Materials	not FFR	/study-materials-type/{programType}
Submit Errata	not FRR / FRR25 / micro	/errata/{programType}
Download ADA Application	rail, an ADA URL exists	the form, new tab
Need Help Studying?	not already opted into EPP	the EPP opt-in dialog
Dialog	Opened by	Its buttons
Notifications	Read more..	close only
Share on LinkedIn	Share on LinkedIn	Copy Link
{program} eBooks	the eBooks link	one link per title; eBook not available when unsigned
Need Help Studying?	the EPP link	Yes · No
/programs/exam-setup/:program
{TYPE} Exam Setup · ExamSetupComponent
Ported
A three-step wizard on one route — the step is component state, not a URL, so it cannot be linked to or refreshed into. Paying a fee difference leaves the wizard for checkout and comes back.

Card / section	Shows when
1 · Exam Details	administration and site for each part, plus any fees the change incurs
2 · ID Information	ID type, number and expiry; OSTA candidates fill nine more fields in Chinese
3 · Setup Completed	the outcome — authorized, awaiting authorization, or simply done
Label	Shown when	Goes to
Next Step	step 1 — disabled while loading	step 2
Reset Selections	step 1	clears the form — no confirmation
Back to My Programs	steps 1 and 2	/programs/{programType}
Next Step / Saving…	step 2 — disabled while saving	step 3, or out to /Login?start=myprograms/setup/feescheckout/{id} when fees are due
Schedule Exam / Schedule Exam Part I / Part II	step 3, authorized, and a provider URL came back	the provider, new tab
contact member services	step 3, authorization did not complete	/help-center
Back to My Programs	step 3	/programs/{programType}
Port gap. There is no Back button anywhere in the wizard — the method exists but is never bound, and the step circles are not clickable. Step 1's validator is also hard-coded to true, so that step cannot fail validation at all. Authorization retries exactly once, after a fixed 20-second wait.

/exam-results
Exam Results · ExamResultsListingComponent
Gaps
A top-level route, not nested under /programs. One card per sitting, with the result sentence chosen by outcome and an expandable quartile panel underneath.

Card / section	Shows when
{programType} : {administration}	one per result
Exam Results : {result}	the result is set
Congratulations! You have passed the {exam}.	result === 'Pass'
We regret to inform you that your result did not meet the requirement to pass the {exam}.	result === 'Fail'
Your Exam was not graded. Please contact member services.	Not Graded, or any violation
We do not have a record of you attending the {exam} Exam…	No-Show
Quartile panel	the result has quartiles and its card is the open one
Label	Shown when	Goes to
Show Quartiles / Hide Quartiles	the result has quartiles	expands in place — accordion, one open at a time
View Exam Results Letter	also gated on having quartiles	the letter PDF, new tab
Download	inside an expanded quartile panel	the performance-analysis PDF, new tab
contact member services	violation, Not Graded or No-Show	/help-center
Port gap. The results-letter button sits inside the quartile gate, so a result with no quartiles offers no way to read its letter. All three actions stamp the last-viewed date, including merely toggling the panel.

Certification CV
/work-experience
Work Experience · WorkExperienceComponent
Ported
A status card driven by cvPageInfo.status. Desktop only in the legacy.

Card / section	Shows when
Submission Needed	status === 'New' or 'In Progress'
Submission Received	status === 'Submitted'
Submission Declined	status === 'Failed Review'
Label	Shown when	Goes to
Submit Work Experience	status === 'New'	/work-experience/manage/{''}
Manage Work Expierence (sic)	In Progress and Submitted	same
Manage Work Expierence (sic)	Failed Review	nothing — the button has no handler
Port gap. The route carries no :programType, so the legacy calls the service with an empty string and every CTA builds a broken URL. There is also no branch for an approved CV — a certified member sees an empty card. The React port asks the server which certifications the member actually holds and renders one card each.

/work-experience/manage/:programType
Manage Work Experience · ManageWorkExperienceComponent
Ported
The entry list — start date, organisation, months, manager, attachments — with the running total against the requirement.

Label	Shown when	Goes to
+ Add Work Experience Entry	always	the entry dialog, step 1
Confirm & Submit Work Experience	enabled only when isValidExperienceSubmission	/work-experience/manage/addresses/{programType}
View / Add (attachments)	per row — View when it has files	the entry dialog, opened on step 2
—S} edit	per row	the entry dialog, step 1
—x delete	per row	the delete confirmation
Dialog	Opened by	Its buttons
Work Experience Detail	Add / edit / attachments	Back · Cancel · Save & Continue · Close
Are you sure you want to permanently delete this work experience?	the row's delete icon	Cancel · Delete
/work-experience/manage/addresses/:programType
Submit Work Experience · SubmitAddressesComponent
Ported
Where the certificate is posted. OSTA candidates fill a second address in Chinese characters.

Label	Shown when	Goes to
NEXT	form valid	/work-experience/manage/addresses/review/{programType}
Port gap. The legacy applies each country's postal-code and province rules inside a loop over every country, so the last row in the list wins rather than the selected one — and setValidators wipes the length and character rules while doing it. There is no Back button. Both fixed in the port.

/work-experience/manage/addresses/review/:programType
Submit Work Experience · ReviewWorkExperienceComponent
Ported
Label	Shown when	Goes to
Edit (experience)	always	/work-experience/manage/{programType}
Edit (address)	always	/work-experience/manage/addresses/{programType}
Submit Your Experience	always in the legacy	submitCVInfo, then /programs
Port gap. No confirmation, no attestation, and Submit is not gated on isValidExperienceSubmission here — a member can raise a review the server will reject. The port gates it.

Study & CPD
/study-materials
Study Materials for Risk Professionals · StudyMaterialsListComponent
Gaps
A card grid with a client-side programme filter. Each card is one of four states: owned, unpaid, purchasable, or coming soon.

Label	Shown when	Goes to
All · Financial Risk Manager · Sustainability & Climate Risk · Risk & AI · Financial Risk and Regulation	filter pills	client-side only in the legacy — the URL never changes
My Access Links	the member owns at least one eBook	/study-materials-archive
Purchase	purchasable and available	/Login?start=checkout/{productCode}/
Download Now	a Download-type material that is owned	the download URL
Access	an owned eBook or GARP Learning item	the reader, or the detail dialog
View Details	coming soon, unpaid, out of stock or blocked	the detail dialog
Dialog	Opened by	Its buttons
{material title}	any card	Purchase · View Order · Download Now · Access
Port gap. An empty bucket is indistinguishable from loading — both shimmer forever. The pills also don't sync to the URL, which makes /study-materials-type/:program a dead end. Both fixed in the port.

/study-materials-type/:program
Study Materials for Risk Professionals · StudyMaterialsListComponent
Ported
The same page filtered to one programme. The slug is normalised — anything containing frr maps to FRR and riskai to RAI.

/study-materials-archive
Purchased Study Materials · StudyMaterialsArchiveComponent
Ported
Owned eBooks only, grouped by edition year, newest first. No filters, no commerce.

Label	Shown when	Goes to
Access	per title	the signed reader URL, new tab
Port gap. No loading, empty or error state at all — a member with no eBooks sees the same bare page as one whose request failed. Added in the port.

/cpd
Continuing Professional Development · CpdComponent
Gaps
A cycle picker, the credit chart, and two tables. Everything but the Approved table is hidden for a past cycle.

Card / section	Shows when
Manage CPD Credits	the selected cycle is the current one
Pending Activities	current cycle only
Approved Activities	every cycle
{cycle} Credit Summary	a cycle is selected
Label	Shown when	Goes to
Add Credits	current cycle	the claim dialog, add mode
Download Handbook	current cycle	the handbook URL, new tab
Browse Credit Opportunities	current cycle	/cpd-activities
Edit —S} / Delete —x	pending claims only	the claim dialog · the delete confirmation
Details	approved claims	the read-only claim dialog
CPD Certificate — FRM / ERP / SCR / RAI	that designation is active and complete	attestation dialog first if not yet attested, then the PDF
Dialog	Opened by	Its buttons
Credit Details	Add Credits / Edit / Details	Submit or Update; read-only has none
Delete this submission?	the delete icon	Cancel · Delete
You have completed your required {n} credits.	a certificate link, not yet attested	Submit — two required checkboxes
Port gap. A member with no matching cycle shimmers forever; there is no empty state and no error state.

/cpd-activities
Browse CPD Activities · CpdActivitiesComponent
Ported
The credit-opportunity catalogue. Filters and sort are server-side; paging is a cumulative Load More that re-requests a larger page rather than appending.

Label	Shown when	Goes to
View Details / Hide Details	per card	expands the description in place
Submit Credits	expanded card	the claim dialog, pre-filled from the activity
Visit Website	the activity has a URL	that URL, new tab
Apply	filter panel	re-queries with the ticked filters
Load More	the page came back full	re-queries with pageSize + 50
Manage my credits	header	/cpd
Port gap. Filter and sort are desktop-only — on mobile there is no way to narrow the list at all. The filter state also lives in a module-level subject that is never reset, so it leaks across navigations.

/cpd-activities-detail/:activityId
Browse CPD Activities · CpdActivitiesComponent
Ported
The same page scoped to one activity — there is no separate detail view. A View All Activities button drops the scope without changing the URL.

Community
/membership
Membership Benefits · MembershipComponent
Gaps
An identity card whose copy switches on membership state, then benefit tiles grouped into server-supplied categories. Each tile is gated on its own hasAccess flag.

Card / section	Shows when
Member Benefits / Member Directory	tab pills — the second navigates away
Identity card	always — name, GARP ID, member type, member status
Welcome copy	Active Individual, no pending order
Renewal copy	Lapsed Individual, no pending order
Upgrade copy	Affiliate, no pending order
You have a pending membership order.	a pending order exists — outranks all three above
{category} benefit grids	one per server category
Label	Shown when	Goes to
Manage My Membership	Active Individual	/my-account
Renew Now	Lapsed Individual	external · sfdcApp with track_cta=PortalMembershipPage
Become a Member	Affiliate	same
View Order	a pending membership order exists	/order-details/{id}
{accessButton} (server-supplied label)	tile is unlocked and has an access URL	that URL — new tab or same tab per accessURLNewWindow
Learn More	tile is locked and has pop-up copy	the benefit dialog
Upgrade Now	tile locked, Affiliate	external · sfdcApp with track_cta={benefit key}
Renew Now	tile locked, Lapsed Individual	same
{purchaseOverrideTitle}	tile locked with a purchase override	that URL, same tab
the whole tile	any tile — but only does anything when locked with pop-up copy	the benefit dialog
Dialog	Opened by	Its buttons
{benefit title}	a locked tile or Learn More	View Order · Upgrade Now · Renew Now · {purchaseOverrideTitle}
Port gap. A locked tile is marked only by a small overlay image pinned to the corner — there is no text saying it is locked. The tile-level View Order also reads item.pendingMembershipOrderId, a field that lives on the member and not the benefit, so it resolves undefined. And the dialog's upgrade CTA uses a different URL shape (/Login?start=registration/membership) from the page's.

/member-resources
Membership · MembershipComponent
Ported
A second path onto the membership page. The React port keeps it as a redirect so existing links still land.

/member-directory
GARP Member Directory · MemberDirectoryComponent
Gaps
Keyword search plus an advanced filter panel that only entitled members get. Ten results a page, sorted LastName DESC server-side with no sort UI.

Label	Shown when	Goes to
Member Benefits / Member Directory	tab pills	/membership · this page
—x— search	always	runs the search — Enter also works
SHOW ADVANCED / HIDE ADVANCED	hasAdvancedSearch	toggles the filter panel
CLEAR FILTER	filter panel	resets the filters — but does not re-run the search
a result row	always	the member details dialog
‹ ›	paginator	server-side paging, 10 per page
{Upgrade|Renew} your Membership	no advanced access and no pending order	external · sfdcApp
View Order	a pending membership order exists	/order-details/{id}
Dialog	Opened by	Its buttons
{member name}	a result row	Send Message · Invite to Connect
Port gap. Three live bugs: the No results found. state can never render because its flag is set once and never changed; a new search never resets to page 1; and Send Message sends the wrong message type and drops the text the member typed.

/member-directory-search/:searchtext
GARP Member Directory · MemberDirectoryComponent
Ported
The same page with the term pre-filled and run on arrival. This is what the dashboard's directory card links to.

/events
Events · MyEventsComponent
Gaps
Three lists, sorted by date client-side. Chapter Meetings and Featured Events are hard-truncated to five with no show more.

Card / section	Shows when
Attending	always — from registeredEvents
Upcoming Chapter Meetings	always — first 5
Featured Events	always — first 5
Label	Shown when	Goes to
View All Events	tab pill	garp.org/events/all, new tab
Set/Change My Chapter	tab pill	/my-account
an event name	per row	the event's own URL, same tab
Manage Attendance	canManageAttendance	/Login?start=chapterMeetingRegistrationsAttendance/{eventId}
Add to Calendar	Attending rows only	Google · Apple · Microsoft 365 / Outlook · Download .ics
Port gap. Featured Events shows the chapter-meeting empty-state copy by mistake, the loading shimmer is unreachable, and a non-200 response renders a completely blank page.

/help-center
Help Center · HelpCenterComponent
Ported
A heading and the support-case form. No FAQ, no search, no articles.

Label	Shown when	Goes to
Submit	subject and description both filled	submitCustomerCase, then a thank-you panel
Port gap. The form has no error branch at all — because the remoting layer resolves errors instead of rejecting, a failed submission still shows the thank-you message.

Orders & support
/purchase-history
Purchase History · PurchaseHistoryComponent
Ported
Two lists with one shared search box. Both sections always render their heading — an empty one shows a message rather than disappearing.

Card / section	Shows when
Account Settings / Order history	tab pills — Order history is the inert current tab
Search	always — filters both lists client-side
Unpaid Purchases	always
No unpaid purchase	the unpaid list is empty
Paid Purchases	always
No paid purchase	the paid list is empty
Label	Shown when	Goes to
Account Settings	tab pill	/my-account
an unpaid order number	per row — desktop only	/order-details/{orderId}
a paid order number	per row	/order-details/{orderId}
Port gap. The whole unpaid list is wrapped in a desktop-only directive, so a member on a phone cannot see or reach their unpaid orders at all. The loading skeletons also never render — they sit on an <ng-template> with a structural *ngIf, which cancels itself out.

/order-details/:orderNumber
{order name} {order number} · OrderDetailsComponent
Gaps
Every View Order in the portal points here. The React port keeps the legacy path as a redirect because the legacy's own emails use it.

Card / section	Shows when
Purchase Date / Amount / Payment Status	an order was found
Note: Please download you order to see instructions… (sic)	unpaid and not payable online
Note: This AliPay order is still pending. Check back for updates.	an AliPay order that cannot be cancelled
{statusMessage}	no order found — a 404 from the service
Label	Shown when	Goes to
Download Order	always	/apex/InvoicePrintAsPDF?id={orderId}, new tab
Pay Order	canPay	/stripe_checkout?regType=orders&id={orderId} — status 201 means nothing to pay and returns to the list
Cancel Order	canCancel	cancels, then /purchase-history
View Orders	always	/purchase-history
Port gap. Cancel Order fires immediately with no confirmation. The route parameter is also named :orderNumber but every caller passes an orderId.

/errata/:programType
Curriculum errata · ErrataComponent
Ported
The published errata sheet, the reporting instructions, and the submission form. Study material and book cascade client-side.

Label	Shown when	Goes to
Download the current errata	a sheet exists for the programme	the PDF, new tab
Submit	form valid	submitErrataForm, then attachFileErrataSubmission if a file is attached
Submit Another Errata	after a successful submission	resets the form
Return to My Programs	after a successful submission	/programs
Back	always	nothing — no href, no handler
Port gap. The failure message is set but never rendered — only a file-size error can appear — so a failed submission looks like nothing happened, and the Submit button stays stuck on Submitting… forever. All three fixed in the port.

Registration
/registration/{frm|scr|rai|ffr|frr|frr25|membership}
{formal program name} · RegistrationFormComponent
Gaps
Page one of three. Each programme has its own form component over one shared shell, plus an optional /:regCode for team and affiliate codes. Every registration button elsewhere in garpapp bypasses these routes and navigates out to sfdcApp instead — these are reachable by URL.

Card / section	Shows when
Registration is not available.	the member is not eligible — replaces the entire form
Welcome back {name} / Individual Details	returning member vs. new
Billing Address	always
Shipping Address	the programme ships something — not FFR or membership
Secure Payment Options	there is something to bill for
Order Summary	always — fees, policy attestations, and the submit button
Label	Shown when	Goes to
+ Address 2 / + Address 3	progressive, billing and shipping	reveals the next street line
Same as Billing Address	the programme ships	copies billing down and recalculates
Online Payment	the billing country allows cards	Stripe — changes the submit label to Continue to Checkout
Wire Transfer	the country allows it	adds a USD 50 fee
ACH	the country allows it	adds a USD 50 fee
Privacy Notice · Code of Conduct · Limitation of Liability · Waiver and Release	policy attestations	garp.org, new tab
Register / Pay and Register / Continue to Checkout / Submit Order / Pay / Checkout	one label, chosen by payment type and cart	verify —  address —  register —  pay, then checkout or page two
Cancel	checkout flow only	nothing — an empty stub
Dialog	Opened by	Its buttons
Account Already Exists	entering an email that matches a customer	Please Login to continue only — the dialog cannot be dismissed
Port gap. The remove-item control on a fee row can never render — its guard returns false outright and its handler is empty. Several error paths are marked // TODO: Show error modal and only set an inline message.

/registration/micro/:courseCode
Micro Course Registration · MicroFormComponent
Gaps
/registration/survey · /registration/information
You are registered / Checkout Complete · SurveyFormComponent
Ported
Page two — the demographics survey. Two paths, one component. Entirely optional: there is no validation and a Skip button goes straight past it. Auto-skips when the cart already carries a done-route.

Label	Shown when	Goes to
Submit / Submitting…	always	saves the profile, then /registration/completed
Skip	always	/registration/completed — no prompt
Add new organization / Add new school	what was typed matches nothing	accepts the typed value
/registration/completed
Thank you! / Order Submitted · CompletedFormComponent
Gaps
Page three. Which of the four sections shows — exams, events, membership or checkout — depends on the registration type, and within each, on whether the member paid by card and whether they were signed in.

Label	Shown when	Goes to
Click here	an invoice is outstanding	/garpapp/purchase-history
Continue to My Programs	an exam or course registration, signed in	/garpapp/programs/{type}
Add to Calendar	an event, not on-demand	a third-party calendar widget
Continue to My Events	an event, signed in	/garpapp/events
View On-Demand	the event is on-demand	the ON24 URL
Continue to GARP content	membership bought behind a paywall	the gated URL from the cookie
Continue / Continue to Dashboard	checkout	the cart's done-route, or /garpapp
Port gap. Every navigation on this page is prefixed /garpapp/…, and none of those paths exist in the router. They all fall through the wildcard to the dashboard — so “Continue to My Programs” silently lands on the wrong page.

Not a route
(no route — cookie-driven)
GARP Content · GatedContentComponent
Ported
Rendered by the app shell instead of the router whenever a garp_gated_url cookie is present, replacing the entire content area — nav, alert bar and router outlet all suppressed. It checks membership, then redirects to the gated URL after exactly two seconds.

Label	Shown when	Goes to
My Account	membership not in good standing	/my-account after clearing the cookie
Click here (continue)	membership valid	the gated URL — also fires automatically after 2s
click here (renew/upgrade)	membership not in good standing	external · sfdcApp with track_cta and the gated URL
Where the portal hands off
Every destination outside garpapp. These are the seams a React port has to decide about one by one — each is either something to rebuild, or a link to keep pointing at the old app.

URL shape	Reached from	How
/sfdcApp#!/registration/{type}	Every Register button on program detail and the programs list	document.location.href — full page
/sfdcApp?track_cta={cta}#!/registration/membership	Membership upsells, My Account upgrade/renew, directory upsell	full page, with a tracking tag
/Login?start=registration/{frm|scr|rai}	The dashboard advertisement card	full page — a third registration URL shape
/Login?start=registration/membership	The benefit dialog's Upgrade/Renew	window.open(_self) — a fourth shape
/Login?start=checkout/{productCode}/	Study-material Purchase, and the GARP Learning add-on	full page — all SPA state is lost
/Login?start=myprograms/certcheckout/{type}	Request Copy of Certificate (FRM and ERP)	full page
/Login?start=chapterMeetingRegistrationsAttendance/{eventId}	Manage Attendance on the Events page	full page
/gbiapp · /garpEPPPortal	The GBI and EPP dashboard cards	full page
garp.org/…	Top nav, footer, Learn More, event names, errata PDFs	mostly new tab
Exam provider (PSI / Pearson / ATA) SSO	Take Exam, and the provider name once scheduled	new tab, signed URL
eBook vendor reader	Access, on study materials and the archive	new tab, short-lived signed URL
Four different URL shapes reach the same registration flow. /sfdcApp#!/registration/…, the same with a track_cta query, /Login?start=registration/…, and a window.open(_self) variant of the last. They are not interchangeable — the track_cta ones carry attribution the others drop.

Riskai is spelled two ways. The route slug is riskai, but every registration and marketing link rewrites it to rai. The errata service, meanwhile, matches on RISKAI. Getting this wrong is silent — the link just 404s.