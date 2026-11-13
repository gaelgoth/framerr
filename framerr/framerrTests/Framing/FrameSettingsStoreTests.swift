import Foundation
import SwiftUI
import Testing
@testable import framerr

@MainActor
struct FrameSettingsStoreTests {
    @Test func settingsPersistAcrossLaunches() throws {
        let suite = "framerr-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = FrameSettingsStore(defaults: defaults)
        #expect(store.settings == FrameSettings())

        store.settings.ratio = .square
        store.settings.borderPercent = 12.5
        store.settings.fillGap = .vertical
        store.color = Color(.sRGB, red: 0, green: 0, blue: 0)

        let reloaded = FrameSettingsStore(defaults: defaults)
        #expect(reloaded.settings == store.settings)
        #expect(reloaded.settings.ratio == .square)
        #expect(reloaded.settings.borderPercent == 12.5)
        #expect(reloaded.settings.fillGap == .vertical)
        #expect(reloaded.settings.color.red == 0)
    }
}
