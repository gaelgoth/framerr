import UniformTypeIdentifiers

/// What the window's single `fileImporter` is currently picking.
enum FilePicker {
    case photos
    case exportFolder

    var contentTypes: [UTType] {
        switch self {
        case .photos: [.image]
        case .exportFolder: [.folder]
        }
    }
}
