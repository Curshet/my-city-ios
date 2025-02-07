import UIKit

protocol AppNotificationsManagerAuthorizationProtocol: AnyObject {
    func requestAuthorization(_ completion: ((UNNotificationSettings) -> Void)?)
}
