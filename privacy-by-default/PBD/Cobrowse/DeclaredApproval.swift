import SwiftUI
import UIKit

final class ApprovalRegistry {

    static let shared = ApprovalRegistry()

    private let liveMarkers = NSHashTable<ApprovalMarkerView>.weakObjects()

    func approvesScreen(of viewController: UIViewController) -> Bool {
        liveMarkers.allObjects.contains { marker in
            marker.isInAWindow
                && marker.owningViewController === viewController
                && marker.declaresApproval
        }
    }

    fileprivate func markerDidMount(_ marker: ApprovalMarkerView) {
        liveMarkers.add(marker)
    }

    fileprivate func markerWasDismantled(_ marker: ApprovalMarkerView) {
        liveMarkers.remove(marker)
    }
}

private extension UIView {

    var isInAWindow: Bool {
        window != nil
    }

    var owningViewController: UIViewController? {
        var responder = next
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}

private final class ApprovalMarkerView: UIView {

    var screenType: Any.Type?

    var declaresApproval: Bool {
        guard let screenType else { return true }

        return CobrowseApproval.approves(screenType)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isInAWindow {
            ApprovalRegistry.shared.markerDidMount(self)
        }
    }
}

private struct ApprovalMarker: UIViewRepresentable {

    let screenType: Any.Type?

    func makeUIView(context: Context) -> ApprovalMarkerView {
        let marker = ApprovalMarkerView()
        marker.screenType = screenType
        marker.isUserInteractionEnabled = false
        marker.isAccessibilityElement = false
        return marker
    }

    func updateUIView(_ uiView: ApprovalMarkerView, context: Context) {
        uiView.screenType = screenType
    }

    static func dismantleUIView(_ uiView: ApprovalMarkerView, coordinator: ()) {
        ApprovalRegistry.shared.markerWasDismantled(uiView)
    }
}

extension View {

    func cobrowseScreen(_ screenType: Any.Type) -> some View {
        background(ApprovalMarker(screenType: screenType).frame(width: 0, height: 0))
    }

    func approvedForCobrowse() -> some View {
        background(ApprovalMarker(screenType: nil).frame(width: 0, height: 0))
    }
}

extension View {

    func cobrowseDestination<Route: Hashable, Screen: View>(
        for route: Route.Type,
        @ViewBuilder destination: @escaping (Route) -> Screen
    ) -> some View {
        navigationDestination(for: route) { value in
            destination(value).cobrowseScreen(Screen.self)
        }
    }

    func cobrowseDestination<Screen: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Screen
    ) -> some View {
        navigationDestination(isPresented: isPresented) {
            destination().cobrowseScreen(Screen.self)
        }
    }

    func cobrowseSheet<Screen: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Screen
    ) -> some View {
        sheet(isPresented: isPresented) {
            content().cobrowseScreen(Screen.self)
        }
    }

    func cobrowseFullScreenCover<Screen: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Screen
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            content().cobrowseScreen(Screen.self)
        }
    }
}
