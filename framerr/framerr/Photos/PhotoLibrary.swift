import CoreGraphics
import Foundation

/// The photos of the post being prepared, in carousel order.
@Observable
final class PhotoLibrary {
    private(set) var photos: [Photo] = [] {
        didSet { onChange?(photos) }
    }

    private(set) var isImporting = false
    /// Names of files that couldn't be read during the last import.
    private(set) var failedImports: [String] = []

    /// Where imported photos are copied; `nil` keeps them at their original location.
    private let folder: URL?
    private let onChange: (([Photo]) -> Void)?

    init(folder: URL? = nil, onChange: (([Photo]) -> Void)? = nil) {
        self.folder = folder
        self.onChange = onChange
    }

    func importPhotos(from urls: [URL]) async {
        await load(urls, copyingInto: folder)
    }

    /// Loads photos that are already in place, such as those of a saved project.
    func open(_ urls: [URL]) async {
        await load(urls, copyingInto: nil)
    }

    func index(of id: Photo.ID) -> Int? {
        photos.firstIndex { $0.id == id }
    }

    /// Moves a photo so it ends up at `destination`; out-of-range destinations are clamped.
    func move(_ id: Photo.ID, to destination: Int) {
        guard let source = index(of: id) else { return }
        let photo = photos.remove(at: source)
        photos.insert(photo, at: min(max(destination, 0), photos.count))
    }

    /// Moves photos, in the given order, in front of `target`, or to the end when `target` is `nil`.
    func move(_ ids: [Photo.ID], before target: Photo.ID?) {
        let moved = ids.compactMap { id in photos.first { $0.id == id } }
        photos.removeAll { ids.contains($0.id) }
        let destination = target.flatMap(index(of:)) ?? photos.endIndex
        photos.insert(contentsOf: moved, at: destination)
    }

    func remove(_ id: Photo.ID) {
        deleteCopies(of: photos.filter { $0.id == id })
        photos.removeAll { $0.id == id }
    }

    func removeAll() {
        deleteCopies(of: photos)
        photos.removeAll()
    }

    private func load(_ urls: [URL], copyingInto folder: URL?) async {
        // An empty project has nothing to load; don't flash the progress overlay.
        guard !urls.isEmpty else { return }
        isImporting = true
        failedImports = []
        defer { isImporting = false }

        var loaded: [Photo] = []
        for (url, photo) in await Self.loadPhotos(urls, copyingInto: folder) {
            if let photo {
                loaded.append(photo)
            } else {
                failedImports.append(url.lastPathComponent)
            }
        }
        // One change for the whole import, so observers never see a partial list.
        photos += loaded
    }

    /// Only touches files inside `folder`, never the user's originals.
    private func deleteCopies(of removed: [Photo]) {
        guard let folder else { return }
        for photo in removed where photo.url.path.hasPrefix(folder.path) {
            try? FileManager.default.removeItem(at: photo.url.deletingLastPathComponent())
        }
    }

    /// Copies (when `folder` is set) and decodes thumbnails in parallel off the main actor, in the original order.
    @concurrent
    private static func loadPhotos(_ urls: [URL], copyingInto folder: URL?) async -> [(URL, Photo?)] {
        await withTaskGroup(of: (Int, Photo?).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    (index, makePhoto(from: url, copyingInto: folder))
                }
            }

            var photos = [Photo?](repeating: nil, count: urls.count)
            for await(index, photo) in group {
                photos[index] = photo
            }
            return Array(zip(urls, photos))
        }
    }

    /// Copies go to `folder/<uuid>/<name>`, keeping the original name for export.
    private nonisolated static func makePhoto(from url: URL, copyingInto folder: URL?) -> Photo? {
        guard let folder else {
            return PhotoLoader.image(at: url, maxPixelSize: Photo.thumbnailPixelSize).map { Photo(url: url, thumbnail: $0) }
        }
        let copyFolder = folder.appending(path: UUID().uuidString)
        let copy = copyFolder.appending(path: url.lastPathComponent)
        guard
            PhotoLoader.copy(url, to: copy),
            let thumbnail = PhotoLoader.image(at: copy, maxPixelSize: Photo.thumbnailPixelSize)
        else {
            try? FileManager.default.removeItem(at: copyFolder)
            return nil
        }
        return Photo(url: copy, thumbnail: thumbnail)
    }
}
