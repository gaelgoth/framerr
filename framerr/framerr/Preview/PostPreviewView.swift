import SwiftUI

/// Mock of a social feed post, to check the carousel before exporting.
struct PostPreviewView: View {
    let photos: [Photo]
    let settings: FrameSettings

    @State private var currentID: Photo.ID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentIndex: Int {
        photos.firstIndex { $0.id == currentID } ?? 0
    }

    private var animation: Animation? {
        reduceMotion ? nil : .snappy
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PostHeader()
                carousel
                actions
                Text("**your_username** Your caption goes here")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
            }
            .frame(maxWidth: 470)
            .background(.background, in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.separator)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(.background.secondary)
    }

    private var carousel: some View {
        let canvas = settings.ratio.canvasSize

        return ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(photos) { photo in
                    FramedPhotoView(image: photo.thumbnail, settings: settings)
                        .containerRelativeFrame(.horizontal)
                        .accessibilityLabel(photo.name)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentID)
        .scrollIndicators(.hidden)
        .aspectRatio(canvas.width / canvas.height, contentMode: .fit)
        .animation(animation, value: settings)
        .overlay(alignment: .topTrailing) {
            Text("\(currentIndex + 1)/\(photos.count)")
                .font(.caption.bold())
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(currentIndex)))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.6), in: .capsule)
                .padding(10)
                .accessibilityIdentifier("page-counter")
                .animation(animation, value: currentIndex)
        }
        .overlay {
            HStack {
                pageButton("Previous Photo", systemImage: "chevron.left", offset: -1)
                    .opacity(currentIndex > 0 ? 1 : 0)
                Spacer()
                pageButton("Next Photo", systemImage: "chevron.right", offset: 1)
                    .opacity(currentIndex < photos.count - 1 ? 1 : 0)
            }
            .padding(.horizontal, 10)
            .animation(animation, value: currentIndex)
        }
    }

    private var actions: some View {
        HStack(spacing: 16) {
            Image(systemName: "heart")
            Image(systemName: "bubble.right")
            Image(systemName: "paperplane")
            Spacer()
            Image(systemName: "bookmark")
        }
        .font(.title3)
        .overlay {
            pageDots
        }
        .padding(12)
        .accessibilityHidden(true)
    }

    private var pageDots: some View {
        HStack(spacing: 4) {
            ForEach(photos.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.accentColor : Color.secondary.opacity(0.4))
                    .frame(width: 6, height: 6)
            }
        }
        .animation(animation, value: currentIndex)
    }

    private func pageButton(_ title: LocalizedStringKey, systemImage: String, offset: Int) -> some View {
        Button(title, systemImage: systemImage) {
            let target = min(max(currentIndex + offset, 0), photos.count - 1)
            withAnimation(animation) {
                currentID = photos[target].id
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .font(.body.bold())
        .foregroundStyle(.black)
        .frame(width: 28, height: 28)
        .background(.white.opacity(0.85), in: .circle)
        .contentShape(.circle)
        .disabled(offset < 0 ? currentIndex == 0 : currentIndex == photos.count - 1)
    }
}
