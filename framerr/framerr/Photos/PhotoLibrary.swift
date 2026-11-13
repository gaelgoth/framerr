import CoreGraphics
import Foundation

/// The photos of the post being prepared, in carousel order.
@Observable
final class PhotoLibrary {
    private(set) var photos: [Photo] = []
    private(set) var isImporting = false
    /// Names of files that couldn't be read during the last import.
    private(set) var failedImports: [String] = []

    func importPhotos(from urls: [URL]) async {
        isImporting = true
        failedImports = []
        defer { isImporting = false }

        for (url, thumbnail) in await Self.loadThumbnails(urls) {
            if let thumbnail {
                photos.append(Photo(url: url, thumbnail: thumbnail))
            } else {
                failedImports.append(url.lastPathComponent)
            }
        }
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
        photos.removeAll { $0.id == id }
    }

    func removeAll() {
        photos.removeAll()
    }

    /// Decodes thumbnails in parallel off the main actor, returned in the original order.
    @concurrent
    private static func loadThumbnails(_ urls: [URL]) async -> [(URL, CGImage?)] {
        await withTaskGroup(of: (Int, CGImage?).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    (index, PhotoLoader.image(at: url, maxPixelSize: Photo.thumbnailPixelSize))
                }
            }

            var thumbnails = [CGImage?](repeating: nil, count: urls.count)
            for await(index, thumbnail) in group {
                thumbnails[index] = thumbnail
            }
            return Array(zip(urls, thumbnails))
        }
    }
}
