import Foundation
import Combine

protocol AppNotificationsManagerControlProtocol: AppNotificationsManagerEventProtocol, AppNotificationsManagerPresentProtocol {
    var internalEventPublisher: PassthroughSubject<AppNotificationsManagerInternalEvent, Never> { get }
}
