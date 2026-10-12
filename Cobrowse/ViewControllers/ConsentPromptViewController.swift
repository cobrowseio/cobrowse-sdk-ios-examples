//
//  ConsentPromptViewController.swift
//  Cobrowse
//

import UIKit
import Combine

import CobrowseSDK

class ConsentPromptViewController: UIViewController {
    
    @IBOutlet private weak var headingLabel: UILabel!
    @IBOutlet private weak var bodyLable: UILabel!
    @IBOutlet private weak var termsLabel: UILabel!
    @IBOutlet private weak var denyButton: UIButton!
    @IBOutlet private weak var allowButton: UIButton!
    
    private var bag = Set<AnyCancellable>()
    
    var heading: String?
    var body: String?
    var terms: String?
    
    var onUpdate: ((_ session: CBIOSession?) -> ())?
    var onDeny: ((_ session: CBIOSession?) -> ())?
    var onAllow: ((_ session: CBIOSession?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let heading = heading {
            headingLabel.text = heading
        }
        
        if let body = body {
            bodyLable.text = body
        }
        
        if let terms, !terms.isEmpty {
            termsLabel.isHidden = false
            termsLabel.attributedText = emphasisedTerms(terms)
        } else {
            termsLabel.isHidden = true
        }
        
        denyButton.isHidden = onDeny == nil
        allowButton.isHidden = onAllow == nil
        
        subscribeToSession()
    }
    
    @IBAction func didTapDenyButton(_ sender: Any) {
        onDeny?(cobrowseSession.current)
        dismiss(animated: true)
    }
    
    @IBAction func didTapAllowButton(_ sender: Any) {
        onAllow?(cobrowseSession.current)
        dismiss(animated: true)
    }
}

// MARK: - Terms

extension ConsentPromptViewController {
    
    private func emphasisedTerms(_ terms: String) -> NSAttributedString {
        
        let text = NSMutableAttributedString(
            string: terms,
            attributes: [ .foregroundColor: termsLabel.textColor as Any ]
        )
        
        for phrase in ["Terms & Privacy Policy", "these terms"] {
            
            guard let range = terms.range(of: phrase)
                else { continue }
            
            text.addAttribute(.foregroundColor,
                              value: UIColor.cbPrimary,
                              range: NSRange(range, in: terms))
        }
        
        return text
    }
}

// MARK: - Subscriptions

extension ConsentPromptViewController {
    
    private func subscribeToSession() {
        
        cobrowseSession.$current.sink { [weak self] session in
            guard let self
                else { return }
            
            self.onUpdate?(session)
        }
        .store(in: &bag)
    }
}
