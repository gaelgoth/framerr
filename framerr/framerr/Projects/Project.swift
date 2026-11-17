import Foundation

/// A draft post: its photos in carousel order and how they are framed.
nonisolated struct Project: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var created = Date.now
    var title = String(localized: "Untitled Post")
    /// A single emoji shown in the sidebar.
    var icon = "📷"
    var settings = FrameSettings()
    /// Photo files relative to `ProjectStore.photosFolder(for:)`, in carousel order.
    var photos: [String] = []
}
