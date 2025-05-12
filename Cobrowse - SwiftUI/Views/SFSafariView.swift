import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: String

    func makeUIViewController(context: Context) -> some UIViewController {
        return SFSafariViewController(url: URL(string: url)!)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
