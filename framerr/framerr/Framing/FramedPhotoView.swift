import SwiftUI

/// On-screen version of the exported image, laid out with the same `FrameLayout` math.
struct FramedPhotoView: View {
    let image: CGImage
    let settings: FrameSettings

    var body: some View {
        let canvas = settings.ratio.canvasSize
        let rect = FrameLayout.imageRect(
            imageSize: CGSize(width: image.width, height: image.height),
            canvas: canvas,
            settings: settings
        )

        Color(settings.color)
            .aspectRatio(canvas.width / canvas.height, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                GeometryReader { proxy in
                    let scale = proxy.size.width / canvas.width
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .frame(width: rect.width * scale, height: rect.height * scale)
                        .offset(x: rect.minX * scale, y: rect.minY * scale)
                }
            }
    }
}
