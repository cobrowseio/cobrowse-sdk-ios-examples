//
//  Cobrowse.swift
//  Cobrowse
//

import SwiftUI
import CobrowseIO

@main
struct Cobrowse: App {
    
    let session = Session()
    let account = Account()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    let cobrowse = CobrowseIO.instance()
                    
                    cobrowse.license = "trial"
                    
                    cobrowse.customData = [
                        kCBIOUserEmailKey: "ios@example.com",
                        kCBIODeviceNameKey: "iOS Demo"
                    ] as [String : NSObject]
                    
                    cobrowse.webviewRedactedViews = [
                        "#title",
                        "#amount",
                        "#subtitle",
                        "#map"
                    ]
                    
                    cobrowse.delegate = session
                    
                    cobrowse.start()
                }
                .environmentObject(session)
                .environmentObject(account)
        }
        
    }
}

struct RootView: View {
    
    @EnvironmentObject private var account: Account
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        
        if account.isSignedIn {
            if horizontalSizeClass == .compact {
                NavigationStack {
                    Dashboard(shouldPresentTransactionsSheet: true)
                }
            } else {
                NavigationSplitView {
                    Transaction.List(transactions: account.transactions)
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

