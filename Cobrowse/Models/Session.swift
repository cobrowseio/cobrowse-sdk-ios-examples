//
//  Session.swift
//  Cobrowse
//

import Foundation

import CobrowseIO

class Session: NSObject, CobrowseIODelegate {
    
    @Published var current: CBIOSession?
    
    let isRedactionByDefaultEnabled = true
    
    func cobrowseSessionDidUpdate(_ session: CBIOSession) {
        current = session
    }
    
    func cobrowseSessionDidEnd(_ session: CBIOSession) {
        current = nil
    }
    
    func cobrowseRedactedViews(for vc: UIViewController) -> [UIView] {
        
        guard isRedactionByDefaultEnabled,
              let keyWindow = UIWindow.keyWindow
            else { return [] }
        
        return keyWindow.rootViews
    }
}
