//
//  SessionToolBar.swift
//  Cobrowse - SwiftUI
//

import SwiftUI

struct CloseModelToolBar: ViewModifier {

    @EnvironmentObject private var cobrowseSession: CobrowseSession
    
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isPresented = false }
                    label: {
                        Image(systemName: "xmark")
                    }
                    .tint(Color("CBPrimary"))
                    .accessibilityIdentifier("CLOSE_BUTTON")
                }
            }
    }
}

extension View {
    func closeModelToolBar(isPresented: Binding<Bool>) -> some View {
        self.modifier(CloseModelToolBar(isPresented: isPresented))
    }
}

private struct IsPresentingModalKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isPresentingModal: Bool {
        get { self[IsPresentingModalKey.self] }
        set { self[IsPresentingModalKey.self] = newValue }
    }
}
