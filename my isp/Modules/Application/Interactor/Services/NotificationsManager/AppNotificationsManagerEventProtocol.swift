import Foundation
import Combine

protocol AppNotificationsManagerEventProtocol: AnyObject {
    var externalEventPublisher: AnyPublisher<AppNotificationsManagerExternalEvent, Never> { get }
}
