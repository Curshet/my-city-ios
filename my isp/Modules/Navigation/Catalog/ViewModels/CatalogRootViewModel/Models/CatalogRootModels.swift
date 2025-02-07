import Foundation
import UserNotifications

// MARK: - CatalogRootPermissionData
struct CatalogRootPermissionData {
    let settings: UNNotificationSettings
    let information: PermissionManagerData
}

// MARK: - CatalogRootRequest
struct CatalogRootRequest {
    let deviceInfo: NetworkManagerRequest
    let firebaseInfo: NetworkManagerRequest
}
