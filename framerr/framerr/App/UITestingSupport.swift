import CoreGraphics
import Foundation

/// UI tests can't drive the system open panel reliably. With `-ui-testing` (Debug only) the app
/// imports generated sample photos through the normal import path and exports to a temp folder.
enum UITestingSupport {
    #if DEBUG
        static let isEnabled = CommandLine.arguments.contains("-ui-testing")
    #else
        static let isEnabled = false
    #endif

    /// Fresh, empty projects folder under UI testing, so every launch starts with no saved drafts.
    static let projectsFolder: URL = isEnabled
        ? freshFolder(named: "framerr-ui-projects")
        : .applicationSupportDirectory.appending(path: "Projects")

    /// Fresh, empty export folder, or `nil` to ask the user.
    static let exportFolder: URL? = {
        guard isEnabled else { return nil }
        return freshFolder(named: "framerr-ui-export")
    }()

    private static var hasSeeded = false

    /// Seeds only the first project opened, so new projects start empty.
    static func seedIfEnabled(_ library: PhotoLibrary) async {
        guard isEnabled, !hasSeeded else { return }
        hasSeeded = true
        let folder = freshFolder(named: "framerr-ui-samples")
        // swiftlint:disable:next large_tuple
        let samples: [(String, Int, Int, CGColor)] = [
            ("Landscape", 1500, 1000, CGColor(srgbRed: 0.9, green: 0.2, blue: 0.2, alpha: 1)),
            ("Portrait", 800, 1000, CGColor(srgbRed: 0.2, green: 0.7, blue: 0.3, alpha: 1)),
            ("Square", 900, 900, CGColor(srgbRed: 0.2, green: 0.4, blue: 0.9, alpha: 1)),
        ]
        let urls = samples.compactMap { name, width, height, color in
            writeSampleJPEG(named: name, width: width, height: height, color: color, in: folder)
        }
        await library.importPhotos(from: urls)
    }

    static func makeSampleImage(width: Int, height: Int, color: CGColor) -> CGImage? {
        guard
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let context = CGContext(
                data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )
        else { return nil }
        context.setFillColor(color)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }

    static func writeSampleJPEG(named name: String, width: Int, height: Int, color: CGColor, in folder: URL) -> URL? {
        let url = folder.appending(path: "\(name).jpg")
        guard
            let image = makeSampleImage(width: width, height: height, color: color),
            let data = JPEGEncoder.encode(image, quality: 0.9),
            (try? data.write(to: url)) != nil
        else { return nil }
        return url
    }

    private static func freshFolder(named name: String) -> URL {
        let folder = FileManager.default.temporaryDirectory.appending(path: name)
        try? FileManager.default.removeItem(at: folder)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}
