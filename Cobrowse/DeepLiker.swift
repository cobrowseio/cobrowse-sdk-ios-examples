//
//  DeepLiker.swift
//  Cobrowse
//

import CobrowseIO

enum DeepLinker {
    
    static func handle(_ url: URL) -> Bool {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else { return false }
        
        guard components.path.isEmpty, let id = components.fragment
            else { return handleAction(with: components) }
        
        return startSession(with: id)
    }
    
    private static func handleAction(with components: URLComponents) -> Bool {
        
        let action = components.path.split(separator: "/").first
        
        switch action {
            case "api": return updateAPI(using: components)
            case "license": return updateLicense(using: components)
            case "data": return updateCustomData(using: components)
            case "s": return startSession(using: components)
            case "code": return startSession(using: components)
            default: return false
        }
    }
}

extension DeepLinker {
    
    private static func updateAPI(using components: URLComponents) -> Bool {
        
        let api = components.path.trimmingPrefix("/api/")
        
        let cobrowse = CobrowseIO.instance()
        
        cobrowse.stop()
        cobrowse.api = String(api)
        cobrowse.start()
        
        return true
    }
    
    private static func updateLicense(using components: URLComponents) -> Bool {
        
        guard let license = components.path.split(separator: "/").last
            else { return false }
        
        let cobrowse = CobrowseIO.instance()
        
        cobrowse.stop()
        cobrowse.license = String(license)
        cobrowse.start()
        
        return true
    }
    
    private static func updateCustomData(using components: URLComponents) -> Bool {
        
        guard let data = components.queryItems?.reduce(into: [String : NSObject](), { partialResult, item in
            guard let value = item.value
                else { return }
            
            partialResult[item.name] = value as NSObject
        })
        else { return false }
        
        CobrowseIO.instance().customData = data
        
        return true
    }
    
    private static func startSession(using components: URLComponents) -> Bool {
        
        if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
            return startSession(with: id)
        } else if let code = components.path.split(separator: "/").last {
            return startSession(with: String(code))
        }
            
        return false
    }
    
    private static func startSession(with id: String) -> Bool {
        
        let cobrowse = CobrowseIO.instance()
        
        cobrowse.stop()
        cobrowse.start()
        cobrowse.getSession(id)
        
        return true
    }
}
