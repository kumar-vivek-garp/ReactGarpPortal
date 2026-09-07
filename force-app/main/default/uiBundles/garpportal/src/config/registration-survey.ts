/**
 * Copy for the post-registration "Complete Your Profile" survey. Static, so
 * the form file holds only behaviour.
 *
 * The framing is deliberate: the survey is optional and GarpAppv1 simply says
 * so, but "optional" on its own reads as "skip me". So the header sells what
 * the answers buy the candidate, the progress ring rewards each answer, and
 * Skip is offered as a deferral ("for now") rather than a way out.
 */
export const REGISTRATION_SURVEY_COPY = {
	/** `{program}` is the programme's short name — "FRM", "SCR". */
	title: "Help us tailor your {program} journey",
	titleFallback: "Help us tailor your GARP journey",
	intro: "Three short steps, about a minute — and everything you share shapes what we send you next.",
	benefits: [
		{
			title: "Study resources that fit",
			description: "Materials and practice matched to your level and background.",
		},
		{
			title: "Events near you",
			description: "Chapter meetings, webcasts and networking for your industry.",
		},
		{
			title: "Insights for your role",
			description: "Career and salary insights from risk professionals like you.",
		},
	],
	/** `{answered}` / `{total}` are substituted live. */
	progress: "{answered} of {total} answered",
	progressLabel: "Survey progress",
	/** `{step}` / `{count}` are substituted live. */
	stepLabel: "Step {step} of {count}",
	steps: {
		work: "Your work",
		experience: "Your experience",
		education: "Your education",
	},
	back: "Back",
	next: "Next",
	footnote: "Nothing here is required. You can update any of it later on My Account.",
	skip: "Skip for now",
	submit: "Save my answers",
	saving: "Saving…",
	saved: "Thanks — your profile is updated.",
	/** Nothing to write to — a guest with no key, or a session with no member record. */
	unavailableTitle: "Your registration is confirmed",
	unavailableMessage:
		"You can fill these details in any time on My Account under Career Information.",
	continue: "Continue",
} as const

export const REGISTRATION_SURVEY_LABELS = {
	workingStatus: "What is your work status?",
	industry: "What industry do/did you specialise in?",
	industryWorkingYear: "What year did you start working in the industry?",
	company: "What is your most recent company?",
	corporateTitle: "What is your professional level?",
	jobFunction: "What is your job function?",
	riskSpecialty: "What is your risk specialty?",
	riskManagementWorkingYear: "What year did you start working in risk management?",
	designations: "Do you currently hold any professional designations?",
	otherQualifications: "Other designations",
	school: "Current or most recent school attended",
	highestDegree: "Degree programme",
	graduationYear: "Year of graduation",
	graduationMonth: "Month of graduation",
} as const
