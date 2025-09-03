
import UIKit
import Combine

import CobrowseSDK

class SessionMetricsButton: UIButton {

    private var bag = Set<AnyCancellable>()
    
    var latency: CobrowseSession.Latency = .unknown {
        didSet { tintColor = latency.color }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:  coder)
        
        layer.masksToBounds = true
        
        subscribeToSession()
        subscribeToSessionMetircs()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
}

// MARK: - Subscriptions

extension SessionMetricsButton {
    
    private func subscribeToSession() {
        
        cobrowseSession.$current.sink { [weak self] session in
            
            guard let self, let session, !session.isActive()
                else { return }
            
            self.latency = .unknown
        }
        .store(in: &bag)
    }
    
    private func subscribeToSessionMetircs() {
        
        cobrowseSession.$metrics.sink { [weak self] metrics in
            
            self?.latency = .unknown
            
            guard let metrics
                else { return }
            
            let latencey = metrics.latency()
            
            switch latencey {
                case 0:
                    self?.latency = .unknown
                    break
                
                case 0.01...0.3:
                    self?.latency = .low
                    break
                
                case 0.31...0.8:
                    self?.latency = .medium
                    break
                
                default:
                    self?.latency = .high
                    break
            }
        }
        .store(in: &bag)
    }
}
