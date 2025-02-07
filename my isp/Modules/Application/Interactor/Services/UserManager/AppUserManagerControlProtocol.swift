import Foundation
import Combine

protocol AppUserManagerControlProtocol: AppUserManagerInfoProtocol {
    var internalEventPublisher: PassthroughSubject<AppUserManagerInternalEvent, Never> { get }
}
