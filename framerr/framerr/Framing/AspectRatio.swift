import CoreGraphics
import Foundation

/// Post formats, with the exact pixel size social platforms store.
nonisolated enum AspectRatio: String, CaseIterable, Codable, Identifiable, Sendable {
    case square
    case portrait
    case landscape
    case story

    var id: Self {
        self
    }

    var canvasSize: CGSize {
        switch self {
        case .square: CGSize(width: 1080, height: 1080)
        case .portrait: CGSize(width: 1080, height: 1350)
        case .landscape: CGSize(width: 1080, height: 566)
        case .story: CGSize(width: 1080, height: 1920)
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .square: "Square 1:1"
        case .portrait: "Portrait 4:5"
        case .landscape: "Landscape 1.91:1"
        case .story: "Story 9:16"
        }
    }
}
