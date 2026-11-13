import SwiftUI

struct ContentView: View {
    @State private var library = PhotoLibrary()
    @State private var settingsStore = FrameSettingsStore(defaults: UITestingSupport.defaults)
    @State private var exporter = ExportController()

    @State private var mode = WorkspaceMode.arrange
    @State private var isInspectorPresented = true
    @State private var filePicker = FilePicker.photos
    @State private var isFilePickerPresented = false
    @State private var isShowingImportFailures = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minWidth: 520, minHeight: 420)
            .overlay {
                if library.isImporting {
                    ProgressView("Importing…")
                        .padding()
                        .background(.regularMaterial, in: .rect(cornerRadius: 12))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(reduceMotion ? nil : .smooth, value: mode)
            .animation(reduceMotion ? nil : .smooth, value: library.photos.isEmpty)
            .animation(reduceMotion ? nil : .smooth, value: library.isImporting)
            .dropDestination(for: URL.self) { urls, _ in
                importPhotos(urls)
            }
            .toolbar { toolbar }
            .inspector(isPresented: $isInspectorPresented) {
                FrameSettingsView(store: settingsStore)
                    .inspectorColumnWidth(min: 260, ideal: 300, max: 400)
            }
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: filePicker.contentTypes,
                allowsMultipleSelection: filePicker == .photos,
                onCompletion: handlePickedFiles
            )
            .alert("Some Files Couldn’t Be Imported", isPresented: $isShowingImportFailures) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(library.failedImports.formatted(.list(type: .and)))
            }
            .confirmationDialog(
                inflected("Replace ^[\(exporter.conflicts.count) existing file](inflect: true)?"),
                isPresented: $exporter.isConfirmingReplace
            ) {
                Button("Replace", role: .destructive) {
                    Task { await exporter.confirmReplace(of: library.photos, settings: settingsStore.settings) }
                }
                Button("Cancel", role: .cancel, action: exporter.cancelReplace)
            } message: {
                Text("The folder already contains files with the same names, such as “\(exporter.conflicts.first ?? "")”.")
            }
            .alert(inflected("Exported ^[\(exporter.exportedFiles.count) photo](inflect: true)"), isPresented: $exporter.isShowingResult) {
                Button("Show in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting(exporter.exportedFiles)
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportSummary)
            }
            .alert("Export Failed", isPresented: $exporter.isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exporter.errorMessage)
            }
            .task {
                await UITestingSupport.seedIfEnabled(library)
            }
    }

    @ViewBuilder
    private var content: some View {
        if library.photos.isEmpty {
            ContentUnavailableView {
                Label("No Photos", systemImage: "photo.on.rectangle.angled")
            } description: {
                Text("Import photos or drop them here to frame them for your post.")
            } actions: {
                Button("Import Photos…") { present(.photos) }
            }
        } else {
            switch mode {
            case .arrange:
                PhotoGridView(library: library, settings: settingsStore.settings)
            case .preview:
                PostPreviewView(photos: library.photos, settings: settingsStore.settings)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button("Import Photos", systemImage: "plus") { present(.photos) }
                .keyboardShortcut("o")
                .help("Import Photos")
            Button("Remove All Photos", systemImage: "trash", action: library.removeAll)
                .help("Remove All Photos")
                .disabled(library.photos.isEmpty)
        }

        ToolbarItem(placement: .principal) {
            Picker("View", selection: $mode) {
                ForEach(WorkspaceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("mode-picker")
        }

        ToolbarItemGroup(placement: .primaryAction) {
            if exporter.isExporting {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button("Export", systemImage: "square.and.arrow.up", action: startExport)
                    .keyboardShortcut("e")
                    .help("Export Framed Photos")
                    .disabled(library.photos.isEmpty)
            }
            Button("Frame Settings", systemImage: "sidebar.trailing") {
                isInspectorPresented.toggle()
            }
            .help("Show or Hide Frame Settings")
        }
    }

    private var exportSummary: String {
        guard let first = exporter.exportedFiles.first, let last = exporter.exportedFiles.last else { return "" }
        let folder = first.deletingLastPathComponent().lastPathComponent
        if first == last {
            return String(localized: "“\(first.lastPathComponent)” in \(folder)")
        }
        return String(localized: "“\(first.lastPathComponent)” to “\(last.lastPathComponent)” in \(folder)")
    }

    /// Alert titles are shown as plain strings on macOS, so grammar agreement must be resolved first.
    private func inflected(_ resource: LocalizedStringResource) -> String {
        String(AttributedString(localized: resource).characters)
    }

    private func present(_ picker: FilePicker) {
        filePicker = picker
        isFilePickerPresented = true
    }

    private func importPhotos(_ urls: [URL]) {
        Task {
            await library.importPhotos(from: urls)
            isShowingImportFailures = !library.failedImports.isEmpty
        }
    }

    private func startExport() {
        if let folder = UITestingSupport.exportFolder {
            export(to: folder)
        } else {
            present(.exportFolder)
        }
    }

    private func export(to folder: URL) {
        Task {
            await exporter.requestExport(of: library.photos, settings: settingsStore.settings, to: folder)
        }
    }

    private func handlePickedFiles(_ result: Result<[URL], any Error>) {
        // A failed or cancelled panel needs no message; the user simply tries again.
        guard case let .success(urls) = result else { return }
        switch filePicker {
        case .photos:
            importPhotos(urls)
        case .exportFolder:
            if let folder = urls.first {
                export(to: folder)
            }
        }
    }
}

#Preview {
    ContentView()
}
