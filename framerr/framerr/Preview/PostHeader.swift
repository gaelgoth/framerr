import SwiftUI

struct PostHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.title)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("your_username")
                .font(.subheadline.bold())
            Spacer()
            Image(systemName: "ellipsis")
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
