import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Encodes JPEGs that upload platforms keep close to as-is: highest quality that fits the size budget.
nonisolated enum JPEGEncoder {
    // shortcut: fixed ~1 MB budget from common upload advice; make it a setting if users want to tune it.
    static let maxFileBytes = 1_000_000
    static let qualities = [0.95, 0.9, 0.85, 0.8, 0.75]

    static func data(for image: CGImage) -> Data? {
        var smallest: Data?
        for quality in qualities {
            guard let data = encode(image, quality: quality) else { return nil }
            if data.count <= maxFileBytes {
                return data
            }
            smallest = data
        }
        return smallest
    }

    static func encode(_ image: CGImage, quality: Double) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
            return nil
        }
        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, image, options)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }
}
