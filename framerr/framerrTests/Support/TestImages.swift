import CoreGraphics
import Foundation
import ImageIO
import Testing
@testable import framerr

/// Real files on disk and pixel inspection for integration tests.
enum TestImages {
    static let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
    static let green = CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
    static let blue = CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)

    static func makeFolder() throws -> URL {
        let folder = FileManager.default.temporaryDirectory.appending(path: "framerr-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func writeJPEG(_ name: String, width: Int, height: Int, color: CGColor = red, in folder: URL) throws -> URL {
        try #require(UITestingSupport.writeSampleJPEG(named: name, width: width, height: height, color: color, in: folder))
    }

    static func image(_ width: Int, _ height: Int, color: CGColor = red) throws -> CGImage {
        try #require(UITestingSupport.makeSampleImage(width: width, height: height, color: color))
    }

    static func load(_ url: URL) throws -> CGImage {
        let source = try #require(CGImageSourceCreateWithURL(url as CFURL, nil))
        return try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
    }

    /// RGB components (0–255) at a pixel, with the origin at the top-left.
    static func pixel(_ image: CGImage, x: Int, y: Int) -> [Int] {
        var buffer = [UInt8](repeating: 0, count: 4)
        buffer.withUnsafeMutableBytes { bytes in
            let context = CGContext(
                data: bytes.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )
            // Shift the image so the wanted pixel lands on the 1×1 context.
            context?.draw(image, in: CGRect(x: -x, y: y - image.height + 1, width: image.width, height: image.height))
        }
        return buffer.prefix(3).map(Int.init)
    }

    static func isClose(_ pixel: [Int], to expected: [Int], tolerance: Int = 8) -> Bool {
        zip(pixel, expected).allSatisfy { abs($0 - $1) <= tolerance }
    }
}
