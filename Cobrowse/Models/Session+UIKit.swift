//
//  Session+UIKit.swift
//  Cobrowse
//

import UIKit
import CobrowseIO

extension Session {

    func cobrowseRedactedViews(for vc: UIViewController) -> [UIView] {
        
        guard isRedactionByDefaultEnabled,
              let keyWindow = UIWindow.keyWindow
            else { return [] }
        
        return keyWindow.rootViews
    }
}
