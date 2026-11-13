import SwiftUI

struct PhotoGridCell: View {
    let photo: Photo
    /// 1-based position in the carousel.
    let position: Int
    let count: Int
    let settings: FrameSettings
    /// Moves the photo to a new 1-based position.
    let move: (Int) -> Void
    let remove: () -> Void

    var body: some View {
        FramedPhotoView(image: photo.thumbnail, settings: settings)
            .clipShape(.rect(cornerRadius: 4))
            // A hairline instead of a shadow: shadows are re-rendered every frame while cells move.
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(.separator)
            }
            .overlay(alignment: .topLeading) {
                Text(position, format: .number)
                    .font(.caption.bold())
                    .monospacedDigit()
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.thinMaterial, in: .capsule)
                    .padding(6)
            }
            .help(photo.name)
            .contextMenu {
                Button("Move to Start", systemImage: "arrow.left.to.line") { move(1) }
                    .disabled(position == 1)
                Button("Move Earlier", systemImage: "arrow.left") { move(position - 1) }
                    .disabled(position == 1)
                Button("Move Later", systemImage: "arrow.right") { move(position + 1) }
                    .disabled(position == count)
                Button("Move to End", systemImage: "arrow.right.to.line") { move(count) }
                    .disabled(position == count)
                Divider()
                Button("Remove", systemImage: "trash", role: .destructive, action: remove)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Photo \(position) of \(count), \(photo.name)")
            .accessibilityAddTraits(.isImage)
            .accessibilityIdentifier("photo-cell")
            .accessibilityAction(named: "Move Earlier") { move(position - 1) }
            .accessibilityAction(named: "Move Later") { move(position + 1) }
            .accessibilityAction(named: "Remove", remove)
    }
}
