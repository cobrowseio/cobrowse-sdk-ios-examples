import SwiftUI
import UIKit

struct RepresentableDemoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Representable")
                .font(.largeTitle).bold()

            Text("Declared, and hosts a UIViewControllerRepresentable.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            EmbeddedController()
                .frame(height: 140)
        }
        .padding()
        .navigationTitle("Representable")
        .frameworkPill()
        .cobrowseScreen(Self.self)
    }
}

private struct EmbeddedController: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        EmbeddedContentController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private final class EmbeddedContentController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemBackground

        let label = UILabel()
        label.text = "UIKit inside a declared screen"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
}
