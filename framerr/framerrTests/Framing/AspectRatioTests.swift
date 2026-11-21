import CoreGraphics
import Testing
@testable import framerr

struct AspectRatioTests {
    @Test(arguments: [
        (AspectRatio.square, 1080.0, 1080.0),
        (.portrait, 1080, 1350),
        (.landscape, 1080, 566),
        (.landscapeFiveFour, 1080, 864),
        (.story, 1080, 1920),
    ])
    func canvasMatchesPostSize(ratio: AspectRatio, width: Double, height: Double) {
        #expect(ratio.canvasSize == CGSize(width: width, height: height))
    }
}
