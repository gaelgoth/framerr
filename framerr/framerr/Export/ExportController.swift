import Foundation

/// Drives the export flow: conflict check, replace confirmation, export, and the result.
@Observable
final class ExportController {
    private(set) var isExporting = false

    private(set) var conflicts: [String] = []
    var isConfirmingReplace = false
    private var pendingFolder: URL?

    private(set) var exportedFiles: [URL] = []
    var isShowingResult = false

    private(set) var errorMessage = ""
    var isShowingError = false

    /// Exports straight away, or asks first when files with the same names exist.
    func requestExport(of photos: [Photo], settings: FrameSettings, to folder: URL) async {
        conflicts = PhotoExporter.conflictingFiles(for: photos, in: folder)
        if conflicts.isEmpty {
            await export(photos, settings: settings, to: folder)
        } else {
            pendingFolder = folder
            isConfirmingReplace = true
        }
    }

    func confirmReplace(of photos: [Photo], settings: FrameSettings) async {
        guard let folder = pendingFolder else { return }
        pendingFolder = nil
        await export(photos, settings: settings, to: folder)
    }

    func cancelReplace() {
        pendingFolder = nil
    }

    private func export(_ photos: [Photo], settings: FrameSettings, to folder: URL) async {
        isExporting = true
        defer { isExporting = false }

        do {
            exportedFiles = try await PhotoExporter.export(photos, settings: settings, to: folder)
            isShowingResult = true
        } catch {
            errorMessage = error.localizedDescription
            isShowingError = true
        }
    }
}
