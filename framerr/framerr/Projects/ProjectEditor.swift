import AppKit
import SwiftUI

/// Asks for a project's title and emoji, when creating or renaming it.
struct ProjectEditor: View {
    let isNew: Bool
    let save: (Project) -> Void

    @State private var project: Project
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    private enum Field {
        case title
        case icon
    }

    init(project: Project, isNew: Bool, save: @escaping (Project) -> Void) {
        _project = State(initialValue: project)
        self.isNew = isNew
        self.save = save
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $project.title)
                    .focused($focusedField, equals: .title)
                    .accessibilityIdentifier("project-title-field")

                LabeledContent("Icon") {
                    HStack {
                        TextField("Icon", text: $project.icon)
                            .labelsHidden()
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .focused($focusedField, equals: .icon)
                            .accessibilityIdentifier("project-icon-field")
                            // Keep one emoji: the one just typed replaces the old.
                            .onChange(of: project.icon) { old, icon in
                                guard icon.count > 1 else { return }
                                project.icon = (icon.first { String($0) != old } ?? icon.first).map(String.init) ?? ""
                            }
                        Button("Choose Emoji…") {
                            focusedField = .icon
                            NSApp.orderFrontCharacterPalette(nil)
                        }
                    }
                }
            } header: {
                Text(isNew ? "New Project" : "Rename Project")
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isNew ? "Create" : "Save") {
                    project.title = project.title.trimmingCharacters(in: .whitespaces)
                    save(project)
                    dismiss()
                }
                .disabled(project.title.trimmingCharacters(in: .whitespaces).isEmpty || project.icon.isEmpty)
            }
        }
        .onAppear { focusedField = .title }
    }
}

#Preview {
    ProjectEditor(project: Project(), isNew: true) { _ in }
}
