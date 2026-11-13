import CoreGraphics
import Foundation

/// Which photos touch the canvas edges instead of getting a border on every side.
nonisolated enum FillGapMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case off
    case horizontal
    case vertical
    case all

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .off: "Off"
        case .horizontal: "Horizontal Photos"
        case .vertical: "Vertical Photos"
        case .all: "All Photos"
        }
    }

    /// Square photos are neither horizontal nor vertical, so they only fill with `.all`.
    func applies(to imageSize: CGSize) -> Bool {
        switch self {
        case .off: false
        case .horizontal: imageSize.width > imageSize.height
        case .vertical: imageSize.height > imageSize.width
        case .all: true
        }
    }
}
