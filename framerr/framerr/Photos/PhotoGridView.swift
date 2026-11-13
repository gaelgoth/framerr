import SwiftUI

/// Framed thumbnails in carousel order. Drag a photo and the others make room live.
struct PhotoGridView: View {
    let library: PhotoLibrary
    let settings: FrameSettings

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let positions = Dictionary(uniqueKeysWithValues: library.photos.enumerated().map { ($1.id, $0 + 1) })

        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 260), spacing: 20)], spacing: 20) {
                ForEach(library.photos) { photo in
                    PhotoGridCell(
                        photo: photo,
                        position: positions[photo.id] ?? 0,
                        count: library.photos.count,
                        settings: settings,
                        move: { library.move(photo.id, to: $0 - 1) },
                        remove: { library.remove(photo.id) }
                    )
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
                .reorderable()
            }
            .reorderContainer(for: Photo.self) { difference in
                switch difference.destination.position {
                case let .before(target): library.move(difference.sources, before: target)
                case .end: library.move(difference.sources, before: nil)
                }
            }
            .padding(20)
            // One animation for every order change (drag, menu, import, remove) and every frame setting.
            .animation(reduceMotion ? nil : .snappy, value: library.photos.map(\.id))
            .animation(reduceMotion ? nil : .snappy, value: settings)
        }
    }
}
