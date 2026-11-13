import SwiftUI

/// Keeps the user's frame settings across launches.
@Observable
final class FrameSettingsStore {
    var settings: FrameSettings {
        didSet { save() }
    }

    /// `Color` bridge for `ColorPicker`, stored as an sRGB `Color.Resolved`.
    var color: Color {
        get { Color(settings.color) }
        set { settings.color = newValue.resolve(in: EnvironmentValues()) }
    }

    private let defaults: UserDefaults
    private static let key = "frameSettings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = defaults.data(forKey: Self.key)
            .flatMap { try? JSONDecoder().decode(FrameSettings.self, from: $0) }
            ?? FrameSettings()
    }

    private func save() {
        defaults.set(try? JSONEncoder().encode(settings), forKey: Self.key)
    }
}
