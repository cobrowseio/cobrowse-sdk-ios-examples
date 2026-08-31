import SwiftUI

struct ContainersDemoView: View {
    var body: some View {
        TabView {
            ApprovedTabView()
                .tabItem { Label("Approved", systemImage: "checkmark.circle") }

            UnapprovedTabView()
                .tabItem { Label("Unapproved", systemImage: "eye.slash") }
        }
        .navigationTitle("Containers")
        .frameworkPill()
    }
}

struct ApprovedTabView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Approved tab")
                .font(.largeTitle).bold()

            Text("Declares its own approval.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .approvedForCobrowse()
    }
}

struct UnapprovedTabView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Unapproved tab")
                .font(.largeTitle).bold()

            Text("Deliberately unapproved.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
