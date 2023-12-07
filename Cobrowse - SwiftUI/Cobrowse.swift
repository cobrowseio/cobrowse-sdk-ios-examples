//
//  Cobrowse.swift
//  Cobrowse
//

import SwiftUI
import CobrowseIO

@main
struct Cobrowse: App {

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .onAppear {
                        let cobrowse = CobrowseIO.instance()
                        
                        cobrowse.license = "trial"
                        
                        cobrowse.customData = [
                            kCBIOUserEmailKey: "ios@demo.com",
                            kCBIODeviceNameKey: "iOS Demo"
                        ] as [String : NSObject]
                        
                        cobrowse.start()
                    }
            }
//            .redacted()
        }
        
    }
}
