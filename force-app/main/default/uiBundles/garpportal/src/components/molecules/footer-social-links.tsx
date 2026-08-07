import { useRef } from "react"

import {
	FacebookIcon,
	InstagramIcon,
	LinkedinIcon,
	WeChatIcon,
	WeiboIcon,
	XIcon,
	XiaohongshuIcon,
	YoutubeIcon,
} from "@/components/atoms/social-icons"
import type { SocialLink } from "@/lib/navigation/types"

const SOCIAL_ICONS = {
	WeChat: WeChatIcon,
	Facebook: FacebookIcon,
	X: XIcon,
	LinkedIn: LinkedinIcon,
	Xiaohongshu: XiaohongshuIcon,
	Instagram: InstagramIcon,
	Weibo: WeiboIcon,
	YouTube: YoutubeIcon,
} as const

const iconLinkClassName =
	"inline-flex items-center justify-center text-foreground transition-transform duration-[250ms] hover:-translate-y-1"

function SocialQrButton({ link }: { link: SocialLink & { kind: "qr" } }) {
	const dialogRef = useRef<HTMLDialogElement>(null)
	const Icon = SOCIAL_ICONS[link.name as keyof typeof SOCIAL_ICONS]

	return (
		<>
			<button
				type="button"
				aria-label={link.name}
				onClick={() => dialogRef.current?.showModal()}
				className={iconLinkClassName}
			>
				<Icon className="size-[26px]" />
			</button>
			<dialog
				ref={dialogRef}
				onClick={() => dialogRef.current?.close()}
				className="fixed top-1/2 left-1/2 w-[300px] max-w-full -translate-x-1/2 -translate-y-1/2 rounded-lg border p-4 backdrop:bg-foreground/50"
			>
				<img src={link.qrImageUrl} alt={link.qrAlt} className="max-w-full" />
			</dialog>
		</>
	)
}

function FooterSocialLinks({ links }: { links: SocialLink[] }) {
	return (
		<div className="grid grid-cols-4 gap-x-2.5 gap-y-3.5 border-y-2 border-[#DFEAEA] px-2.5 pt-3 pb-1.5 text-center lg:border-b-0">
			{links.map((link) => {
				if (link.kind === "qr") {
					return <SocialQrButton key={link.name} link={link} />
				}

				const Icon = SOCIAL_ICONS[link.name as keyof typeof SOCIAL_ICONS]
				return (
					<a
						key={link.name}
						href={link.url}
						target="_blank"
						rel="noopener noreferrer"
						aria-label={link.name}
						className={iconLinkClassName}
					>
						<Icon className="size-[26px]" />
					</a>
				)
			})}
		</div>
	)
}

export { FooterSocialLinks }
