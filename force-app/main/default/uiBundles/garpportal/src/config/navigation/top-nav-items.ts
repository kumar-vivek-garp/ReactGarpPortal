import { Building2, Cpu, Leaf, Newspaper, TrendingUp, Users } from "lucide-react"

import type { TopNavItem } from "./types"

/**
 * Mirrors the live garpApp mega-menu data (`nav-items-list.ts`, extracted from
 * production's own sourcemap) so labels and destination URLs stay 1:1 with
 * https://my.garp.org/garpapp — do not invent or reorder entries here.
 */
export const TOP_NAV_ITEMS: TopNavItem[] = [
	{
		title: "FRM",
		accentToken: "garp-cyan",
		icon: TrendingUp,
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
				{ title: "Program and Exams", url: "https://www.garp.org/frm/program-exams" },
				{ title: "Fees and Payments", url: "https://www.garp.org/frm/fees-payments" },
				{ title: "Exam Logistics", url: "https://www.garp.org/frm/exam-logistics" },
				{ title: "Exam Policies", url: "https://www.garp.org/frm/exam-policies" },
			],
		},
		column2: {
			header: "FRM Resources",
			links: [
				{ title: "Study Materials", url: "https://www.garp.org/frm/study-materials" },
				{ title: "FAQs", url: "https://www.garp.org/frm/frequently-asked-questions" },
				{ title: "Continuing Professional Development (CPD)", url: "https://www.garp.org/cpd" },
			],
		},
	},
	{
		title: "SCR",
		accentToken: "garp-saffron",
		icon: Leaf,
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
				{ title: "Program and Exam", url: "https://www.garp.org/scr/program-exam" },
				{ title: "Fees and Payments", url: "https://www.garp.org/scr/fees-payments" },
				{ title: "Exam Logistics", url: "https://www.garp.org/scr/exam-logistics" },
				{ title: "Exam Policies", url: "https://www.garp.org/scr/exam-policies" },
			],
		},
		column2: {
			header: "SCR Resources",
			links: [
				{ title: "Study Materials", url: "https://www.garp.org/scr/study-materials" },
				{ title: "FAQs", url: "https://www.garp.org/scr/frequently-asked-questions" },
				{ title: "Continuing Professional Development (CPD)", url: "https://www.garp.org/cpd" },
			],
		},
	},
	{
		title: "Risk & AI",
		accentToken: "rai-orange",
		icon: Cpu,
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
				{ title: "Program and Exam", url: "https://www.garp.org/rai/program-exam" },
				{ title: "Fees and Payments", url: "https://www.garp.org/rai/fees-payments" },
				{ title: "Exam Logistics", url: "https://www.garp.org/rai/exam-logistics" },
				{ title: "Exam Policies", url: "https://www.garp.org/rai/exam-policies" },
			],
		},
		column2: {
			header: "RAI Resources",
			links: [
				{ title: "Study Materials", url: "https://www.garp.org/rai/study-materials" },
				{ title: "FAQs", url: "https://www.garp.org/rai/frequently-asked-questions" },
				{ title: "Continuing Professional Development (CPD)", url: "https://www.garp.org/cpd" },
			],
		},
	},
	{
		title: "Membership",
		accentToken: "deep-purple",
		icon: Users,
		column1: {
			header: "Membership",
			links: [
				{ title: "Overview", url: "https://www.garp.org/membership" },
				{ title: "Professional Chapters", url: "https://www.garp.org/membership/professional-chapters" },
				{ title: "Volunteer Opportunities", url: "https://www.garp.org/membership/volunteer" },
				{
					title: "Certification/Certificate Holder Directory",
					url: "https://www.garp.org/certificate-holder-directory",
				},
			],
		},
		column2: {
			header: "Professional Development",
			links: [{ title: "Risk Career Center", url: "https://www.garp.org/membership/risk-career-center" }],
		},
	},
	{
		/*
		 * Re-synced from the live www.garp.org nav (read off the rendered menu, not
		 * inferred): three columns collapsed to two, and "Risk Intelligence" was
		 * rebranded to the Risk Insights hub. The old Articles/Podcasts entries
		 * pointed at chapter-meeting and webcast listings rather than at content.
		 */
		title: "Insights & Events",
		accentToken: "bright-purple",
		icon: Newspaper,
		column1: {
			header: "Content",
			links: [
				{ title: "Latest Insights", url: "https://www.garp.org/risk-insights" },
				{ title: "Articles", url: "https://www.garp.org/risk-insights-resources?types=article" },
				{ title: "Podcasts", url: "https://www.garp.org/risk-insights-resources?types=podcast" },
				{
					title: "Research and Reports",
					url: "https://www.garp.org/risk-insights-resources?types=research%2Cwhite_paper",
				},
			],
		},
		column2: {
			header: "Events",
			links: [
				{ title: "Upcoming Events", url: "https://www.garp.org/events" },
				{
					title: "Financial Risk Symposium",
					url: "https://www.garp.org/event/2026-financial-risk-symposium",
				},
				{
					title: "Climate and Nature Risk Symposium",
					url: "https://www.garp.org/event/2026-climate-nature-symposium",
				},
			],
		},
	},
	{
		title: "About Us",
		accentToken: "dark-blue-gray",
		icon: Building2,
		column1: {
			header: "About Us",
			links: [
				{ title: "About GARP", url: "https://www.garp.org/about" },
				{ title: "Board of Trustees", url: "https://www.garp.org/about/board-of-trustees" },
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
				{
					// Lives under Industry Engagement on live, not About Us — and the
					// old entry pointed at the sustainability hub, not the institute.
					title: "GARP Risk Institute",
					url: "https://www.garp.org/garp-risk-institute",
					openInNewTab: true,
				},
			],
		},
	},
]
