import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value(for key: String) throws -> String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        
        guard let value = object as? String else {
            throw Error.invalidValue
        }
        return value
    }
}

enum API {
    static var baseURL: URL {
        // If not set in Info.plist, fallback to default hardcoded value to avoid crashes during development
        let defaultURL = URL(string: "https://hiring-api.samba.dev.assaabloyglobalsolutions.net")!
        do {
            let urlString = try Configuration.value(for: "BASE_URL")
            if let url = URL(string: urlString) {
                return url
            }
        } catch {
            return defaultURL
        }
        return defaultURL
    }
}