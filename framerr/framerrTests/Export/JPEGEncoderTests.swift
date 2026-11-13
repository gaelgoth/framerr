import CoreGraphics
import Foundation
import Testing
@testable import framerr

struct JPEGEncoderTests {
    @Test func simpleImageUsesHighestQuality() throws {
        let image = try TestImages.image(1080, 1350)
        let data = try #require(JPEGEncoder.data(for: image))
        #expect(data == JPEGEncoder.encode(image, quality: JPEGEncoder.qualities[0]))
    }

    @Test func detailedImageStaysWithinBudgetOrUsesLowestQuality() throws {
        let image = try noise(width: 1080, height: 1350)
        let data = try #require(JPEGEncoder.data(for: image))
        #expect(try data.count <= JPEGEncoder.maxFileBytes || data == JPEGEncoder.encode(
            image,
            quality: #require(JPEGEncoder.qualities.last)
        ))
        #expect(try data.count < #require(JPEGEncoder.encode(image, quality: JPEGEncoder.qualities[0])).count)
    }

    private func noise(width: Int, height: Int) throws -> CGImage {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0 ..< (width * height * 4)).map { _ in UInt8.random(in: 0 ... 255, using: &generator) }
        let provider = try #require(CGDataProvider(data: Data(bytes) as CFData))
        return try #require(CGImage(
            width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent
        ))
    }
}
