import SwiftUI

struct SheetsDemoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Sheets")
                .font(.largeTitle).bold()

            Text("Every sheet decides its own visibility, at every depth.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PresentsApprovedSheet(depth: 1)
            PresentsUnapprovedSheet(depth: 1)
        }
        .padding()
        .navigationTitle("Sheets")
        .frameworkPill()
        .cobrowseScreen(Self.self)
    }
}

struct ApprovedSheetView: View {

    let depth: Int

    var body: some View {
        VStack(spacing: 16) {
            Text("Approved sheet · depth \(depth)")
                .font(.title2).bold()

            Text("Declares its own approval.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            PresentsApprovedSheet(depth: depth + 1)
            PresentsUnapprovedSheet(depth: depth + 1)
        }
        .padding()
    }
}

struct UnapprovedSheetView: View {

    let depth: Int

    var body: some View {
        VStack(spacing: 16) {
            Text("Unapproved sheet · depth \(depth)")
                .font(.title2).bold()

            Text("Deliberately unapproved.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            PresentsApprovedSheet(depth: depth + 1)
            PresentsUnapprovedSheet(depth: depth + 1)
        }
        .padding()
    }
}

private struct PresentsApprovedSheet: View {

    let depth: Int

    @State private var presenting = false

    var body: some View {
        Button("Approved sheet · depth \(depth)") { presenting = true }
            .buttonStyle(.borderedProminent)
            .cobrowseSheet(isPresented: $presenting) { ApprovedSheetView(depth: depth) }
    }
}

private struct PresentsUnapprovedSheet: View {

    let depth: Int

    @State private var presenting = false

    var body: some View {
        Button("Unapproved sheet · depth \(depth)") { presenting = true }
            .buttonStyle(.bordered)
            .cobrowseSheet(isPresented: $presenting) { UnapprovedSheetView(depth: depth) }
    }
}
