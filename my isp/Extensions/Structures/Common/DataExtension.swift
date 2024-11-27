import Foundation

extension Data {
    
    static var clear: Self {
        Data()
    }
    
    init(_ optional: Self?) {
        self = optional ?? .clear
    }
    
}
