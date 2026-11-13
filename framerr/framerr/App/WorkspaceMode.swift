import Foundation

enum WorkspaceMode: String, CaseIterable, Identifiable {
    case arrange
    case preview

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .arrange: "Arrange"
        case .preview: "Post Preview"
        }
    }
}
