import CoreGraphics
import Foundation

/// Renders every photo with its frame and writes numbered JPEGs into a folder.
nonisolated enum PhotoExporter {
    enum ExportError: LocalizedError {
        case unreadable(String)
        case encodingFailed(String)

        var errorDescription: String? {
            switch self {
            case let .unreadable(name): String(localized: "Couldn't read “\(name)”. Was the original file moved?")
            case let .encodingFailed(name): String(localized: "Couldn't create the JPEG for “\(name)”.")
            }
        }
    }

    /// Export file names that already exist in `folder`.
    static func conflictingFiles(for photos: [Photo], in folder: URL) -> [String] {
        let isScoped = folder.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                folder.stopAccessingSecurityScopedResource()
            }
        }

        return ExportNaming.fileNames(for: photos.map(\.name)).filter {
            FileManager.default.fileExists(atPath: folder.appending(path: $0).path(percentEncoded: false))
        }
    }

    /// Writes the photos in order, replacing files with the same names.
    @concurrent
    static func export(_ photos: [Photo], settings: FrameSettings, to folder: URL) async throws -> [URL] {
        let isScoped = folder.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                folder.stopAccessingSecurityScopedResource()
            }
        }

        let canvas = settings.ratio.canvasSize
        let fileNames = ExportNaming.fileNames(for: photos.map(\.name))
        var urls: [URL] = []

        for (photo, fileName) in zip(photos, fileNames) {
            try Task.checkCancellation()

            // Decode at the size it will be drawn so ImageIO does the high-quality downsampling.
            let rect = FrameLayout.imageRect(imageSize: photo.pixelSize, canvas: canvas, settings: settings)
            guard
                let image = PhotoLoader.image(at: photo.url, maxPixelSize: Int(max(rect.width, rect.height))),
                let framed = FrameRenderer.render(image, settings: settings)
            else { throw ExportError.unreadable(photo.url.lastPathComponent) }

            guard let data = JPEGEncoder.data(for: framed) else {
                throw ExportError.encodingFailed(photo.url.lastPathComponent)
            }

            let url = folder.appending(path: fileName)
            try data.write(to: url, options: .atomic)
            urls.append(url)
        }
        return urls
    }
}
