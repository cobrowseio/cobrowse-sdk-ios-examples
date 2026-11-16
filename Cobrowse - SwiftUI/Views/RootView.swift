//
//  RootView.swift
//  Cobrowse - SwiftUI
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var account: Account
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // The sidebar list is not in a sheet, so it is always full height.
    // Its session toolbar tracks the detent, which Dashboard only provides to its own subtree.
    @State private var sidebarDetent = Transaction.Detent.State(.large)
    
    var body: some View {
        
        if account.isSignedIn {
            if horizontalSizeClass == .compact {
                NavigationStack {
                    Dashboard(shouldPresentTransactionsSheet: true)
                }
            } else {
                NavigationSplitView {
                    Transaction.List(transactions: account.transactions)
                        .environmentObject(sidebarDetent)
                } detail: {
                    NavigationStack {
                        Dashboard(shouldPresentTransactionsSheet: false)
                    }
                }
            }
        } else {
            SignIn()
        }
    }
}
