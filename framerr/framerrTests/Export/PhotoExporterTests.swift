import CoreGraphics
import Foundation
import Testing
@testable import framerr

@MainActor
struct PhotoExporterTests {
    @Test func exportsNumberedFilesInCarouselOrder() async throws {
        let (library, folder) = try await makeLibrary()
        defer { try? FileManager.default.removeItem(at: folder) }
        let output = folder.appending(path: "Out")
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

        // The user reorders before exporting: Portrait first.
        library.move(library.photos[1].id, to: 0)
        let urls = try await PhotoExporter.export(library.photos, settings: FrameSettings(), to: output)

        let expected = ["01_Portrait.jpg", "02_Landscape.jpg", "03_Square.jpg"]
        #expect(urls.map(\.lastPathComponent) == expected)
        #expect(try FileManager.default.contentsOfDirectory(atPath: output.path(percentEncoded: false)).sorted() == expected)

        for url in urls {
            let image = try TestImages.load(url)
            #expect(image.width == 1080 && image.height == 1350)
            #expect(image.colorSpace?.name == CGColorSpace.sRGB)
            let size = try #require(try url.resourceValues(forKeys: [.fileSizeKey]).fileSize)
            #expect(size <= JPEGEncoder.maxFileBytes)
        }

        // 02 is the landscape photo: white border above it, red in the middle.
        let landscape = try TestImages.load(urls[1])
        #expect(TestImages.isClose(TestImages.pixel(landscape, x: 540, y: 100), to: [255, 255, 255]))
        #expect(TestImages.isClose(TestImages.pixel(landscape, x: 540, y: 675), to: [255, 0, 0], tolerance: 12))
    }

    @Test func detectsExistingFilesBeforeOverwriting() async throws {
        let (library, folder) = try await makeLibrary()
        defer { try? FileManager.default.removeItem(at: folder) }
        try Data().write(to: folder.appending(path: "02_Portrait.jpg"))

        #expect(PhotoExporter.conflictingFiles(for: library.photos, in: folder) == ["02_Portrait.jpg"])
    }

    @Test func missingOriginalFailsWithReadableError() async throws {
        let (library, folder) = try await makeLibrary()
        defer { try? FileManager.default.removeItem(at: folder) }
        try FileManager.default.removeItem(at: library.photos[0].url)

        await #expect(throws: PhotoExporter.ExportError.self) {
            try await PhotoExporter.export(library.photos, settings: FrameSettings(), to: folder)
        }
    }

    @Test func controllerAsksBeforeReplacingThenExports() async throws {
        let (library, folder) = try await makeLibrary()
        defer { try? FileManager.default.removeItem(at: folder) }
        let existing = folder.appending(path: "01_Landscape.jpg")
        try Data("old".utf8).write(to: existing)

        let controller = ExportController()
        await controller.requestExport(of: library.photos, settings: FrameSettings(), to: folder)
        #expect(controller.isConfirmingReplace)
        #expect(controller.conflicts == ["01_Landscape.jpg"])
        #expect(try Data(contentsOf: existing) == Data("old".utf8), "nothing is written before confirming")

        await controller.confirmReplace(of: library.photos, settings: FrameSettings())
        #expect(controller.isShowingResult)
        #expect(controller.exportedFiles.map(\.lastPathComponent) == ["01_Landscape.jpg", "02_Portrait.jpg", "03_Square.jpg"])
        #expect(try TestImages.load(existing).width == 1080)
    }

    @Test func controllerExportsDirectlyWithoutConflicts() async throws {
        let (library, folder) = try await makeLibrary()
        defer { try? FileManager.default.removeItem(at: folder) }
        let output = folder.appending(path: "Out")
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

        let controller = ExportController()
        await controller.requestExport(of: library.photos, settings: FrameSettings(), to: output)

        #expect(!controller.isConfirmingReplace)
        #expect(controller.isShowingResult)
        #expect(controller.exportedFiles.count == 3)
    }

    private func makeLibrary() async throws -> (PhotoLibrary, URL) {
        let folder = try TestImages.makeFolder()
        let urls = try [
            TestImages.writeJPEG("Landscape", width: 3000, height: 2000, color: TestImages.red, in: folder),
            TestImages.writeJPEG("Portrait", width: 2000, height: 2500, color: TestImages.green, in: folder),
            TestImages.writeJPEG("Square", width: 2000, height: 2000, color: TestImages.blue, in: folder),
        ]
        let library = PhotoLibrary()
        await library.importPhotos(from: urls)
        return (library, folder)
    }
}
