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
                    
                    cobrowse.license = "trial"
                    
                    cobrowse.customData = [
                        CBIOUserEmailKey: "ios@example.com",
                        CBIODeviceNameKey: "iOS Demo"
                    ]
                    
                    cobrowse.delegate = session
                    
                    cobrowse.start()
                }
                .environmentObject(session)
                .environmentObject(account)
        }
    }
}
