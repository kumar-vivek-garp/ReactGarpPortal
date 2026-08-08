import type { TopNavItem } from "./types"

/**
 * Mirrors the live garpApp mega-menu data (`nav-items-list.ts`, extracted from
 * production's own sourcemap) so labels and destination URLs stay 1:1 with
 * https://my.garp.org/garpapp — do not invent or reorder entries here.
 */
export const TOP_NAV_ITEMS: TopNavItem[] = [
	{
		title: "FRM",
		heading: {
			prefix: "Financial Risk Manager (",
			highlight: "FRM",
			highlightToken: "garp-cyan",
			symbol: "®",
			suffix: ") Certification",
		},
		column1: {
			header: "FRM Certification",
			headerURL: "https://www.garp.org/frm",
			links: [
				{ title: "Overview", url: "https://www.garp.org/frm" },
				{ title: "Programs and Exams", url: "https://www.garp.org/frm/program-exams" },
				{ title: "Fees and Payments", url: "https://www.garp.org/frm/fees-payments" },
				{ title: "Exams Logistics", url: "https://www.garp.org/frm/exam-logistics" },
				{ title: "Exams Policies", url: "https://www.garp.org/frm/exam-policies" },
			],
		},
		column2: {
			header: "FRM Resources",
			links: [
				{ title: "Study Materials", url: "https://www.garp.org/frm/study-materials" },
				{ title: "FAQs", url: "https://www.garp.org/frm/frequently-asked-questions" },
				{ title: "Continuing Professional Development", url: "https://www.garp.org/cpd" },
			],
		},
	},
	{
		title: "SCR",
		heading: {
			prefix: "Sustainability and Climate Risk (",
			highlight: "SCR",
			highlightToken: "garp-saffron",
			symbol: "®",
			suffix: ") Certificate",
		},
		column1: {
			header: "SCR Certificate",
			headerURL: "https://www.garp.org/scr",
			links: [
				{ title: "Overview", url: "https://www.garp.org/scr" },
				{ title: "Programs and Exams", url: "https://www.garp.org/scr/program-exam" },
				{ title: "Fees and Payments", url: "https://www.garp.org/scr/fees-payments" },
				{ title: "Exams Logistics", url: "https://www.garp.org/scr/exam-logistics" },
				{ title: "Exams Policies", url: "https://www.garp.org/scr/exam-policies" },
			],
		},
		column2: {
			header: "SCR Resources",
			links: [
				{ title: "Study Materials", url: "https://www.garp.org/scr/study-materials" },
				{ title: "FAQs", url: "https://www.garp.org/scr/frequently-asked-questions" },
				{ title: "Continuing Professional Development", url: "https://www.garp.org/cpd" },
			],
		},
	},
	{
		title: "Risk & AI",
		heading: {
			prefix: "Risk and AI (",
			highlight: "RAI",
			highlightToken: "rai-split",
			symbol: "™",
			suffix: ") Certificate",
		},
		column1: {
			header: "RAI Certificate",
			headerURL: "https://www.garp.org/rai",
			links: [
				{ title: "Overview", url: "https://www.garp.org/rai" },
				{ title: "Programs and Exams", url: "https://www.garp.org/rai/program-exam" },
				{ title: "Fees and Payments", url: "https://www.garp.org/rai/fees-payments" },
				{ title: "Exams Logistics", url: "https://www.garp.org/rai/exam-logistics" },
				{ title: "Exams Policies", url: "https://www.garp.org/rai/exam-policies" },
			],
		},
		column2: {
			header: "RAI Resources",
			links: [
				{ title: "Study Materials", url: "https://www.garp.org/rai/study-materials" },
				{ title: "FAQs", url: "https://www.garp.org/rai/frequently-asked-questions" },
				{ title: "Continuing Professional Development", url: "https://www.garp.org/cpd" },
			],
		},
	},
	{
		title: "Membership",
		column1: {
			header: "Membership",
			links: [
				{ title: "Overview", url: "https://www.garp.org/membership" },
				{ title: "Professional Chapters", url: "https://www.garp.org/membership/professional-chapters" },
				{ title: "Volunteer Opportunities", url: "https://www.garp.org/membership/volunteer" },
				{ title: "Directory", url: "https://my.garp.org/sfdcApp#!/public_directory" },
			],
		},
		column2: {
			header: "Professional Development",
			links: [{ title: "Risk Career Center", url: "https://www.garp.org/membership/risk-career-center" }],
		},
	},
	{
		title: "Insights & Events",
		column1: {
			header: "Risk Insights",
			links: [
				{ title: "Financial Risk", url: "https://www.garp.org/financial-risk" },
				{ title: "Sustainability and Climate", url: "https://www.garp.org/sustainability-climate-risk" },
				{ title: "Risk and Artificial Intelligence", url: "https://www.garp.org/artificial-intelligence-risk" },
			],
		},
		column2: {
			header: "Content Type",
			links: [
				{ title: "Articles", url: "https://www.garp.org/events/all?type=chapter_meeting" },
				{ title: "Podcasts", url: "https://www.garp.org/webcasts" },
				{
					title: "View All",
					url: "https://www.garp.org/risk-insights-resources?types=article%2Cpodcast%2Cresource%2Cwebcast%2Cwhite_paper",
				},
			],
		},
		column3: {
			header: "Events",
			links: [
				{ title: "Chapter Meetings", url: "https://www.garp.org/events/all?type=chapter_meeting" },
				{ title: "Webcasts", url: "https://www.garp.org/webcasts" },
				{ title: "Risk Events", url: "https://www.garp.org/events" },
				{ title: "View All", url: "https://www.garp.org/events/all" },
			],
		},
	},
	{
		title: "About Us",
		column1: {
			header: "About Us",
			links: [
				{ title: "About GARP", url: "https://www.garp.org/about" },
				{ title: "Board of Trustees", url: "https://www.garp.org/about/board-of-trustees" },
				{ title: "GARP Risk Institute", url: "https://www.garp.org/sustainability-climate-risk" },
				{ title: "Press Room", url: "https://www.garp.org/about/press-room" },
				{ title: "Careers at GARP", url: "https://www.garp.org/about/careers-at-garp" },
				{ title: "Contact Us", url: "https://www.garp.org/about/contact-us" },
			],
		},
		column2: {
			header: "Industry Engagement",
			links: [
				{ title: "GARP for Students", url: "https://www.garp.org/students" },
				{ title: "University Outreach", url: "https://www.garp.org/about/university-outreach" },
				{ title: "Corporate Outreach", url: "https://www.garp.org/about/corporate-outreach" },
				{ title: "Buy Side Risk Managers Forum", url: "https://www.garp.org/about/buy-side-risk-managers-forum" },
				{
					title: "GARP Benchmarking Initiative",
					url: "https://www.garp.org/garp-benchmarking-initiative",
					openInNewTab: true,
				},
			],
		},
	},
]
