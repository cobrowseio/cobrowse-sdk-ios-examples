import SwiftUI
import SafariServices

struct SettingsView: View {
    
    @Binding var isPresented: Bool
    @State private var showingPrivacyPolicy = false
    
    private let settings: [CobrowseSession.Setting] = [
        .init(title: "Redaction by default", keyPath: \.redactionByDefault),
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(settings) { setting in
                Toggle(setting.title, isOn: setting.binding)
            }
            Spacer()
            Button("Privacy Policy") {
                showingPrivacyPolicy = true
            }
        }
        .padding(.horizontal, 20)
        .navigationTitle("Settings")
        .closeModelToolBar(isPresented: $isPresented)
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: "https://cobrowse.io/privacy")
        }
    }
}
