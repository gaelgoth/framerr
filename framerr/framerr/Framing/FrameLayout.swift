import CoreGraphics
import Foundation

/// Where a photo sits on the canvas. Shared by the on-screen preview and the exporter so both match.
nonisolated enum FrameLayout {
    static func imageRect(imageSize: CGSize, canvas: CGSize, settings: FrameSettings) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let border = settings.fillGap.applies(to: imageSize) ? 0 : (canvas.width * settings.borderPercent / 100).rounded()
        let area = CGRect(origin: .zero, size: canvas).insetBy(dx: border, dy: border)
        let scale = min(area.width / imageSize.width, area.height / imageSize.height)
        let width = (imageSize.width * scale).rounded()
        let height = (imageSize.height * scale).rounded()

        return CGRect(
            x: ((canvas.width - width) / 2).rounded(),
            y: ((canvas.height - height) / 2).rounded(),
            width: width,
            height: height
        )
    }
}
