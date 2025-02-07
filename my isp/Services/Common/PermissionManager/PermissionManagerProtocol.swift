import Foundation
import Combine

protocol PermissionManagerProtocol {
    var internalEventPublisher: PassthroughSubject<PermissionManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<PermissionManagerExternalEvent, Never> { get }
    var information: PermissionManagerData { get }
}
