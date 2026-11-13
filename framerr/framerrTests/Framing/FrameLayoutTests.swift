import CoreGraphics
import Testing
@testable import framerr

struct FrameLayoutTests {
    private let canvas = AspectRatio.portrait.canvasSize
    private let landscape = CGSize(width: 1500, height: 1000)
    private let portrait = CGSize(width: 800, height: 1000)

    @Test func landscapeFillingTheGapUsesFullWidthWithBorderOnlyTopAndBottom() {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 5, fillGap: .all)
        let rect = FrameLayout.imageRect(imageSize: landscape, canvas: canvas, settings: settings)
        #expect(rect == CGRect(x: 0, y: 315, width: 1080, height: 720))
    }

    @Test func landscapeWithoutFillGetsBorderOnEverySide() {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 5, fillGap: .off)
        let rect = FrameLayout.imageRect(imageSize: landscape, canvas: canvas, settings: settings)
        #expect(rect == CGRect(x: 54, y: 351, width: 972, height: 648))
    }

    @Test func portraitWithoutFillHasUniformSideBorderAndAtLeastAsMuchTopBorder() {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 5, fillGap: .off)
        let rect = FrameLayout.imageRect(imageSize: portrait, canvas: canvas, settings: settings)
        #expect(rect.minX == 54)
        #expect(canvas.width - rect.maxX == 54)
        #expect(rect.minY >= 54)
        #expect(abs(rect.minY - (canvas.height - rect.maxY)) <= 1)
    }

    @Test func matchingPhotoFillingTheGapCoversTheWholeCanvas() {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 10, fillGap: .all)
        let rect = FrameLayout.imageRect(imageSize: portrait, canvas: canvas, settings: settings)
        #expect(rect == CGRect(origin: .zero, size: canvas))
    }

    @Test func horizontalModeFillsOnlyLandscapePhotos() {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 5, fillGap: .horizontal)
        #expect(FrameLayout.imageRect(imageSize: landscape, canvas: canvas, settings: settings).width == 1080)
        #expect(FrameLayout.imageRect(imageSize: portrait, canvas: canvas, settings: settings).minX == 54)
    }

    @Test func verticalModeFillsOnlyPortraitPhotos() {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 5, fillGap: .vertical)
        #expect(FrameLayout.imageRect(imageSize: portrait, canvas: canvas, settings: settings) == CGRect(origin: .zero, size: canvas))
        #expect(FrameLayout.imageRect(imageSize: landscape, canvas: canvas, settings: settings).minX == 54)
    }

    @Test(arguments: [(FillGapMode.off, false), (.horizontal, false), (.vertical, false), (.all, true)])
    func squarePhotoFillsOnlyWithAll(mode: FillGapMode, fills: Bool) {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 5, fillGap: mode)
        let rect = FrameLayout.imageRect(imageSize: CGSize(width: 900, height: 900), canvas: canvas, settings: settings)
        #expect((rect.minX == 0) == fills)
    }

    @Test func emptyImageGivesEmptyRect() {
        #expect(FrameLayout.imageRect(imageSize: .zero, canvas: canvas, settings: FrameSettings()) == .zero)
    }
}
