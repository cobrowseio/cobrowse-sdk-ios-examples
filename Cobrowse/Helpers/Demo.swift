//
//  Demo.swift
//

import Foundation

import SwiftUI
import CobrowseSDK

enum Demo {
    
    @AppStorage("isAppetize")
    static var isAppetize = false
    
    @discardableResult
    static func setup() -> Bool {
        
        #if APPCLIP
        let isDemo = true
        #else
        let isDemo = Demo.isAppetize
        #endif
        
        if isDemo {
            let demoID = Int.random(in: 1000..<9999).description
            
            #if APPCLIP
            let license = "rE6HC6EDX6g2_w"
            let deviceName = "AppClip iOS Device (\(demoID))"
            let userEmail = "appclip-\(demoID)@example.com"
            #else
            let license = "trial"
            let deviceName = "Trial iOS Device"
            let userEmail = "ios@example.com"
            #endif
            
            let cobrowse = CobrowseIO.instance()
            
            cobrowse.license = license
            cobrowse.api = "https://cobrowse.io"
            cobrowse.capabilities = ["arrows", "disappearing_ink", "drawing", "keypress", "laser", "pointer", "rectangles"]
            cobrowse.customData = [
                "demo_id": demoID,
                CBIODeviceNameKey: deviceName,
                CBIOUserEmailKey: userEmail
            ]
            
            account.isSignedIn = true
        }
        
        return isDemo
    }
}
