//
//  Cobrowse.swift
//  Cobrowse
//

import SwiftUI
import CobrowseSDK

let session = Session()
let account = Account()

@main
struct Cobrowse: App {
    
    @UIApplicationDelegateAdaptor var delegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    let cobrowse = CobrowseIO.instance()
                    
                    cobrowse.license = "tG4g9cexebTjGw"
                    
                    cobrowse.customData = [
                        CBIOUserEmailKey: "ios@example.com",
                        CBIODeviceNameKey: "iOS Demo"
                    ]
                    
//                    cobrowse.redactedViews = [
//                        "#456"
//                    ]
                    
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
