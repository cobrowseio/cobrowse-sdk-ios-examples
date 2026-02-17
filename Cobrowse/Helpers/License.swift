
import Foundation

enum License {
    
    static func isKnown(_ license: String) async throws -> Bool {
        
        if try bundled.licenses.contains(license) {
            return true
        }
        
        if let response {
            // Use the in-memory response that was previously fetched
            return response.licenses.contains(license)
        } else {
            // Fetch the remote list
            let response = try await fetchRemote()
            self.response = response
            
            return response.licenses.contains(license)
        }
    }
    
    private static var response: Response?
    
    private static let remoteURL = URL(string: "https://raw.githubusercontent.com/cobrowseio/cobrowse-sdk-ios-examples/master/Cobrowse/Recources/knownLicenses.json")!
    
    private static func fetchRemote() async throws -> Response {
        
        let (data, _) = try await URLSession.shared.data(from: remoteURL)
        let response = try JSONDecoder().decode(Response.self, from: data)

        return response
    }
    
    private static var bundled: Response {
        get throws {
            
            let url = Bundle.main.url(forResource: "knownLicenses", withExtension: "json")!
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(Response.self, from: data)
            
            return response
        }
    }
    
    private struct Response: Decodable {
        let licenses: [String]
    }
}
