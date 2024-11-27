import Foundation

protocol AppNotificationsManagerPresentProtocol: AnyObject {
    func presentUserNotification(_ type: AppUserNotificationType)
}
