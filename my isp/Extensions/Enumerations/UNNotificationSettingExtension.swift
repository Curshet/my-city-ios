import Foundation
import UserNotifications

extension UNNotificationSetting {

    var description: String {
        switch self {
            case .notSupported:
                "not supported"
            
            case .disabled:
                "disabled"
            
            case .enabled:
                "enabled"
            
            default:
                "unknown"
        }
    }
    
}
