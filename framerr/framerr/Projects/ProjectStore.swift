import Foundation

/// Keeps every draft across launches, one folder each: `project.json` and the copied photos.
@Observable
final class ProjectStore {
    /// Newest first. Any change is written to disk right away.
    var projects: [Project] {
        didSet {
            for project in projects where !oldValue.contains(project) {
                save(project)
            }
        }
    }

    private let root: URL

    init(root: URL) {
        self.root = root
        let folders = (try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? []
        projects = folders
            .compactMap { try? Data(contentsOf: $0.appending(path: "project.json")) }
            .compactMap { try? JSONDecoder().decode(Project.self, from: $0) }
            .sorted { $0.created > $1.created }
    }

    /// The project with `id`; setting a deleted project does nothing.
    subscript(id: Project.ID?) -> Project? {
        get { projects.first { $0.id == id } }
        set {
            guard let newValue, let index = projects.firstIndex(where: { $0.id == newValue.id }) else { return }
            projects[index] = newValue
        }
    }

    @discardableResult
    func create(_ project: Project = Project()) -> Project.ID {
        projects.insert(project, at: 0)
        return project.id
    }

    func delete(_ id: Project.ID) {
        projects.removeAll { $0.id == id }
        try? FileManager.default.removeItem(at: folder(for: id))
    }

    func photosFolder(for id: Project.ID) -> URL {
        folder(for: id).appending(path: "photos")
    }

    func photoURLs(of project: Project) -> [URL] {
        project.photos.map { photosFolder(for: project.id).appending(path: $0) }
    }

    /// Records the carousel order. Imported copies live at `photos/<uuid>/<name>`.
    func setPhotos(_ urls: [URL], of id: Project.ID) {
        self[id]?.photos = urls.map { "\($0.deletingLastPathComponent().lastPathComponent)/\($0.lastPathComponent)" }
    }

    private func folder(for id: Project.ID) -> URL {
        root.appending(path: id.uuidString)
    }

    private func save(_ project: Project) {
        let folder = folder(for: project.id)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? JSONEncoder().encode(project).write(to: folder.appending(path: "project.json"), options: .atomic)
    }
}
