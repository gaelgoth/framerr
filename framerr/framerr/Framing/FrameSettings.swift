import SwiftUI

/// How every photo of the post is framed. One ratio for all, as carousels require.
nonisolated struct FrameSettings: Codable, Equatable, Sendable {
    var ratio = AspectRatio.portrait
    /// Border thickness as a percentage of the canvas width.
    var borderPercent = 5.0
    var color = Color.Resolved(red: 1, green: 1, blue: 1)
    /// Which photos touch the canvas edges; the border then only fills the leftover space.
    var fillGap = FillGapMode.off

    static let borderRange = 0.0 ... 25.0
}
