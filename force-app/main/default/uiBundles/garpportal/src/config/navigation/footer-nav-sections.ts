import type { FooterNavSection } from "./types"

/**
 * Mirrors the live garpApp footer accordion 1:1 (labels + hrefs captured directly
 * from https://my.garp.org/garpapp's rendered footer) — keep entries and order in sync
 * with production rather than reordering for local taste.
 *
 * `accentToken` is ours, not the live footer's. Three families share a hue so
 * the colour means something instead of being nine arbitrary swatches: the
 * three certifications keep their own mega-menu colours, everything to learn
 * from or attend is one purple, and the organisation itself is the neutral.
 */
export const FOOTER_NAV_SECTIONS: FooterNavSection[] = [
	{
		key: "frm",
		accentToken: "garp-cyan",
		label: "FRM",
		links: [
			{ title: "Overview", url: "https://www.garp.org/frm" },
			{ title: "Program and Exams", url: "https://www.garp.org/frm/program-exams" },
			{ title: "Fees and Payments", url: "https://www.garp.org/frm/fees-payments" },
			{ title: "Exam Logistics", url: "https://www.garp.org/frm/exam-logistics" },
			{ title: "Exam Policies", url: "https://www.garp.org/frm/exam-policies" },
			{ title: "Study Materials", url: "https://www.garp.org/frm/study-materials" },
			{ title: "FAQs", url: "https://www.garp.org/frm/frequently-asked-questions" },
			{ title: "Continuing Professional Development (CPD)", url: "https://www.garp.org/cpd" },
		],
	},
	{
		key: "scr",
		accentToken: "garp-saffron",
		label: "SCR",
		links: [
			{ title: "Overview", url: "https://www.garp.org/scr" },
			{ title: "Program and Exam", url: "https://www.garp.org/scr/program-exam" },
			{ title: "Fees and Payments", url: "https://www.garp.org/scr/fees-payments" },
			{ title: "Exam Logistics", url: "https://www.garp.org/scr/exam-logistics" },
			{ title: "Exam Policies", url: "https://www.garp.org/scr/exam-policies" },
			{ title: "Study Materials", url: "https://www.garp.org/scr/study-materials" },
			{ title: "FAQs", url: "https://www.garp.org/scr/frequently-asked-questions" },
			{ title: "Continuing Professional Development (CPD)", url: "https://www.garp.org/cpd" },
		],
	},
	{
		key: "rai",
		accentToken: "rai-orange",
		label: "RAI",
		links: [
			{ title: "Overview", url: "https://www.garp.org/rai" },
			{ title: "Program and Exam", url: "https://www.garp.org/rai/program-exam" },
			{ title: "Fees and Payments", url: "https://www.garp.org/rai/fees-payments" },
			{ title: "Exam Logistics", url: "https://www.garp.org/rai/exam-logistics" },
			{ title: "Exam Policies", url: "https://www.garp.org/rai/exam-policies" },
			{ title: "Study Materials", url: "https://www.garp.org/rai/study-materials" },
			{ title: "FAQs", url: "https://www.garp.org/rai/frequently-asked-questions" },
			{ title: "Continuing Professional Development (CPD)", url: "https://www.garp.org/cpd" },
		],
	},
	{
		key: "membership",
		accentToken: "deep-purple",
		label: "Membership",
		links: [
			{ title: "Membership Overview", url: "https://www.garp.org/membership" },
			{ title: "Professional Chapters", url: "https://www.garp.org/membership/professional-chapters" },
			{ title: "Volunteer Opportunities", url: "https://www.garp.org/membership/volunteer" },
			{ title: "Certification/Certificate Holder Directory", url: "https://www.garp.org/certificate-holder-directory" },
			{ title: "Career Center", url: "https://www.garp.org/membership/risk-career-center" },
		],
	},
	{
		key: "resources",
		accentToken: "bright-purple",
		label: "Resources",
		links: [
			{ title: "Risk Intelligence", url: "https://www.garp.org/risk-intelligence" },
			{ title: "Podcasts", url: "https://www.garp.org/podcasts" },
			{ title: "White Papers", url: "https://www.garp.org/white-papers" },
		],
	},
	{
		key: "events",
		accentToken: "bright-purple",
		label: "Events",
		links: [
			{ title: "Chapter Meetings", url: "https://www.garp.org/events/all?type=chapter_meeting" },
			{ title: "Webcasts", url: "https://www.garp.org/webcasts" },
			{ title: "Risk Events", url: "https://www.garp.org/events" },
		],
	},
	{
		key: "additional-education",
		accentToken: "bright-purple",
		label: "Additional Education",
		links: [
			{ title: "Foundations of Financial Risk (FFR)", url: "https://www.garp.org/courses/foundations-of-financial-risk" },
			{ title: "Financial Risk and Regulation (FRR)", url: "https://www.garp.org/courses/financial-risk-and-regulation" },
		],
	},
	{
		key: "about-us",
		accentToken: "dark-blue-gray",
		label: "About Us",
		links: [
			{ title: "About GARP", url: "https://www.garp.org/about" },
			{ title: "Board of Trustees", url: "https://www.garp.org/about/board-of-trustees" },
			{ title: "GARP Risk Institute", url: "https://www.garp.org/sustainability-climate-risk" },
			{ title: "Press Room", url: "https://www.garp.org/about/press-room" },
			{ title: "Careers at GARP", url: "https://www.garp.org/about/careers-at-garp" },
			{ title: "Contact Us", url: "https://www.garp.org/about/contact-us" },
		],
	},
	{
		key: "industry-engagement",
		accentToken: "dark-blue-gray",
		label: "Industry Engagement",
		links: [
			{ title: "GARP for Students", url: "https://www.garp.org/students" },
			{ title: "University Outreach", url: "https://www.garp.org/about/university-outreach" },
			{ title: "Corporate Outreach", url: "https://www.garp.org/about/corporate-outreach" },
			{ title: "Buy Side Risk Managers Forum", url: "https://www.garp.org/about/buy-side-risk-managers-forum" },
			{ title: "GARP Benchmarking Initiative", url: "https://www.garp.org/garp-benchmarking-initiative" },
		],
	},
]
