//
//  FullDeviceConsentPromptViewController.swift
//  Cobrowse
//

import UIKit
import Combine
import ReplayKit

import CobrowseSDK

class FullDeviceConsentPromptViewController: UIViewController {
    
    @IBOutlet private weak var pickerView: RPSystemBroadcastPickerView!
    
    private var bag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.showsMicrophoneButton = false
        pickerView.preferredExtension = "io.cobrowse.demo.broadcast-extension"
        pickerView.accessibilityElementsHidden = true
        
        subscribeToSession()
    }

    @IBAction func denyButtonWasTapped(_ sender: Any) {
        cobrowseSession.current?.setFullDevice(.rejected)
        dismiss(animated: true)
    }

    @IBAction func allowButtonWasTapped(_ sender: Any) {
        
        // Find the broadcast button to trigger the picker from our
        // custom `allow` button.
        guard let button = broadcastButton(in: pickerView)
                else { return }
        
        button.sendActions(for: .touchDown)
    }
    
    private func broadcastButton(in view: UIView) -> UIButton? {
        
        if let button = view as? UIButton {
            return button
        }
        
        for subview in view.subviews {
            if let found = broadcastButton(in: subview) {
                return found
            }
        }
        
        return nil
    }
}

// MARK: - Subscriptions

extension FullDeviceConsentPromptViewController {
    
    private func subscribeToSession() {
        
        cobrowseSession.$current.sink { [weak self] session in
            
            guard
                let self = self,
                let session = session, session.fullDevice() != .requested
            else { return }
            
            dismiss(animated: true)
        }
        .store(in: &bag)
    }
}
