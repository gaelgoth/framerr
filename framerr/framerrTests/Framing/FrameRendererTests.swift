import CoreGraphics
import SwiftUI
import Testing
@testable import framerr

struct FrameRendererTests {
    private let white = [255, 255, 255]
    private let red = [255, 0, 0]

    @Test func rendersBorderAroundPhotoAtPostSize() throws {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 10, fillGap: .off)
        let output = try #require(try FrameRenderer.render(TestImages.image(1500, 1000), settings: settings))

        #expect(output.width == 1080)
        #expect(output.height == 1350)
        #expect(TestImages.isClose(TestImages.pixel(output, x: 5, y: 5), to: white))
        #expect(TestImages.isClose(TestImages.pixel(output, x: 50, y: 675), to: white), "side border")
        #expect(TestImages.isClose(TestImages.pixel(output, x: 540, y: 200), to: white), "top gap")
        #expect(TestImages.isClose(TestImages.pixel(output, x: 540, y: 675), to: red))
    }

    @Test func fillingTheGapTouchesSideEdges() throws {
        let settings = FrameSettings(ratio: .portrait, borderPercent: 10, fillGap: .horizontal)
        let output = try #require(try FrameRenderer.render(TestImages.image(1500, 1000), settings: settings))

        #expect(TestImages.isClose(TestImages.pixel(output, x: 1, y: 675), to: red))
        #expect(TestImages.isClose(TestImages.pixel(output, x: 1078, y: 675), to: red))
        #expect(TestImages.isClose(TestImages.pixel(output, x: 540, y: 300), to: white))
        #expect(TestImages.isClose(TestImages.pixel(output, x: 540, y: 1050), to: white))
    }

    @Test func usesBorderColor() throws {
        let settings = FrameSettings(ratio: .square, borderPercent: 5, color: Color.Resolved(red: 0, green: 0, blue: 0))
        let output = try #require(try FrameRenderer.render(TestImages.image(500, 500), settings: settings))

        #expect(output.width == 1080 && output.height == 1080)
        #expect(TestImages.isClose(TestImages.pixel(output, x: 10, y: 10), to: [0, 0, 0]))
    }
}
