import Foundation
import SwiftUI
import Testing
@testable import framerr

@MainActor
final class ProjectStoreTests {
    private let root: URL

    init() throws {
        root = try TestImages.makeFolder()
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    @Test func projectsPersistAcrossLaunches() throws {
        let store = ProjectStore(root: root)
        let older = store.create()
        let id = store.create()
        #expect(store.projects.map(\.id) == [id, older], "newest first")

        store[id]?.title = "Summer"
        store[id]?.icon = "🌊"
        store[id]?.settings.ratio = .square
        store[id]?.settings.borderPercent = 12.5
        store[id]?.settings.fillGap = .vertical
        store[id]?.settings.pickerColor = Color(.sRGB, red: 0, green: 0, blue: 0)
        store.setPhotos([store.photosFolder(for: id).appending(path: "X/A.jpg")], of: id)

        let reloaded = ProjectStore(root: root)
        #expect(reloaded.projects == store.projects)
        let project = try #require(reloaded[id])
        #expect(project.title == "Summer")
        #expect(project.icon == "🌊")
        #expect(project.settings.ratio == .square)
        #expect(project.settings.color.red == 0)
        #expect(reloaded.photoURLs(of: project) == [reloaded.photosFolder(for: id).appending(path: "X/A.jpg")])
        #expect(reloaded[older]?.settings == FrameSettings(), "settings are per project")
    }

    @Test func createKeepsTheGivenTitleAndIcon() {
        let store = ProjectStore(root: root)
        let id = store.create(Project(title: "Summer", icon: "🌊"))

        #expect(ProjectStore(root: root)[id]?.title == "Summer")
        #expect(ProjectStore(root: root)[id]?.icon == "🌊")
    }

    @Test func deleteRemovesTheProjectAndItsPhotos() throws {
        let store = ProjectStore(root: root)
        let id = store.create()
        let photos = store.photosFolder(for: id)
        try FileManager.default.createDirectory(at: photos, withIntermediateDirectories: true)

        store.delete(id)

        #expect(store.projects.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: photos.deletingLastPathComponent().path))
        #expect(ProjectStore(root: root).projects.isEmpty)
        store[id]?.title = "Gone"
        #expect(store.projects.isEmpty, "editing a deleted project does nothing")
    }
}
