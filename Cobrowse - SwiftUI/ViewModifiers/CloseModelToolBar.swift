//
//  SessionToolBar.swift
//  Cobrowse - SwiftUI
//

import SwiftUI

struct CloseModelToolBar: ViewModifier {

    @EnvironmentObject private var cobrowseSession: CobrowseSession
    
    @State var closeModel: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { closeModel = true }
                    label: { Image(systemName: "xmark") }
                        .tint(Color("CBPrimary"))
                        .accessibilityIdentifier("CLOSE_BUTTON")
                }
            }
            .preference(key: CloseModelKey.self, value: closeModel)
    }
}

extension View {
    
    func closeModelToolBar() -> some View {
        self.modifier(CloseModelToolBar())
    }
}

struct CloseModelKey: PreferenceKey {
    
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
