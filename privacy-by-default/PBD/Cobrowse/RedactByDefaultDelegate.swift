import UIKit
import CobrowseSDK

final class RedactByDefaultDelegate: NSObject, CobrowseIODelegate {

    func cobrowseRedactedViews(for viewController: UIViewController) -> [UIView] {
        UIApplication.shared.attachedWindows
    }

    func cobrowseUnredactedViews(for viewController: UIViewController) -> [UIView] {
        guard isApproved(viewController)
            else { return [] }

        return [viewController.view]
    }

    private func isApproved(_ viewController: UIViewController) -> Bool {
        if ApprovalRegistry.shared.approvesScreen(of: viewController) {
            return true
        }

        guard viewController.children.isEmpty
            else { return false }

        return viewController is ApprovedForCobrowse
    }

    func cobrowseSessionDidUpdate(_ session: CBIOSession) {}

    func cobrowseSessionDidEnd(_ session: CBIOSession) {}
}

private extension UIApplication {

    var attachedWindows: [UIWindow] {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
    }
}
