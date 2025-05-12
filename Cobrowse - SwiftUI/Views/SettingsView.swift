import SwiftUI
import SafariServices

struct SettingsView: View {
    
    @State private var showingPrivacyPolicy = false
    
    private let settings: [CobrowseSession.Setting] = [
        .init(title: "Redaction by default", keyPath: \.isRedactionByDefaultEnabled),
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(settings) { setting in
                Toggle(setting.title, isOn: setting.binding)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button("Privacy Policy") {
                showingPrivacyPolicy = true
            }
        }
        .frame(maxWidth: .infinity)
        .background { Color("Background").ignoresSafeArea() }
        .navigationTitle("Settings")
        .closeModelToolBar()
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: "https://cobrowse.io/privacy")
        }
    }
}
