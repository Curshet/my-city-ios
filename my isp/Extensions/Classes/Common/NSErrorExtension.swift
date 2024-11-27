import Foundation

extension NSError {
    
    static var system: NSError {
        NSError(text: .localized.systemError, code: 766)
    }
    
    static func dataFailure(domain: String) -> NSError {
        NSError(text: .localized.dataError, code: 755, domain: domain)
    }
    
    convenience init(text: String, code: Int = 700, domain: String = .clear) {
        let description = text.isEmpty() ? .localized.unknownError : text
        let path = domain.isEmpty() ? Bundle.main.identifier : domain
        self.init(domain: path, code: code, userInfo: [NSLocalizedDescriptionKey : description.lowercased()])
    }
    
}
