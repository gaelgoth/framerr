import Foundation
import Testing
@testable import framerr

@MainActor
final class PhotoLibraryTests {
    private let folder: URL

    init() throws {
        folder = try TestImages.makeFolder()
    }

    deinit {
        try? FileManager.default.removeItem(at: folder)
    }

    @Test func bulkImportKeepsSelectionOrder() async throws {
        let names = ["E", "A", "D", "B", "C"]
        let urls = try names.map { try TestImages.writeJPEG($0, width: 3000, height: 2000, in: folder) }

        let library = PhotoLibrary()
        await library.importPhotos(from: urls)

        #expect(library.photos.map(\.name) == names)
        #expect(library.failedImports.isEmpty)
        #expect(!library.isImporting)
        // Thumbnails are downsampled but keep the aspect ratio.
        #expect(library.photos[0].pixelSize == CGSize(width: 1080, height: 720))
    }

    @Test func unreadableFilesAreSkippedAndReported() async throws {
        let good = try TestImages.writeJPEG("Good", width: 100, height: 100, in: folder)
        let bad = folder.appending(path: "Broken.jpg")
        try Data("not an image".utf8).write(to: bad)

        let library = PhotoLibrary()
        await library.importPhotos(from: [good, bad])

        #expect(library.photos.map(\.name) == ["Good"])
        #expect(library.failedImports == ["Broken.jpg"])
    }

    @Test func importAppendsToExistingPhotos() async throws {
        let library = try await makeLibrary(["A", "B"])

        try await library.importPhotos(from: [TestImages.writeJPEG("C", width: 10, height: 10, in: folder)])

        #expect(library.photos.map(\.name) == ["A", "B", "C"])
    }

    @Test func moveReordersPhotos() async throws {
        let library = try await makeLibrary(["A", "B", "C"])
        let a = library.photos[0].id
        let c = library.photos[2].id

        library.move(a, to: 2)
        #expect(library.photos.map(\.name) == ["B", "C", "A"])

        library.move(c, to: 0)
        #expect(library.photos.map(\.name) == ["C", "B", "A"])

        library.move(c, to: 99)
        #expect(library.photos.map(\.name) == ["B", "A", "C"])
    }

    @Test func dragReorderMovesPhotosBeforeTargetOrToEnd() async throws {
        let library = try await makeLibrary(["A", "B", "C", "D"])
        let id = { (name: String) in library.photos.first { $0.name == name }!.id }

        library.move([id("A")], before: id("D"))
        #expect(library.photos.map(\.name) == ["B", "C", "A", "D"])

        library.move([id("D"), id("B")], before: id("C"))
        #expect(library.photos.map(\.name) == ["D", "B", "C", "A"])

        library.move([id("D")], before: nil)
        #expect(library.photos.map(\.name) == ["B", "C", "A", "D"])
    }

    @Test func removeDeletesOnlyThatPhoto() async throws {
        let library = try await makeLibrary(["A", "B", "C"])

        library.remove(library.photos[1].id)
        #expect(library.photos.map(\.name) == ["A", "C"])

        library.removeAll()
        #expect(library.photos.isEmpty)
    }

    @Test func importIntoFolderKeepsACopy() async throws {
        let source = try TestImages.writeJPEG("A", width: 10, height: 10, in: folder)
        let copies = folder.appending(path: "project")
        var changes: [[String]] = []
        let library = PhotoLibrary(folder: copies) { changes.append($0.map(\.name)) }

        try await library.importPhotos(from: [source, TestImages.writeJPEG("B", width: 10, height: 10, in: folder)])
        try FileManager.default.removeItem(at: source)

        let copy = library.photos[0].url
        #expect(copy.path.hasPrefix(copies.path))
        #expect(library.photos.map(\.name) == ["A", "B"])
        #expect(changes == [["A", "B"]], "one change per import")

        let reopened = PhotoLibrary(folder: copies)
        await reopened.open(library.photos.map(\.url))
        #expect(reopened.photos.map(\.name) == ["A", "B"], "the copy outlives the original")

        library.remove(library.photos[0].id)
        #expect(!FileManager.default.fileExists(atPath: copy.path))
        #expect(changes.last == ["B"])
    }

    @Test func removeNeverDeletesOriginals() async throws {
        let original = try TestImages.writeJPEG("A", width: 10, height: 10, in: folder)
        let library = PhotoLibrary(folder: folder.appending(path: "project"))
        await library.open([original])

        library.removeAll()

        #expect(FileManager.default.fileExists(atPath: original.path))
    }

    private func makeLibrary(_ names: [String]) async throws -> PhotoLibrary {
        let library = PhotoLibrary()
        try await library.importPhotos(from: names.map { try TestImages.writeJPEG($0, width: 10, height: 10, in: folder) })
        return library
    }
}
