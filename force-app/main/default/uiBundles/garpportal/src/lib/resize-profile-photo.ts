/**
 * Silently downscale + center-crop profile photos before upload so Attachment
 * Body matches sidebar avatar display size (avoids Lighthouse “oversized image”).
 *
 * Uses browser Canvas / createImageBitmap — no extra dependency.
 */

export const PROFILE_PHOTO_EDGE_PX = 128
export const PROFILE_PHOTO_JPEG_QUALITY = 0.85
export const PROFILE_PHOTO_UPLOAD_NAME = "profile-photo.jpg"

export type CoverCrop = {
	sx: number
	sy: number
	size: number
}

export type ResizedProfilePhoto = {
	base64Body: string
	dataUrl: string
	fileName: string
	contentType: "image/jpeg"
	width: number
	height: number
}

/** Center-crop the largest square that fits inside `width` × `height`. */
export function coverCropSquare(width: number, height: number): CoverCrop {
	const size = Math.min(width, height)
	return {
		sx: Math.max(0, Math.floor((width - size) / 2)),
		sy: Math.max(0, Math.floor((height - size) / 2)),
		size,
	}
}

/** Output edge: at most {@link PROFILE_PHOTO_EDGE_PX}, never upscale. */
export function profilePhotoOutputEdge(sourceSquareSize: number): number {
	return Math.max(1, Math.min(PROFILE_PHOTO_EDGE_PX, Math.floor(sourceSquareSize)))
}

/**
 * Resize a JPEG/PNG `File` to a square JPEG suitable for Contact profile photos.
 */
export async function resizeProfilePhoto(file: File): Promise<ResizedProfilePhoto> {
	const bitmap = await createImageBitmap(file)
	try {
		const crop = coverCropSquare(bitmap.width, bitmap.height)
		const edge = profilePhotoOutputEdge(crop.size)

		const canvas = document.createElement("canvas")
		canvas.width = edge
		canvas.height = edge
		const ctx = canvas.getContext("2d")
		if (!ctx) {
			throw new Error("Unable to prepare the photo for upload.")
		}

		// JPEG has no alpha — flatten PNG transparency onto white.
		ctx.fillStyle = "#ffffff"
		ctx.fillRect(0, 0, edge, edge)
		ctx.drawImage(
			bitmap,
			crop.sx,
			crop.sy,
			crop.size,
			crop.size,
			0,
			0,
			edge,
			edge,
		)

		const blob = await canvasToJpegBlob(canvas, PROFILE_PHOTO_JPEG_QUALITY)
		const dataUrl = await blobToDataUrl(blob)
		const base64Body = dataUrl.includes(",")
			? (dataUrl.split(",")[1] ?? "")
			: dataUrl

		if (!base64Body) {
			throw new Error("Unable to encode the photo for upload.")
		}

		return {
			base64Body,
			dataUrl,
			fileName: PROFILE_PHOTO_UPLOAD_NAME,
			contentType: "image/jpeg",
			width: edge,
			height: edge,
		}
	} finally {
		bitmap.close()
	}
}

function canvasToJpegBlob(
	canvas: HTMLCanvasElement,
	quality: number,
): Promise<Blob> {
	return new Promise((resolve, reject) => {
		canvas.toBlob(
			(blob) => {
				if (!blob) {
					reject(new Error("Unable to encode the photo for upload."))
					return
				}
				resolve(blob)
			},
			"image/jpeg",
			quality,
		)
	})
}

function blobToDataUrl(blob: Blob): Promise<string> {
	return new Promise((resolve, reject) => {
		const reader = new FileReader()
		reader.onload = () => {
			const result = typeof reader.result === "string" ? reader.result : ""
			if (!result) {
				reject(new Error("Unable to read the encoded photo."))
				return
			}
			resolve(result)
		}
		reader.onerror = () => {
			reject(new Error("Unable to read the encoded photo."))
		}
		reader.readAsDataURL(blob)
	})
}
