import { existsSync, readFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { describe, expect, it } from "vitest"

/**
 * The banner artwork has to ship PRE-CROPPED, and this is the only place that
 * can catch it if it does not.
 *
 * Each 2027 frame composites its art at a different vertical offset inside a
 * 1440×166 window (FRM 46/906, SCR 88/906, RAI 101/933), so what the design
 * shows is a narrow band near the top of a much taller image — which is where
 * every one of these gradients keeps its colour bloom. Hand the component a
 * full-height source instead and `object-cover` centres on the flat middle:
 * the bloom disappears, nothing throws, and the banner just looks duller than
 * the design. That shipped on FRM once and was caught by eye, not by a test.
 *
 * A correctly cropped asset is the banner's own aspect ratio, 1440/166 =
 * 8.675. Anything else is wrong, and the failure message says which file.
 */
const BANNER_ASPECT = 1440 / 166

const BANNERS = ["frm", "scr", "rai"] as const

const CHROME_DIR = "src/assets/brand/programs/chrome"

/**
 * The chrome asset directory on disk.
 *
 * Walks up from the working directory rather than using `import.meta.url`:
 * Vite rewrites that to a served URL during transform, so it resolves to
 * `/src/assets/…` and every read fails with ENOENT. Walking up also means the
 * test does not care which directory vitest was invoked from.
 */
function chromeDir(): string {
	let dir = process.cwd()
	for (;;) {
		const candidate = resolve(dir, CHROME_DIR)
		if (existsSync(candidate)) return candidate
		const parent = dirname(dir)
		if (parent === dir) throw new Error(`could not locate ${CHROME_DIR}`)
		dir = parent
	}
}

const bannerPath = (slug: string) => resolve(chromeDir(), `${slug}-banner.jpg`)

/** Width/height from a JPEG's SOFn frame header. */
function jpegSize(bytes: Buffer): { width: number; height: number } {
	let offset = 2 // skip SOI
	while (offset < bytes.length) {
		if (bytes[offset] !== 0xff) {
			offset += 1
			continue
		}
		const marker = bytes[offset + 1]
		// SOFn carries the dimensions — except DHT (c4), JPG (c8) and DAC (cc).
		const isFrameHeader =
			marker >= 0xc0 &&
			marker <= 0xcf &&
			marker !== 0xc4 &&
			marker !== 0xc8 &&
			marker !== 0xcc
		if (isFrameHeader) {
			return {
				height: bytes.readUInt16BE(offset + 5),
				width: bytes.readUInt16BE(offset + 7),
			}
		}
		offset += 2 + bytes.readUInt16BE(offset + 2)
	}
	throw new Error("no JPEG frame header found")
}

describe("guest chrome banner artwork", () => {
	it.each(BANNERS)("%s's banner is cropped to the banner's aspect", (slug) => {
		const { width, height } = jpegSize(readFileSync(bannerPath(slug)))
		const aspect = width / height

		expect(
			Math.abs(aspect - BANNER_ASPECT),
			`${slug}-banner.jpg is ${width}x${height} (aspect ${aspect.toFixed(3)}), ` +
				`expected ~${BANNER_ASPECT.toFixed(3)}. An uncropped source makes ` +
				`object-cover centre on the flat middle of the gradient and silently ` +
				`drop the colour bloom the design has.`,
		).toBeLessThan(0.05)
	})

	/*
	 * A generous ceiling, not a budget: the uncropped sources were 736KB–1.1MB,
	 * so anything near that means a raw export was committed by mistake.
	 */
	it.each(BANNERS)("%s's banner is a cropped export, not the raw source", (slug) => {
		expect(readFileSync(bannerPath(slug)).byteLength).toBeLessThan(200_000)
	})
})
