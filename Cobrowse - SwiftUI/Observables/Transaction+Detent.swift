//
//  Transaction+Detent.swift
//  Cobrowse - SwiftUI
//

import Combine

extension Transaction {
    enum Detent {
        case collapsed, fraction, large
    }
}

extension Transaction.Detent {
    class State: ObservableObject {
        @Published var current: Transaction.Detent
        
        init(_ detent: Transaction.Detent) {
            self.current = detent
        }
        
        func `is`(_ detent: Transaction.Detent) -> Bool {
            current == detent
        }
    }
}
