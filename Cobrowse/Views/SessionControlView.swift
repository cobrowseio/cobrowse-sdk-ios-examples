//
//  SessionControlView.swift
//  Cobrowse
//

import UIKit

class SessionControlView: UIView {
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(named: "CBPrimary")
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
