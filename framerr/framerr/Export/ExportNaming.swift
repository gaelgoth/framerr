import Foundation

/// File names that sort in carousel order: `01_original-name.jpg`.
nonisolated enum ExportNaming {
    static func fileNames(for names: [String]) -> [String] {
        let width = max(2, String(names.count).count)
        return names.enumerated().map { index, name in
            String(format: "%0*d_%@.jpg", width, index + 1, name)
        }
    }
}
