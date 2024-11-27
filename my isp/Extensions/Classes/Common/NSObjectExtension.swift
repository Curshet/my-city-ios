import Foundation
import MetricKit

extension NSObject: MXMetricManagerSubscriber, LoggingProtocol {
    
    static var typeName: String {
        description()
    }
    
    static func address<T>(_ object: T) -> String {
        let bitCast = unsafeBitCast(object, to: Int.self)
        return String(NSString(format: "%p", bitCast))
    }
    
    /// Object type name
    var typeName: String {
        Self.typeName
    }
    
    /// Object memory address
    var address: String {
        Self.address(self)
    }
    
}
