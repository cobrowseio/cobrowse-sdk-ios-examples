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
        
        subscribeToSession()
    }

    @IBAction func denyButtonWasTapped(_ sender: Any) {
        cobrowseSession.current?.setFullDevice(.rejected)
        dismiss(animated: true)
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

final class GlyphTintView: UIView {
    
    @IBOutlet weak var sourceView: UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }
    
    private func updateMask() {
        guard let sourceView, !bounds.isEmpty
                else { return }
        
        guard let glyph = imageView(in: sourceView),
              let image = glyph.image,
              !glyph.bounds.isEmpty
        else { return }
        
        let maskFrame = glyph.convert(glyph.bounds, to: self)
        let maskView = mask as? UIImageView ?? UIImageView()
        
        if maskView.image !== image {
            maskView.image = image
            maskView.contentMode = glyph.contentMode
        }
        
        if maskView.frame != maskFrame {
            maskView.frame = maskFrame
        }
        
        if mask !== maskView {
            mask = maskView
        }
        
        // The mask already has this image.
        // Hide the original so the black shape does not sit under the color.
        if glyph.alpha != 0 {
            glyph.alpha = 0
        }
        
        if isHidden {
            isHidden = false
        }
    }
    
    private func imageView(in view: UIView) -> UIImageView? {
        
        if let imageView = view as? UIImageView, imageView.image != nil {
            return imageView
        }
        
        for subview in view.subviews {
            if let found = imageView(in: subview) {
                return found
            }
        }
        
        return nil
    }
}
