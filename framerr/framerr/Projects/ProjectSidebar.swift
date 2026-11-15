import SwiftUI

/// What the window shows: the never-saved post, or a saved project.
enum SidebarItem: Hashable {
    case unsaved
    case project(Project.ID)

    var projectID: Project.ID? {
        if case let .project(id) = self {
            id
        } else {
            nil
        }
    }
}

/// The unsaved post, then every saved draft. Projects are optional; with none, a hint explains them.
struct ProjectSidebar: View {
    let store: ProjectStore
    @Binding var selection: SidebarItem

    @State private var editing: Edit?
    @State private var deleting: Project?

    var body: some View {
        // Ignores deselection, so something is always shown.
        List(selection: Binding { selection } set: { selection = $0 ?? selection }) {
            Label("Unsaved Post", systemImage: "square.dashed")
                .tag(SidebarItem.unsaved)
                .accessibilityIdentifier("unsaved-row")

            Section("Projects") {
                ForEach(store.projects) { project in
                    Label {
                        Text(project.title.isEmpty ? String(localized: "Untitled Post") : project.title)
                    } icon: {
                        Text(project.icon)
                    }
                    .tag(SidebarItem.project(project.id))
                    .accessibilityIdentifier("project-row")
                    .contextMenu {
                        Button("Rename…") { edit(project, isNew: false) }
                        Button("Delete…", role: .destructive) { deleting = project }
                    }
                }

                if store.projects.isEmpty {
                    Text("Save a post as a project to keep its photos and settings for later.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .selectionDisabled()
                }
            }
        }
        .toolbar {
            Button("New Project", systemImage: "square.and.pencil") {
                edit(Project(), isNew: true)
            }
            .keyboardShortcut("n")
            .help("New Project")
        }
        .sheet(item: $editing) { edit in
            ProjectEditor(project: edit.project, isNew: edit.isNew) { edited in
                // A new project only exists once created, so Cancel leaves nothing behind.
                if edit.isNew {
                    selection = .project(store.create(edited))
                } else {
                    store[edited.id] = edited
                }
            }
        }
        .confirmationDialog(
            "Delete “\(deleting?.title ?? "")”?",
            isPresented: Binding { deleting != nil } set: {
                if !$0 {
                    deleting = nil
                }
            },
            presenting: deleting
        ) { project in
            Button("Delete", role: .destructive) { delete(project) }
        } message: { _ in
            Text("Its photos and frame settings will be removed. Your original files aren’t affected.")
        }
    }

    private func edit(_ project: Project, isNew: Bool) {
        editing = Edit(project: project, isNew: isNew)
    }

    private func delete(_ project: Project) {
        store.delete(project.id)
        if selection == .project(project.id) {
            selection = store.projects.first.map { .project($0.id) } ?? .unsaved
        }
    }

    /// Carries whether the project is new with the sheet itself, so the sheet never reads a stale flag.
    private struct Edit: Identifiable {
        let project: Project
        let isNew: Bool

        var id: Project.ID {
            project.id
        }
    }
}
