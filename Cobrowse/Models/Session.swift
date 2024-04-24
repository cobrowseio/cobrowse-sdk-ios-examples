//
//  Session.swift
//  Cobrowse
//

import Foundation

import CobrowseIO

class Session: NSObject, ObservableObject, CobrowseIODelegate {
    
    @Published var current: CBIOSession?
    
    @UserDefault(key: "isRedactionByDefaultEnabled", defaultValue: false)
    var isRedactionByDefaultEnabled: Bool
    
    func cobrowseSessionDidUpdate(_ session: CBIOSession) {
        current = session
    }
    
    func cobrowseSessionDidEnd(_ session: CBIOSession) {
        current = nil
    }
}
