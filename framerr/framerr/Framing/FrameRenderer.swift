import CoreGraphics
import SwiftUI

/// Draws a photo onto its framed sRGB canvas at the post's exact pixel size.
nonisolated enum FrameRenderer {
    static func render(_ image: CGImage, settings: FrameSettings) -> CGImage? {
        let canvas = settings.ratio.canvasSize
        guard
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let context = CGContext(
                data: nil,
                width: Int(canvas.width),
                height: Int(canvas.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )
        else { return nil }

        context.interpolationQuality = .high
        context.setFillColor(settings.color.cgColor)
        context.fill(CGRect(origin: .zero, size: canvas))

        let imageSize = CGSize(width: image.width, height: image.height)
        // The rect is centered, so Core Graphics' flipped y-axis doesn't change the result.
        context.draw(image, in: FrameLayout.imageRect(imageSize: imageSize, canvas: canvas, settings: settings))
        return context.makeImage()
    }
}
