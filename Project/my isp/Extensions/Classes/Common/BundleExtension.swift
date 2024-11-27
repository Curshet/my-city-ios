import Foundation

extension Bundle: BundleProtocol {
    
    var displayName: String {
        String(object(forInfoDictionaryKey: "CFBundleDisplayName"))
    }
    
    var name: String {
        String(object(forInfoDictionaryKey: "CFBundleName"))
    }
    
    var identifier: String {
        String(object(forInfoDictionaryKey: "CFBundleIdentifier"))
    }
    
    var version: String {
        String(object(forInfoDictionaryKey: "CFBundleShortVersionString"))
    }
    
    var build: String {
        String(object(forInfoDictionaryKey: "CFBundleVersion"))
    }

}
