import CoreGraphics
import Foundation

/// An imported photo. The original file is only read again at export time.
nonisolated struct Photo: Identifiable, Sendable {
    /// Big enough for a sharp on-screen preview, small enough to keep many photos in memory.
    static let thumbnailPixelSize = 1080

    let id = UUID()
    let url: URL
    let thumbnail: CGImage

    var name: String {
        url.deletingPathExtension().lastPathComponent
    }

    var pixelSize: CGSize {
        CGSize(width: thumbnail.width, height: thumbnail.height)
    }
}
